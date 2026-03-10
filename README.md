# AstroMuninn Downloads

Public binary distribution repository for **AstroMuninn**, published by **RavenSky Observatories**.

This repository intentionally contains:

- Release assets for supported platforms
- `SHA256SUMS.txt` checksum files
- Download and install instructions
- Public release notes
- Stable installer entry points

This repository intentionally does **not** contain the AstroMuninn source code.

## Quick Install

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.ps1 | iex
```

## Downloads

Download compiled binaries from the [Releases](https://github.com/dostergaard/AstroMuninn-downloads/releases) page.

Current supported targets:

- macOS Apple Silicon
- Windows x86_64 (MinGW)
- Linux x86_64

The installers default to user-space locations:

- macOS / Linux: `~/.local/bin`
- Windows: `%LOCALAPPDATA%\RavenSky\AstroMuninn\bin`

They verify release checksums before installing.

## Verify Downloads

Each release includes a `SHA256SUMS.txt` file.

Examples:

```bash
shasum -a 256 -c SHA256SUMS.txt
```

```powershell
Get-FileHash .\AstroMuninn-v0.9.1-windows-x86_64.zip -Algorithm SHA256
```

## Homebrew

AstroMuninn provides a custom Homebrew tap from this repo after the first public release has been published:

```bash
brew tap dostergaard/AstroMuninn-downloads https://github.com/dostergaard/AstroMuninn-downloads
brew install astromuninn
```

Homebrew uses the public release assets from this repository.

## Install

See [INSTALL.md](INSTALL.md) for platform-specific usage notes.
