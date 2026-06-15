# Caelus Linux Bootstrapper

Simple Linux bootstrapper for Caelus. Now features a custom native APK runtime (inspired by Sober) for running Caelus Android APK on Linux without Flatpak.

## Quick Start (One-Command Setup)

```bash
# Run the automatic setup - everything is configured for you
bash setup.sh

# Download the Caelus APK from the official source
# Place it in the current directory structure
cp your-caelus.apk apk-runtime/apk/caelus.apk

# Run Caelus
./target/release/caelus-bootstrapper
```

That's it! The setup script automatically:
- Installs Rust if needed
- Creates all required directories in current folder
- Configures everything for you
- Builds the bootstrapper
- Everything is pre-configured and ready to run

**Note**: The Caelus APK file is NOT included in this repository due to GitHub size limits. You must download it from the official source and place it in `apk-runtime/apk/caelus.apk` in the current directory.

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
./ (current directory)
├── apk-runtime/
│   ├── apk/          # Place Caelus APK here (this IS the client)
│   ├── libs/         # Extracted native libraries
│   ├── cache/        # Cached APK data
│   └── config/       # Runtime configuration files
├── target/
│   └── release/
│       └── caelus-bootstrapper
└── setup.sh
```

### Configuration

The setup script automatically creates configuration. The APK path is set to the current directory structure:

```toml
use_apk_runtime = true
apk_path = "./apk-runtime/apk/caelus.apk"
```

The bootstrapper automatically checks for the APK in the current directory first, so you don't need to manually configure the path.

### How It Works

The native APK runtime (inspired by Sober):
1. **APK is the client**: The Caelus APK itself is the client, similar to how Sober runs Roblox from a modified APK
2. **Current directory setup**: Checks for APK in the current directory structure first
3. **Extracts native libraries**: Extracts .so files from the APK for Linux compatibility
4. **Sets up runtime environment**: Creates custom runtime configuration
5. **Configures library paths**: Sets up proper library paths and environment variables
6. **Creates launch script**: Generates a launch script to run the APK as the client

This approach avoids Flatpak sandboxing and creates a specialized runtime environment similar to Sober's approach for Roblox, where the APK itself serves as the client.

## Troubleshooting

### APK not found
Make sure you placed the Caelus APK in the correct location:
```bash
# Should be in current directory structure
ls apk-runtime/apk/caelus.apk
```

### Build errors
Make sure Rust is properly installed:
```bash
rustc --version
cargo --version
```

### Runtime issues
Check the generated launch script:
```bash
ls apk-runtime/launch-caelus.sh
```

### Download failed
Check your internet connection and the APK source.

## Project Structure

```
.
├── Cargo.toml              # Rust project configuration
├── setup.sh                # One-command setup script
├── src/
│   ├── main.rs           # Rust bootstrapper code
│   └── apk_runtime.rs    # APK runtime module
├── apk-runtime/           # APK runtime directory
│   ├── apk/              # Place Caelus APK here (this IS the client)
│   ├── libs/             # Extracted native libraries
│   ├── cache/            # Cached APK data
│   └── config/           # Runtime configuration files
├── OldLinuxStuff/         # Legacy Wine-based methods
└── .gitignore             # Git ignore file
```

## Notes

- APK runtime inspired by Sober for Roblox
- The APK itself is the client (like Sober runs Roblox from modified APK)
- Uses current directory structure for easy setup
- No Flatpak dependency - native Linux runtime
- Auto-configures on first run
- Extracts native libraries for Linux compatibility

## License

This project is part of the Caelus infrastructure.

---

Simple Caelus Linux bootstrapper
