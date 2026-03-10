# AstroMuninn Downloads

Public binary distribution repository for **AstroMuninn**, published by **RavenSky Observatories**.

This repository intentionally contains:

- Release assets for supported platforms
- `SHA256SUMS.txt` checksum files
- Download and install instructions
- Public release notes

This repository intentionally does **not** contain the AstroMuninn source code.

## Downloads

Download compiled binaries from the [Releases](../../releases) page.

Current supported targets:

- macOS Apple Silicon
- Windows x86_64 (MinGW)
- Linux x86_64

## Verify Downloads

Each release includes a `SHA256SUMS.txt` file.

Examples:

```bash
shasum -a 256 -c SHA256SUMS.txt
```

```powershell
Get-FileHash .\AstroMuninn-v0.9.1-windows-x86_64.zip -Algorithm SHA256
```

## Install

See [INSTALL.md](INSTALL.md) for platform-specific usage notes.
