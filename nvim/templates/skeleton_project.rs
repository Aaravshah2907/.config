//! Project: <Project Name>
//! Description: <Brief overview of application purpose>

use std::error::Error;
use std::process::ExitCode;

type Result<T> = std::result::Result<T, Box<dyn Error>>;

fn run() -> Result<()> {
    let app_name = option_env!("CARGO_PKG_NAME").unwrap_or("project");
    println!("Starting {app_name}...");
    Ok(())
}

fn main() -> ExitCode {
    if let Err(err) = run() {
        eprintln!("[ERROR] {err}");
        return ExitCode::FAILURE;
    }
    ExitCode::SUCCESS
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert!(run().is_ok());
    }
}
