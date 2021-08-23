use std::{
    env,
    ffi::OsStr,
    fs::{self, FileType},
    io::{self, ErrorKind},
    os::unix::{self, process::ExitStatusExt},
    path::{Path, PathBuf},
    process::{Command, Stdio},
};

use chrono::Local;
use nix::{
    errno::Errno,
    unistd::{self, AccessFlags, Uid, User},
};

use crate::fail;
use crate::path::*;

const FILES_DIR: &str = "files";
const SCRIPTS_DIR: &str = "installer/scripts";
const BACKUP_DIR_FORMAT: &str = "dotfiles-backup_%Y-%m-%d_%H:%M:%S";
const README_FILE: &str = "README.md";
const README_CONTENTS: &str = include_str!("backup_dir_readme.md");
const HOME_SUBMODULE_DIR: &str = ".dotfiles-submodules";
const REPO_SUBMODULE_DIR: &str = "submodules";

pub fn install() {
    let home_dir = find_home_dir();
    log::info!("Found home directory: {}", home_dir);

    let (file_root, submodules_path, scripts_path) = find_repo_dirs();
    let repo_root = file_root.as_path_buf().parent().unwrap();
    log::info!("Found dotfile repo: {}", repo_root.to_string_lossy());
    log::info!("Dotfile directory: {}", file_root);

    log::info!("Checking out submodules");
    checkout_submodules(&repo_root);
    log::info!("Checkout done");

    log::debug!("Finding dotfiles");
    let files = recurse_through_dir(file_root.as_path_buf(), |p| {
        RelPath::new(p.strip_prefix(file_root.as_path_buf()).unwrap())
    });
    log::debug!(
        "Found {}",
        files.iter().map(|f| format!("{}", f)).collect::<Vec<_>>().join(" ")
    );

    log::info!("Creating backup");
    let backup_dir = create_backup(&home_dir, &files);
    log::info!("Backup done");

    log::info!("Installing symlinks");
    create_symlinks(&home_dir, &file_root, &backup_dir, &files);
    create_submodule_symlink(&home_dir, &backup_dir, &submodules_path);
    log::info!("Symlinking done");

    log::info!("Running install scripts");
    run_install_scripts(scripts_path, &file_root, repo_root);
    log::info!("Install scripts done");

    log::info!("");
    log::info!("Happy hacking!");
}

fn find_repo_dirs() -> (DotfilesPath, SubmodulesPath, InstallScriptsPath) {
    log::debug!("Finding repo root");
    let binary_path = env::current_exe().expect("Failed to get the path to the binary!");
    // env::current_exe *seems* to always return an absolute path, but let's make sure.
    assert!(binary_path.is_absolute());

    for dir in binary_path.parent().unwrap().ancestors() {
        log::debug!("Checking {}", dir.to_string_lossy());
        if dir.join(".git").is_dir() {
            let path_buf = dir.to_path_buf();
            return (
                DotfilesPath::new(path_buf.join(FILES_DIR)),
                SubmodulesPath::new(path_buf.join(REPO_SUBMODULE_DIR)),
                InstallScriptsPath::new(path_buf.join(SCRIPTS_DIR)),
            );
        }
    }

    fail!("Couldn't find the root of the dotfile repository! Make sure to run this binary inside the repo.")
}

fn find_home_dir() -> HomePath {
    log::debug!("Finding home directory");
    const ERR: &str = "Failed to get user info for the current user";
    HomePath::new(
        User::from_uid(Uid::current())
            .map_err(|e| fail!("{}: {}", ERR, e))
            .unwrap()
            .expect(ERR)
            .dir,
    )
}

fn make_home_submodule_dir(home_dir: &HomePath) -> HomeFile {
    home_dir.with_rel_file(&RelPath::new(HOME_SUBMODULE_DIR))
}

fn symlinks_equal(a: &HomeFile, b: &BackupFile) -> bool {
    assert!(get_file_type(a).is_symlink());
    assert!(get_file_type(b).is_symlink());

    let a_target = a
        .to_path_buf()
        .read_link()
        .map_err(|e| fail!("Failed to read symlink {}: {}", a, e))
        .unwrap();
    let b_target = b
        .to_path_buf()
        .read_link()
        .map_err(|e| fail!("Failed to read symlink {}: {}", b, e))
        .unwrap();

    let equal = a_target == b_target;
    if equal {
        log::trace!(
            "Symlinks ({} -> {}) and ({} -> {}) are equal",
            a,
            a_target.to_string_lossy(),
            b,
            b_target.to_string_lossy()
        )
    } else {
        log::warn!(
            "Symlinks ({} -> {}) and ({} -> {}) have different targets",
            a,
            a_target.to_string_lossy(),
            b,
            b_target.to_string_lossy()
        )
    }
    equal
}

fn files_equal_by_contents(a: &HomeFile, b: &BackupFile) -> bool {
    assert!(get_file_type(a).is_file());
    assert!(get_file_type(b).is_file());

    let a_contents = fs::read(a.to_path_buf()).map_err(|e| fail!("Failed to read {}: {}", a, e));
    let b_contents = fs::read(b.to_path_buf()).map_err(|e| fail!("Failed to read {}: {}", b, e));
    (a_contents == b_contents)
        .then(|| log::trace!("Files {} and {} are equal", a, b))
        .ok_or_else(|| log::warn!("Files {} and {} have different contents", a, b))
        .is_ok()
}

fn files_equal(a: &HomeFile, b: &BackupFile) -> bool {
    log::debug!("Checking that {} and {} are equal", a, b);

    let a_type = get_file_type(a);
    let b_type = get_file_type(b);
    if a_type != b_type {
        log::warn!("Files {} and {} have different file types", a, b);
        return false;
    }

    if a_type.is_file() {
        files_equal_by_contents(a, b)
    } else if a_type.is_symlink() {
        symlinks_equal(a, b)
    } else if a_type.is_dir() {
        recurse_through_dir(a.to_path_buf(), |p| {
            let rel_path = RelPath::new(p.strip_prefix(a.to_path_buf()).unwrap());
            let a = HomeFile::new(&HomePath::new(a.to_path_buf()), &rel_path);
            let b = BackupFile::new(&BackupPath::new(b.to_path_buf()), &rel_path);
            files_equal(&a, &b)
        })
        .iter()
        .all(|&x| x)
    } else {
        fail!(
            "Can't compare files {} and {} with unknown file type {:?}",
            a,
            b,
            a_type
        );
    }
}

fn verify_backup_and_remove(file: &RelPath, home_dir: &HomePath, backup_dir: &BackupPath) {
    let home_file = home_dir.with_rel_file(file);
    let backup_file = backup_dir.with_rel_file(file);

    if !files_equal(&home_file, &backup_file) {
        log::error!("Not deleting {} because it's not backed up properly", home_file);
        fail!("Bailing out!");
    }

    let home_file_type = get_file_type(&home_file);
    if home_file_type.is_symlink() || home_file_type.is_file() {
        log::debug!("Deleting {}", home_file);
        fs::remove_file(home_file.to_path_buf())
            .map_err(|e| fail!("Failed to remove {}: {}", home_file, e))
            .unwrap();
    } else if home_file_type.is_dir() {
        log::debug!("Deleting {} recursively", home_file);
        fs::remove_dir_all(home_file.to_path_buf())
            .map_err(|e| fail!("Failed to remove {}: {}", home_file, e))
            .unwrap();
    } else {
        fail!(
            "Not deleting {} because it has the unknown type {:?}",
            home_file,
            home_file_type
        );
    }
}

fn copy_symlink(link: &HomeFile, destination: &BackupFile) -> io::Result<()> {
    let target = fs::read_link(link.to_path_buf())?;
    log::trace!(
        "Coping symlink ({} -> {}) to {}",
        link,
        target.to_string_lossy(),
        destination
    );
    unix::fs::symlink(&target, destination.to_path_buf())
}

/// Checks that a file/directory exists. Note that unlike Path::exists(), this does not follow
/// symlinks, meaning that it will return `true` for broken symlinks.
fn file_exists<P: FilePath>(path: &P) -> bool {
    !matches!(path.to_path_buf().read_link(), Err(e) if e.kind() == ErrorKind::NotFound)
}

fn is_symlink<P: FilePath>(path: &P) -> bool {
    file_exists(path)
        && path
            .to_path_buf()
            .symlink_metadata()
            .map_err(|e| fail!("Failed to get metadata for {}: {}", path, e))
            .unwrap()
            .file_type()
            .is_symlink()
}

fn get_file_type<P: FilePath>(path: &P) -> FileType {
    let ret = path
        .to_path_buf()
        .symlink_metadata()
        .map_err(|e| fail!("Failed to get metadata for {}: {}", path, e))
        .unwrap()
        .file_type();
    log::trace!("File {} has filetype {:?}", path, ret);
    ret
}

fn recurse_through_dir<P: AsRef<Path>, F, R>(path: P, mut op: F) -> Vec<R>
where
    F: FnMut(PathBuf) -> R + Copy,
{
    let path = path.as_ref();
    let mut ret = Vec::new();

    for entry in path.read_dir().unwrap() {
        let entry = entry
            .map_err(|e| fail!("Failed to get directory entry in {}: {}", path.to_string_lossy(), e))
            .unwrap();
        let entry_path = entry.path();
        let is_dir = entry
            .file_type()
            .map_err(|e| fail!("Failed to get file type for {}: {}", entry_path.to_string_lossy(), e))
            .unwrap()
            .is_dir();
        if is_dir {
            ret.append(&mut recurse_through_dir(entry_path, op));
        } else {
            ret.push(op(entry_path));
        }
    }

    ret
}

fn create_backup(home_dir: &HomePath, files: &[RelPath]) -> BackupPath {
    let backup_dir = create_backup_dir(home_dir);

    for file in files {
        log::info!("Backing up {}", file);
        backup_file(file, home_dir, &backup_dir);
    }

    backup_submodules(home_dir, &backup_dir);

    backup_dir
}

fn create_backup_dir(home_dir: &HomePath) -> BackupPath {
    let timestamp = Local::now();
    let backup_dir_name = timestamp.format(BACKUP_DIR_FORMAT).to_string();
    let backup_dir = BackupPath::new(home_dir.with_rel_file(&RelPath::new(backup_dir_name)).to_path_buf());

    log::info!("Creating backup directory {}", backup_dir);
    fs::create_dir(backup_dir.as_path_buf())
        .map_err(|e| fail!("Failed to create backup directory {}: {}", backup_dir, e))
        .unwrap();

    let readme_file = backup_dir.with_rel_file(&RelPath::new(README_FILE));

    log::debug!("Creating readme file {}", readme_file);
    fs::write(readme_file.to_path_buf(), README_CONTENTS)
        .map_err(|e| fail!("Failed to create readme file {}: {}", readme_file, e))
        .unwrap();

    backup_dir
}

fn backup_file(relative_file: &RelPath, home_dir: &HomePath, backup_dir: &BackupPath) {
    let file = home_dir.with_rel_file(relative_file);

    if !file_exists(&file) {
        log::debug!("Not backing up {} because it doesn't exist", file);
        return;
    }

    let backup_file = backup_dir.with_rel_file(relative_file);
    log::trace!("Backing up {} to {}", file, backup_file);

    let backup_subdir = backup_file.parent().unwrap();
    if !file_exists(&backup_subdir) {
        log::debug!("Creating subdirectory {} in backup directory", backup_subdir);
        fs::create_dir_all(backup_subdir.to_path_buf())
            .map_err(|e| fail!("Failed to create directory {}: {}", backup_subdir, e))
            .unwrap();
    }

    if is_symlink(&file) {
        copy_symlink(&file, &backup_file)
            .map_err(|e| {
                let link_target = fs::read_link(file.to_path_buf())
                    .unwrap_or_else(|_| Path::new("<couldn't read symlink>").to_path_buf());
                fail!(
                    "Failed to copy symlink ({} -> {}) to {}: {}",
                    file,
                    link_target.to_string_lossy(),
                    backup_file,
                    e
                )
            })
            .unwrap();
    } else {
        fs::copy(file.to_path_buf(), backup_file.to_path_buf())
            .map_err(|e| fail!("Failed to copy {} to {}: {}", file, backup_file, e))
            .unwrap();
    }
}

fn backup_submodules(home_dir: &HomePath, backup_dir: &BackupPath) {
    let submodule_dir = make_home_submodule_dir(home_dir);

    if !file_exists(&submodule_dir) {
        log::debug!(
            "Not backing up submodule dir {} because it doesn't exist",
            submodule_dir
        );
        return;
    }

    let submodule_dir_type = get_file_type(&submodule_dir);
    log::debug!("Got submodule dir type {:?}", submodule_dir_type);

    log::info!("Backing up submodules at ~/{}", submodule_dir.rel_file());
    if submodule_dir_type.is_symlink() {
        log::debug!("Backing up submodules by copying symlink");
        backup_file(&RelPath::new(HOME_SUBMODULE_DIR), home_dir, backup_dir);
    } else if submodule_dir_type.is_dir() {
        log::debug!("Backing up submodules by copying file-by-file");
        let files = recurse_through_dir(submodule_dir.to_path_buf(), |p| {
            backup_file(
                &RelPath::new(p.strip_prefix(home_dir.as_path_buf()).unwrap()),
                home_dir,
                backup_dir,
            )
        });
        log::info!("Backed up {} files from submodule dir", files.len());
    } else {
        fail!(
            "Can't back up submodule dir because it has the unknown type {:?}",
            submodule_dir_type
        );
    }
}

fn create_symlinks(home_dir: &HomePath, file_dir: &DotfilesPath, backup_dir: &BackupPath, files: &[RelPath]) {
    for file in files {
        log::debug!("Installing {}", file);

        let target = file_dir.with_rel_file(file);
        let link_name = home_dir.with_rel_file(file);
        let link_dir = link_name.parent().unwrap();

        if file_exists(&link_name) {
            log::debug!("Deleting {}", link_name);
            verify_backup_and_remove(file, home_dir, backup_dir)
        } else if !file_exists(&link_dir) {
            log::debug!("Creating directory {}", link_dir);
            fs::create_dir_all(link_dir.to_path_buf())
                .map_err(|e| fail!("Failed to create directory {}: {}", link_dir, e))
                .unwrap();
        }

        log::info!("Linking {}", link_name.rel_file());
        create_symlink(&target, &link_name);
    }
}

fn create_symlink(target: &Dotfile, link_name: &HomeFile) {
    unix::fs::symlink(target.to_path_buf(), link_name.to_path_buf())
        .map_err(|e| fail!("Failed to create link from {} to {}: {}", link_name, target, e))
        .unwrap();
}

fn command_name(command: &Path) -> &str {
    command
        .file_name()
        .unwrap_or_else(|| fail!("Tried to run a command which doesn't point to a file"))
        .to_str()
        .unwrap_or_else(|| fail!("Tried to run a command which isn't valid Unicode"))
}

fn run_command<C, A, D>(command: C, args: &[A], cwd: D)
where
    C: AsRef<Path>,
    A: AsRef<OsStr>,
    D: AsRef<Path>,
{
    let name = command_name(command.as_ref());
    let mut cmd = Command::new(command.as_ref());
    cmd.args(args).current_dir(cwd).stdin(Stdio::inherit());
    log::debug!("Spawning {:?}", &cmd);
    let output = cmd
        .output()
        .map_err(|e| fail!("Failed to spawn {}: {}", name, e))
        .unwrap();
    log::debug!("{} exited with {}", name, output.status);

    if !output.stdout.is_empty() {
        log::info!("{} stdout:", name);
        String::from_utf8_lossy(&output.stdout)
            .lines()
            .for_each(|s| log::info!("  {}", s.strip_suffix('\n').unwrap_or(s)));
    } else {
        log::debug!("No output on stdout from {}", name);
    }

    if !output.stderr.is_empty() {
        log::warn!("{} stderr:", name);
        String::from_utf8_lossy(&output.stderr)
            .lines()
            .for_each(|s| log::warn!("  {}", s.strip_suffix('\n').unwrap_or(s)));
    } else {
        log::debug!("No output on stderr from {}", name);
    }

    if !output.status.success() {
        if let Some(signal) = output.status.signal() {
            log::error!("{} was killed by signal {}", name, signal);
        }
        fail!("{} returned an error: {}", name, output.status);
    }
}

fn checkout_submodules<P: AsRef<Path>>(repo_root: P) {
    run_command("git", &["submodule", "update", "--init", "--recursive"], repo_root)
}

fn create_submodule_symlink(home_dir: &HomePath, backup_dir: &BackupPath, repo_submodule_dir: &SubmodulesPath) {
    let home_submodule_dir = make_home_submodule_dir(home_dir);

    if file_exists(&home_submodule_dir) {
        let submodule_dir_type = get_file_type(&home_submodule_dir);

        if submodule_dir_type.is_symlink() || submodule_dir_type.is_file() {
            log::debug!("Deleting {} because it's a file or symlink", home_submodule_dir);
            verify_backup_and_remove(home_submodule_dir.rel_file(), home_dir, backup_dir);
        } else if submodule_dir_type.is_dir() {
            log::debug!("Deleting {} because it's a file", home_submodule_dir);
            fs::remove_dir_all(home_submodule_dir.to_path_buf())
                .map_err(|e| fail!("Failed to remove {}: {}", home_submodule_dir, e))
                .unwrap();
        } else {
            fail!(
                "Not deleting {} because it has the unknown type {:?}",
                home_submodule_dir,
                submodule_dir_type
            );
        }
    }

    log::info!("Linking submodules at {}", home_submodule_dir.rel_file());
    unix::fs::symlink(repo_submodule_dir.as_path(), home_submodule_dir.to_path_buf())
        .map_err(|e| fail!("Failed to symlink submodules: {}", e))
        .unwrap();
}

fn run_install_scripts(dir: InstallScriptsPath, file_root: &DotfilesPath, repo_root: &Path) {
    if !dir.as_path().is_dir() {
        fail!(
            "Install script path {} does not seem to be a directory! This may be caused by missing \
            permissions.",
            dir.as_path().display(),
        )
    }

    let mut scripts = recurse_through_dir(dir.as_path(), |p| p);
    scripts.sort();

    for script in scripts {
        let name = command_name(&script);
        match unistd::access(&script, AccessFlags::X_OK) {
            Ok(()) => {
                log::info!("Running {}", name);
                run_command(script, &[file_root.as_path()], repo_root);
            }
            Err(Errno::EACCES) => {
                log::warn!("Skipping {} because it does not have execute permissions", name);
            }
            Err(errno) => fail!("Failed to check permissions of {}: {}", name, errno.desc()),
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    use tempfile::{Builder, TempDir};

    use crate::logging;

    struct Fixture(TempDir);

    impl Fixture {
        pub fn new() -> io::Result<Self> {
            logging::init_test();
            let temp_dir = Builder::new()
                .prefix("dotfile-installer-test-tmp-")
                .rand_bytes(8)
                .tempdir_in(".")?;
            log::debug!("Created temp dir {} for testing", temp_dir.path().to_string_lossy());
            Ok(Self(temp_dir))
        }

        pub fn file<T: FilePath>(&self, name: &str, contents: &str) -> io::Result<T> {
            let path = T::new(&<T as FilePath>::Prefix::new(self.0.path()), &RelPath::new(name));
            log::debug!("Creating temp file {} with contents '{}'", path, contents);
            fs::write(path.to_path_buf(), contents)?;
            Ok(path)
        }

        pub fn nonexistent_file<T: FilePath>(&self, name: &str) -> T {
            T::new(&T::Prefix::new(self.0.path()), &RelPath::new(name))
        }

        pub fn symlink<T: FilePath, P: AsRef<Path>>(&self, name: &str, target: P) -> io::Result<T> {
            let path = T::new(&T::Prefix::new(self.0.path()), &RelPath::new(name));
            log::debug!("Creating symlink {} -> {}", path, target.as_ref().to_string_lossy());
            unix::fs::symlink(target, path.to_path_buf())?;
            Ok(path)
        }
    }

    #[test]
    fn files_equal() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let a = fixture.file("a", "foo")?;
        let b = fixture.file("b", "foo")?;
        assert!(super::files_equal(&a, &b));
        Ok(())
    }

    #[test]
    fn files_equal_same_file() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let a = fixture.file("a", "foo")?;
        let b = fixture.file("a", "foo")?;
        assert!(super::files_equal(&a, &b));
        Ok(())
    }

    #[test]
    fn files_not_equal() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let a = fixture.file("a", "foo")?;
        let b = fixture.file("b", "bar")?;
        assert!(!super::files_equal(&a, &b));
        Ok(())
    }

    #[test]
    #[should_panic]
    fn file_equal_nonexistent_file() {
        let fixture = Fixture::new().unwrap();
        let a = fixture.file("a", "foo").unwrap();
        let b = fixture.nonexistent_file("b");
        assert!(!super::files_equal(&a, &b));
    }

    #[test]
    fn relative_symlinks_equal() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let a = fixture.symlink("a", "foo/bar")?;
        let b = fixture.symlink("b", "foo/bar")?;
        assert!(super::files_equal(&a, &b));
        Ok(())
    }

    #[test]
    fn absolute_symlinks_equal() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let a = fixture.symlink("a", "/foo/bar")?;
        let b = fixture.symlink("b", "/foo/bar")?;
        assert!(super::files_equal(&a, &b));
        Ok(())
    }

    #[test]
    fn relative_symlinks_not_equal() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let a = fixture.symlink("a", "foo/bar")?;
        let b = fixture.symlink("b", "bar/foo")?;
        assert!(!super::files_equal(&a, &b));
        Ok(())
    }

    #[test]
    fn absolute_symlinks_not_equal() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let a = fixture.symlink("a", "/foo/bar")?;
        let b = fixture.symlink("b", "/bar/foo")?;
        assert!(!super::files_equal(&a, &b));
        Ok(())
    }

    #[test]
    fn absolute_and_relative_symlink_with_the_same_target_not_equal() -> io::Result<()> {
        let fixture = Fixture::new()?;
        let target = fixture.file::<Dotfile>("target", "foo")?;

        log::trace!("{}", target);
        let a = fixture.symlink("a", target.to_path_buf())?;
        let b = fixture.symlink("b", "./target")?;

        assert!(!super::files_equal(&a, &b));
        Ok(())
    }
}
