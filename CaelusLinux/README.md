# Caelus Linux Bootstrapper

Simple Linux bootstrapper for Caelus. Downloads CaelusLauncher.exe and runs it with Wine.

## Quick Start (Simple Method)

Just run the simple installer:

```bash
# Download and run the simple installer
bash simple-install.sh
```

That's it! It will:
- Check Wine installation and version
- Install required Wine components (vcrun2019, dotnet48, msxml6, corefonts)
- Download CaelusLauncher.exe from GitHub releases
- Install it to `~/.caelus/`
- Launch it with Wine

## Requirements

- **Wine 8.0 or later**: Required for best compatibility
- **Winetricks**: For installing Wine components

### Install Wine

**Ubuntu/Debian (recommended - WineHQ):**
```bash
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -sc)/winehq-$(lsb_release -sc).sources
sudo apt update
sudo apt install --install-recommends winehq-stable winetricks
```

**Ubuntu/Debian (from repos - may be older):**
```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine64 wine32 winetricks
```

**Fedora (recommended - WineHQ):**
```bash
sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/$(rpm -E %fedora)/winehq.repo
sudo dnf install --allowerasing winehq-stable winetricks
```

**Fedora (from repos - may be older):**
```bash
sudo dnf install wine winetricks
```

**Arch:**
```bash
sudo pacman -S wine winetricks
```

## Wine Compatibility

**Minimum Wine version:** 8.0
**Recommended:** Wine 9.0 or later

If you're using an old version of Wine (like 11.0, 10.0, etc.), you may experience compatibility issues. Update Wine for better results.

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
wine_prefix = "~/.wine"
wine_mode = 1
enable_dxvk = true
launch_args = ""
```

## What It Does

1. Checks Wine installation and version
2. Installs required Wine components (vcrun2019, dotnet48, msxml6, corefonts)
3. Downloads CaelusLauncher.exe from GitHub releases
4. Installs it to `~/.caelus/`
5. Launches it using Wine
6. No complex setup needed

## Troubleshooting

### Wine not found
Install Wine using the commands above.

### Wine version too old
If you see warnings about Wine version being too old, update Wine:
```bash
# Ubuntu/Debian
sudo apt install --install-recommends winehq-stable

# Fedora
sudo dnf update wine

# Arch
sudo pacman -S wine
```

### Client won't launch
```bash
# Check Wine version
wine --version

# Check Wine prefix
WINEPREFIX=~/.wine winecfg

# Reinstall Wine components
winetricks vcrun2019 dotnet48 msxml6 corefonts
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
- Automatically installs required Wine components
- Simple and straightforward installation
- Based on the official Windows bootstrapper

## License

This project is part of the Caelus infrastructure.

---

Simple Caelus Linux bootstrapper
