# Caelus Linux Bootstrapper

Simple Linux bootstrapper for Caelus. Now features a custom native APK runtime (inspired by Sober) for running Caelus Android APK on Linux without Flatpak.

## Quick Start (One-Command Setup)

```bash
# Run the automatic setup - everything is configured for you
bash setup.sh

# Download the Caelus APK from the official source
# Place it in the required location
cp your-caelus.apk ~/.caelus/apk-runtime/apk/caelus.apk

# Run Caelus
./target/release/caelus-bootstrapper
```

That's it! The setup script automatically:
- Installs Rust if needed
- Creates all required directories
- Configures everything for you
- Builds the bootstrapper
- Everything is pre-configured and ready to run

**Note**: The Caelus APK file is NOT included in this repository due to GitHub size limits. You must download it from the official source and place it in the designated directory.

### Legacy Methods

The old Wine-based method and manual APK setup have been moved to `OldLinuxStuff/` for reference.

## Requirements

- **Rust**: Required to build the native APK runtime
- **Caelus APK**: The Android APK file for Caelus

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

## Advanced Method (Rust Build)

```bash
# Build
cargo build --release

# Run
./target/release/caelus-bootstrapper
```

## Configuration

Edit `~/.caelus/config.toml`:

```toml
client_url = "https://github.com/caelusinfra/windows-bootstrapper/releases/download/v2026.03.29.1453/CaelusLauncher.exe"
install_dir = "~/.caelus"
wine_prefix = "~/.caelus/wine"
wine_mode = 1
enable_dxvk = true
launch_args = ""
```

## Native APK Runtime

Inspired by [Sober](https://sober.vinegarhq.org), this bootstrapper features a custom native APK runtime for running Caelus Android APK on Linux without Flatpak dependencies.

### Setup Native APK Runtime

```bash
# Run the APK installer
bash apk-install.sh

# Place your Caelus APK in the required location
cp your-caelus.apk ~/.caelus/apk-runtime/apk/caelus.apk

# Build and run the Rust bootstrapper
cargo build --release
./target/release/caelus-bootstrapper
```

### Native Runtime Structure

```
~/.caelus/
├── apk-runtime/
│   ├── apk/          # Place Caelus APK here
│   ├── libs/         # Extracted native libraries
│   ├── cache/        # Cached APK data
│   └── config/       # Runtime configuration files
└── config.toml       # Main configuration (set use_apk_runtime = true)
```

### Configuration

Edit `~/.caelus/config.toml`:

```toml
use_apk_runtime = true
apk_path = "~/.caelus/apk-runtime/apk/caelus.apk"
```

### How It Works

The native APK runtime:
1. Extracts the Caelus APK to a cache directory
2. Extracts native libraries (.so files) for Linux compatibility
3. Sets up a custom runtime environment
4. Configures library paths and environment variables
5. Provides a framework for native Android app execution on Linux

This approach avoids Flatpak sandboxing and creates a specialized runtime environment similar to Sober's approach for Roblox.

### Using caelus:// URIs

After installation, you can join games using caelus:// URIs:

```bash
# Example: Join a specific game
caelus://launchmode:play+placeId:123456+universeId:789012

# The launcher will parse these parameters and pass them to CaelusLauncher.exe
```

## Troubleshooting

### Wine not found
Install Wine using the commands above.

### Client won't launch
```bash
# Check Wine version
wine --version

# Check Wine prefix
winecfg
```

### Download failed
Check your internet connection and the GitHub URL in config.toml.

### Wine errors (fixme, err messages)
Some Wine errors are normal and don't prevent the application from running. If the launcher doesn't work:
1. Update Wine to the latest version
2. Try using Proton (Steam's Wine fork) if available
3. Check Wine AppDB for known issues

## Project Structure

```
.
├── Cargo.toml              # Rust project configuration
├── config.toml            # Configuration
├── simple-install.sh      # Simple bash installer
├── src/
│   └── main.rs           # Rust bootstrapper code
└── README.md             # This file
```

## Notes

- Downloads CaelusLauncher.exe from official GitHub releases
- Uses Wine to run the Windows launcher on Linux
- Simple and straightforward installation
- Based on the official Windows bootstrapper

## License

This project is part of the Caelus infrastructure.

---

Simple Caelus Linux bootstrapper
