# Caelus Linux Bootstrapper

Simple Linux bootstrapper for Caelus. Downloads CaelusLauncher.exe and runs it with Wine.

## Quick Start (Simple Method)

Just run the simple installer:

```bash
# Download and run the simple installer
bash simple-install.sh
```

That's it! It will:
- Check Wine installation
- Download CaelusLauncher.exe from GitHub releases
- Install it to `~/.caelus/`
- Launch it with Wine

## Requirements

- **Wine**: Required to run Windows applications on Linux

### Install Wine

**Ubuntu/Debian:**
```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine64 wine32
```

**Fedora:**
```bash
sudo dnf install wine
```

**Arch:**
```bash
sudo pacman -S wine
```

## Advanced Method (Rust Build)

If you want to build from source:

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

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

## What It Does

1. Checks Wine installation
2. Downloads CaelusLauncher.exe from GitHub releases
3. Installs it to `~/.caelus/`
4. Launches it using Wine
5. No complex setup needed

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
