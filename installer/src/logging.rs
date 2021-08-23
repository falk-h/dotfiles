use std::{fs::File, sync::Once};

use chrono::Local;
#[cfg(test)]
use simplelog::TestLogger;
use simplelog::{
    ColorChoice, CombinedLogger, Config, ConfigBuilder, LevelFilter, SharedLogger, TermLogger, TerminalMode,
    WriteLogger,
};

use crate::fail;

const LOG_FILE_FORMAT: &str = "dotfiles-installer_%Y-%m-%d_%H:%M:%S.log";

static INITIALIZED: Once = Once::new();

pub fn init(stdout_level: LevelFilter) {
    INITIALIZED.call_once(|| {
        let config = make_config();
        let mut loggers: Vec<Box<dyn SharedLogger>> = Vec::with_capacity(2);

        loggers.push(TermLogger::new(
            stdout_level,
            config.clone(),
            TerminalMode::Mixed,
            ColorChoice::Auto,
        ));

        let log_file = make_log_file_path();
        let file_err = File::create(&log_file)
            .map(|f| {
                loggers.push(WriteLogger::new(LevelFilter::Trace, config, f));
            })
            .err();

        CombinedLogger::init(loggers)
            .map_err(|e| fail!("Failed to initialize logging: {}", e))
            .unwrap();

        if let Some(e) = file_err {
            log::error!("Failed to create log file {}: {}", log_file, e);
            log::warn!("Continuing with logging only to stdout");
        } else {
            log::info!("Logging to {}", log_file);
        }
    });
}

#[cfg(test)]
pub fn init_test() {
    INITIALIZED.call_once(|| {
        TestLogger::init(LevelFilter::Trace, make_config())
            .map_err(|e| panic!("Failed to initialize logging: {}", e))
            .unwrap()
    });
}

fn make_config() -> Config {
    ConfigBuilder::new().set_time_level(LevelFilter::Trace).build()
}

fn make_log_file_path() -> String {
    let timestamp = Local::now();
    timestamp.format(LOG_FILE_FORMAT).to_string()
}
