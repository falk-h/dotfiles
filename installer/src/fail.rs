#[macro_export]
macro_rules! fail {
    ($($arg:tt)+) => ({
        #[cfg(test)]
        {
            panic!($($arg)+)
        }
        #[cfg(not(test))]
        {
            log::error!($($arg)+);
            std::process::exit(1)
        }
    });
}
