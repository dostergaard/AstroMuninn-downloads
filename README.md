# AstroMuninn Downloads

Public binary distribution repository for **AstroMuninn**, published by
**RavenSky Observatory**.

This repository is the public downloads hub for:

- AstroMuninn CLI
- AstroMuninn Lite

It contains:

- release assets for supported platforms
- `SHA256SUMS.txt` checksum files
- stable metadata files for installers and release consumers
- public install and usage documentation
- public release notes

Source code is not published in this repository.

## Products

### AstroMuninn CLI

The CLI is the most automation-friendly AstroMuninn product and remains the
lowest-friction way to install AstroMuninn on macOS, Linux, and Windows.

Quick install:

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.ps1 | iex
```

CLI documentation:

- [CLI install guide](INSTALL.md)
- [CLI usage instructions](UsageInstructions.md)
- [CLI metadata feed](https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/latest.json)

### AstroMuninn Lite

AstroMuninn Lite is the desktop application built on the shared AstroMuninn
Rust core.

Quick install:

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.ps1 | iex
```

Lite documentation:

- [Lite overview](lite/README.md)
- [Lite install guide](lite/INSTALL.md)
- [Lite user manual](lite/UserManual.md)
- [Lite metadata feed](https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/latest.json)

Important note:

- Lite public releases may still require OS-specific security override steps
  until signing and notarization are enabled for the desktop app release line

## Current Supported Targets

### CLI

- macOS Apple Silicon
- Windows x86_64
- Linux x86_64

### Lite

- macOS Apple Silicon
- Windows x86_64
- Linux x86_64

## Checksums

Each public release includes a `SHA256SUMS.txt` file alongside its assets.

Verify downloads before running them whenever possible.

## Homebrew

The custom Homebrew tap in this repo currently applies to the CLI product:

```bash
brew tap dostergaard/AstroMuninn-downloads https://github.com/dostergaard/AstroMuninn-downloads
brew install astromuninn
```

## License

AstroMuninn binaries are licensed for personal / non-commercial use. See
[LICENSE](LICENSE) for the full license text.
