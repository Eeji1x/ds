use anyhow::{Context, Result};
use dirs::home_dir;
use log::{error, info, warn};
use reqwest::blocking::Client;
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;
use std::process::Command;
use toml;

// Config struct - pretty simple stuff
#[derive(Debug, Deserialize, Serialize)]
struct Config {
    client_url: String,
    install_dir: String,
    wine_prefix: String,
    wine_mode: i32,
    enable_dxvk: bool,
    launch_args: String,
}

impl Default for Config {
    fn default() -> Self {
        let home = home_dir().unwrap_or_else(|| PathBuf::from("."));
        Config {
            client_url: "https://github.com/caelusinfra/windows-bootstrapper/releases/download/v2026.03.29.1453/CaelusLauncher.exe".to_string(),
            install_dir: home.join(".caelus").to_string_lossy().to_string(),
            wine_prefix: home.join(".caelus/wine").to_string_lossy().to_string(),
            wine_mode: 1,
            enable_dxvk: true,
            launch_args: String::new(),
        }
    }
}

// Load config from file or create default
fn load_config() -> Result<Config> {
    let home = home_dir().context("Couldn't get home directory")?;
    let config_path = home.join(".caelus/config.toml");
    
    if config_path.exists() {
        let content = fs::read_to_string(&config_path)
            .context("Couldn't read config file")?;
        let config: Config = toml::from_str(&content)
            .context("Couldn't parse config file")?;
        Ok(config)
    } else {
        let config = Config::default();
        save_config(&config)?;
        Ok(config)
    }
}

// Save config to file
fn save_config(config: &Config) -> Result<()> {
    let home = home_dir().context("Couldn't get home directory")?;
    let config_dir = home.join(".caelus");
    fs::create_dir_all(&config_dir)
        .context("Couldn't create config directory")?;
    
    let config_path = config_dir.join("config.toml");
    let content = toml::to_string_pretty(config)
        .context("Couldn't serialize config")?;
    fs::write(&config_path, content)
        .context("Couldn't write config file")?;
    Ok(())
}

// Check if wine is installed
fn check_wine() -> Result<()> {
    let output = Command::new("wine")
        .arg("--version")
        .output();
    
    match output {
        Ok(output) => {
            if output.status.success() {
                let version = String::from_utf8_lossy(&output.stdout);
                println!("Found Wine: {}", version.trim());
                
                // Check if Wine version is too old
                let version_str = version.trim();
                if version_str.contains("wine-11") || version_str.contains("wine-10") || version_str.contains("wine-9") {
                    println!("WARNING: Wine version is very old. Consider updating to Wine 8.0 or later for better compatibility.");
                    println!("On Ubuntu/Debian: sudo apt install --install-recommends winehq-stable");
                    println!("On Fedora: sudo dnf install wine");
                    println!("On Arch: sudo pacman -S wine");
                }
                
                Ok(())
            } else {
                Err(anyhow::anyhow!("Wine command failed"))
            }
        }
        Err(_) => {
            Err(anyhow::anyhow!("Wine not found. You need to install Wine first.\nOn Ubuntu/Debian: sudo apt install wine64\nOn Fedora: sudo dnf install wine\nOn Arch: sudo pacman -S wine"))
        }
    }
}

// Check for winetricks (optional but nice to have)
fn check_winetricks() -> Result<()> {
    let output = Command::new("winetricks")
        .arg("--version")
        .output();
    
    match output {
        Ok(output) => {
            if output.status.success() {
                println!("Found winetricks");
                Ok(())
            } else {
                Err(anyhow::anyhow!("Winetricks command failed"))
            }
        }
        Err(_) => {
            println!("Winetricks not found (optional but recommended)");
            Ok(())
        }
    }
}

// Install required Wine components using winetricks
fn install_wine_components(config: &Config) -> Result<()> {
    println!("Installing required Wine components...");
    
    let wine_prefix = &config.wine_prefix;
    std::env::set_var("WINEPREFIX", wine_prefix);
    
    // Install vcrun2019
    println!("Installing vcrun2019...");
    let status = Command::new("winetricks")
        .arg("-q")
        .arg("vcrun2019")
        .status();
    
    match status {
        Ok(s) if s.success() => println!("✓ vcrun2019 installed"),
        _ => println!("! vcrun2019 installation had issues (may still work)"),
    }
    
    // Install dotnet48
    println!("Installing dotnet48...");
    let status = Command::new("winetricks")
        .arg("-q")
        .arg("dotnet48")
        .status();
    
    match status {
        Ok(s) if s.success() => println!("✓ dotnet48 installed"),
        _ => println!("! dotnet48 installation had issues (may still work)"),
    }
    
    // Install msxml6
    println!("Installing msxml6...");
    let status = Command::new("winetricks")
        .arg("-q")
        .arg("msxml6")
        .status();
    
    match status {
        Ok(s) if s.success() => println!("✓ msxml6 installed"),
        _ => println!("! msxml6 installation had issues (may still work)"),
    }
    
    // Install corefonts
    println!("Installing corefonts...");
    let status = Command::new("winetricks")
        .arg("-q")
        .arg("corefonts")
        .status();
    
    match status {
        Ok(s) if s.success() => println!("✓ corefonts installed"),
        _ => println!("! corefonts installation had issues (may still work)"),
    }
    
    println!("Wine components installation complete");
    Ok(())
}

// Download the CaelusLauncher.exe
fn download_client(config: &Config) -> Result<()> {
    let client = Client::new();
    let url = &config.client_url;
    
    println!("Downloading CaelusLauncher.exe...");
    println!("From: {}", url);
    
    let response = client.get(url)
        .send()
        .context("Failed to download client")?;
    
    if !response.status().is_success() {
        return Err(anyhow::anyhow!("Download failed with status: {}", response.status()));
    }
    
    let bytes = response.bytes()
        .context("Failed to read response body")?;
    
    let install_path = PathBuf::from(&config.install_dir);
    fs::create_dir_all(&install_path)
        .context("Failed to create install directory")?;
    
    let exe_path = install_path.join("CaelusLauncher.exe");
    fs::write(&exe_path, bytes)
        .context("Failed to write client file")?;
    
    println!("Downloaded to: {}", exe_path.display());
    println!("Client installed successfully");
    Ok(())
}

// Launch the client using wine
fn launch_client(config: &Config) -> Result<()> {
    let install_path = PathBuf::from(&config.install_dir);
    
    // Look for CaelusLauncher.exe specifically
    let client_exe = install_path.join("CaelusLauncher.exe");
    
    if !client_exe.exists() {
        return Err(anyhow::anyhow!("CaelusLauncher.exe not found in {}", install_path.display()));
    }
    
    println!("Launching: {}", client_exe.display());
    
    // Set up wine environment
    let wine_prefix = &config.wine_prefix;
    std::env::set_var("WINEPREFIX", wine_prefix);
    
    // Enable DXVK if configured
    if config.enable_dxvk {
        std::env::set_var("WINEPREFIX", wine_prefix);
        // DXVK should be set up in the wine prefix
    }
    
    // Launch with wine
    let status = Command::new("wine")
        .arg(&client_exe)
        .spawn()
        .context("Failed to launch client")?;
    
    println!("Client launched with PID: {}", status.id());
    Ok(())
}

// Simple banner
fn print_banner() {
    println!("╔════════════════════════════════════════════════════════════╗");
    println!("║                                                          ║");
    println!("║              CAELUS LINUX BOOTSTRAPPER                    ║");
    println!("║                                                          ║");
    println!("║           Run Caelus on Linux with Wine                   ║");
    println!("║                                                          ║");
    println!("╚════════════════════════════════════════════════════════════╝");
    println!();
}

fn main() -> Result<()> {
    env_logger::init();
    print_banner();
    
    // Load configuration
    let config = load_config()
        .context("Failed to load configuration")?;
    
    println!("Config:");
    println!("  Client URL: {}", config.client_url);
    println!("  Install dir: {}", config.install_dir);
    println!("  Wine prefix: {}", config.wine_prefix);
    println!();
    
    // Check prerequisites
    println!("Checking prerequisites...");
    check_wine()
        .context("Wine check failed. Please install Wine.")?;
    check_winetricks()
        .context("Winetricks check failed.")?;
    
    // Install required Wine components
    install_wine_components(&config)?;
    println!();
    
    // Check if client is already installed
    let install_path = PathBuf::from(&config.install_dir);
    let client_exe = install_path.join("CaelusLauncher.exe");
    
    if client_exe.exists() {
        println!("Client already installed.");
        println!("Launching...");
        launch_client(&config)?;
    } else {
        println!("Client not found. Downloading...");
        download_client(&config)
            .context("Failed to download client")?;
        println!("Launching...");
        launch_client(&config)?;
    }
    
    println!();
    println!("Done! The client should be running now.");
    println!("If you have issues, check the Wine logs.");
    
    Ok(())
}
