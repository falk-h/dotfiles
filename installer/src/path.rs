use std::{
    borrow::Cow,
    fmt::{self, Display, Formatter},
    path::{Path, PathBuf},
};

/// A path to a file in some prefix.
pub trait FilePath: Display + Sized {
    type Prefix: Prefix;

    fn prefix(&self) -> &Self::Prefix;

    fn rel_file(&self) -> &RelPath;

    fn new(prefix: &Self::Prefix, file: &RelPath) -> Self;

    fn to_string_lossy(&self) -> String {
        format!("{}/{}", self.prefix().to_string_lossy(), self.rel_file())
    }

    fn to_path_buf(&self) -> PathBuf {
        self.prefix().as_path_buf().join(self.rel_file().as_path_buf())
    }

    fn parent(&self) -> Option<Self> {
        Some(Self::new(self.prefix(), &self.rel_file().parent()?))
    }
}

/// The path to a prefix.
pub trait Prefix: Display + Sized {
    type File: FilePath;

    fn new<P: AsRef<Path>>(path: P) -> Self;

    fn as_path_buf(&self) -> &PathBuf;

    fn with_rel_file(&self, path: &RelPath) -> Self::File;

    fn as_path(&self) -> &Path {
        self.as_path_buf()
    }

    fn to_string_lossy(&self) -> Cow<'_, str> {
        self.as_path().to_string_lossy()
    }
}

/// An absolute path to a file in the home directory.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct HomeFile(HomePath, RelPath);

/// An absolute path to a file in the backup directory.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct BackupFile(BackupPath, RelPath);

/// An absolute path to a dotfile in the dotfiles repository.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct Dotfile(DotfilesPath, RelPath);

/// The path to the home directory.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct HomePath(PathBuf);

/// The path to the backup directory.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct BackupPath(PathBuf);

/// The path to the dotfiles in the dotfiles repository.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct DotfilesPath(PathBuf);

/// The path to the submodules in the dotfiles repository.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct SubmodulesPath(PathBuf);

/// A relative path to a file.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct RelPath(PathBuf);

/// The path to the install scripts in the dotfiles repository.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct InstallScriptsPath(PathBuf);

impl InstallScriptsPath {
    pub fn new<P: AsRef<Path>>(path: P) -> Self {
        Self(path.as_ref().to_path_buf())
    }

    pub fn as_path(&self) -> &Path {
        &self.0
    }
}

impl SubmodulesPath {
    pub fn new<P: AsRef<Path>>(path: P) -> Self {
        Self(path.as_ref().to_path_buf())
    }

    pub fn as_path(&self) -> &Path {
        &self.0
    }

    fn to_string_lossy(&self) -> Cow<'_, str> {
        self.0.to_string_lossy()
    }
}

macro_rules! impl_file_path {
    ($t:ty, $p:ty) => {
        impl FilePath for $t {
            type Prefix = $p;

            fn prefix(&self) -> &Self::Prefix {
                &self.0
            }

            fn rel_file(&self) -> &RelPath {
                &self.1
            }

            fn new(prefix: &Self::Prefix, file: &RelPath) -> Self {
                Self(prefix.clone(), file.clone())
            }
        }
    };
}

impl_file_path!(HomeFile, HomePath);
impl_file_path!(BackupFile, BackupPath);
impl_file_path!(Dotfile, DotfilesPath);

macro_rules! impl_prefix {
    ($t:ty, $f:ty) => {
        impl Prefix for $t {
            type File = $f;

            fn new<P: AsRef<Path>>(path: P) -> Self {
                Self(path.as_ref().to_owned())
            }

            fn as_path_buf(&self) -> &PathBuf {
                &self.0
            }

            fn with_rel_file(&self, path: &RelPath) -> Self::File {
                Self::File::new(self, path)
            }
        }
    };
}

impl_prefix!(HomePath, HomeFile);
impl_prefix!(BackupPath, BackupFile);
impl_prefix!(DotfilesPath, Dotfile);

macro_rules! impl_display {
    ($t:ty) => {
        impl Display for $t {
            fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), fmt::Error> {
                write!(f, "{}", self.to_string_lossy())
            }
        }
    };
}

impl_display!(RelPath);
impl_display!(HomeFile);
impl_display!(BackupFile);
impl_display!(Dotfile);
impl_display!(HomePath);
impl_display!(BackupPath);
impl_display!(DotfilesPath);
impl_display!(SubmodulesPath);

impl RelPath {
    pub fn new<P: AsRef<Path>>(path: P) -> Self {
        assert!(path.as_ref().is_relative());
        Self(path.as_ref().to_path_buf())
    }

    pub fn as_path_buf(&self) -> &PathBuf {
        &self.0
    }

    pub fn to_string_lossy(&self) -> Cow<'_, str> {
        self.0.to_string_lossy()
    }

    fn parent(&self) -> Option<Self> {
        Some(Self::new(self.as_path_buf().parent()?))
    }
}
