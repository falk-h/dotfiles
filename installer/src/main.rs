mod fail;
mod install;
mod logging;
mod path;

use clap::{app_from_crate, App, AppSettings, Arg};
use simplelog::LevelFilter;

fn main() {
    // Force a recompile if Cargo.toml is changed since app_from_crate! reads values from Cargo.toml.
    const _: &str = include_str!("../Cargo.toml");
    let args = app_from_crate!()
        .setting(AppSettings::SubcommandRequiredElseHelp)
        .args(&[
            Arg::new("verbose")
                .short('v')
                .long("verbose")
                .help("Increases verbosity")
                .multiple_occurrences(true),
            Arg::new("quiet")
                .short('q')
                .long("quiet")
                .help("Decreases verbosity")
                .multiple_occurrences(true),
        ])
        .subcommands(vec![
            App::new("install").about("Creates symlinks for all dotfiles in your home directory")
        ])
        .get_matches();

    let log_levels = [
        LevelFilter::Off,
        LevelFilter::Error,
        LevelFilter::Warn,
        LevelFilter::Info,
        LevelFilter::Debug,
        LevelFilter::Trace,
    ];
    let default_log_level = 3;
    let verbose = args.occurrences_of("verbose").try_into().unwrap_or(isize::MAX);
    let quiet = args.occurrences_of("quiet").try_into().unwrap_or(isize::MAX);
    let log_level_index = (default_log_level + verbose - quiet)
        .try_into()
        .unwrap_or(0)
        .min(log_levels.len() - 1);
    let log_level = log_levels[log_level_index];

    logging::init(log_level);

    match args.subcommand() {
        Some(("install", _)) => install::install(),
        _ => fail!("Couldn't determine subcommand!"),
    }
}
