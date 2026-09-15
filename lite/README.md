# AstroMuninn Lite

AstroMuninn Lite is the desktop edition of AstroMuninn for organizing
astrophotography capture files into a deterministic destination structure based
on FITS and XISF metadata.

Lite is built on the same shared Rust core as the AstroMuninn CLI, but it is
delivered as a desktop application rather than a command-line binary.

Quick install:

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.ps1 | iex
```

## What Lite Includes

AstroMuninn Lite currently includes:

- source and destination folder selection
- copy and move operation modes
- scan and preview planning
- tree, file list, and inspector workflow
- user-resizable file-list columns
- monitor mode for newly arriving files
- template validation and template save/update
- warning and error surfacing before execution
- partial execution that skips file-specific blocking rows while leaving valid
  files free to continue

Monitor mode also handles supported files present at startup. It waits for an
elapsed quiet period and performs read-only structural validation by default;
optional full validation and finite resource caps are configured in the shared
`config.json`. Cancelling stops admission of new work, while an already-started
Copy/Move may settle safely before the session returns to idle. After a terminal
unavailable/full destination error, correct the destination and start a new
session; an ordinary missing directory may instead be recreated.

Windows 11 Pro x86-64 manual acceptance covers the installer, launch, local
folder selection, FITS/XISF, Copy, Move, cancellation, restart, responsiveness,
and data integrity. NAS/SMB, disconnected removable storage, real disk-full
behavior, and every Windows storage topology remain unverified.

## Documentation

- [Lite install guide](INSTALL.md)
- [Lite user manual](UserManual.md)

## Release Artifacts

Lite release assets are published as:

- macOS Apple Silicon: `.dmg`
- Windows x86_64: installer `.exe`
- Linux x86_64: `.AppImage`

## Early-Adopter Note

Until Lite desktop signing and notarization are enabled:

- macOS may require Gatekeeper override steps
- Windows may show SmartScreen warnings

Those steps are documented in [INSTALL.md](INSTALL.md).
