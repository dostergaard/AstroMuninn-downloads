# Install AstroMuninn CLI

This page covers the AstroMuninn CLI product.

For AstroMuninn Lite desktop installation, see:

- [lite/INSTALL.md](lite/INSTALL.md)

## Recommended Commands

macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.ps1 | iex
```

To install a specific release, pass a version:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.sh | bash -s -- --version vX.Y.Z
```

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.ps1))) -Version vX.Y.Z
```

## macOS Apple Silicon

The shell installer:

1. Detects macOS Apple Silicon and resolves the latest or requested release.
2. Downloads `AstroMuninn-vX.Y.Z-macos-apple-silicon.tar.gz` and `SHA256SUMS.txt`.
3. Verifies the SHA256 checksum.
4. Installs `astromuninn` into `~/.local/bin` by default.
5. Adds `~/.local/bin` to your shell PATH if needed.

Because the installer uses `curl` instead of a browser download, it generally
avoids the normal macOS browser quarantine friction that applies to desktop app
downloads. AstroMuninn CLI is still unsigned, so you should document that
honestly for users.

## Windows x86_64

The PowerShell installer:

1. Resolves the latest or requested release.
2. Downloads `AstroMuninn-vX.Y.Z-windows-x86_64.zip` and `SHA256SUMS.txt`.
3. Verifies the SHA256 checksum.
4. Extracts and installs `astromuninn.exe` into `%LOCALAPPDATA%\RavenSky\AstroMuninn\bin`.
5. Adds that directory to the user PATH if needed.
6. Uses `Unblock-File` where available to reduce Windows download friction.

AstroMuninn is still unsigned, so Windows Defender SmartScreen or antivirus tooling may still present warnings depending on the user environment.

## Linux x86_64

The shell installer:

1. Detects Linux x86_64 and resolves the latest or requested release.
2. Downloads `AstroMuninn-vX.Y.Z-linux-x86_64.tar.gz` and `SHA256SUMS.txt`.
3. Verifies the SHA256 checksum.
4. Installs `astromuninn` into `~/.local/bin` by default.
5. Adds `~/.local/bin` to your shell PATH if needed.

## Homebrew

This repository also acts as a custom Homebrew tap:

```bash
brew tap dostergaard/AstroMuninn-downloads https://github.com/dostergaard/AstroMuninn-downloads
brew install astromuninn
```

The Homebrew formula is generated from the public release checksums and updated on each public release.

## Verify the Archive

Use the matching `SHA256SUMS.txt` file shipped with each release.

## Update And Reinstall

- macOS / Linux: rerun the install command. Existing binaries are replaced in place.
- Windows: rerun the PowerShell installer. Existing binaries are replaced in place.
- Homebrew: `brew upgrade astromuninn`

## Uninstall

- macOS / Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.sh | bash -s -- --uninstall
```

- Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/install.ps1))) -Uninstall
```

- Homebrew:

```bash
brew uninstall astromuninn
```

## Troubleshooting

- `unsupported operating system` or `unsupported architecture`: AstroMuninn currently ships macOS Apple Silicon, Windows x86_64, and Linux x86_64 binaries only.
- `SHA256 mismatch`: retry the install. If it persists, stop and investigate before running the binary.
- `command not found` after install: open a new shell or ensure the installer-added PATH entry has been loaded.
- browser-download warnings on macOS: prefer the `curl` installer path instead of downloading the archive manually.
