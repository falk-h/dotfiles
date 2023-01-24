mod fail;
mod install;
mod logging;
mod path;

use clap::{Arg, ArgAction, Command};
use simplelog::LevelFilter;

fn main() {
    // Force a recompile if Cargo.toml is changed since clap::command reads values from Cargo.toml.
    const _: &str = include_str!("../Cargo.toml");
    let args = clap::command!()
        .arg_required_else_help(true)
        .args(&[
            Arg::new("verbose")
                .short('v')
                .long("verbose")
                .help("Increases verbosity")
                .action(ArgAction::Count),
            Arg::new("quiet")
                .short('q')
                .long("quiet")
                .help("Decreases verbosity")
                .action(ArgAction::Count),
        ])
        .subcommand(Command::new("install").about("Creates symlinks for all dotfiles in your home directory"))
        .get_matches();

    let log_levels: Vec<_> = LevelFilter::iter().collect();
    let default_log_level = 3;
    let verbose: usize = args.get_count("verbose").into();
    let quiet: usize = args.get_count("quiet").into();
    let log_level_index = (default_log_level + verbose - quiet).clamp(0, log_levels.len() - 1);
    let log_level = log_levels[log_level_index];

    logging::init(log_level);

    match args.subcommand() {
        Some(("install", _)) => install::install(),
        _ => fail!("Couldn't determine subcommand!"),
    }
}
