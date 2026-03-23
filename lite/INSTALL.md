# Install AstroMuninn Lite

## Important Early-Adopter Warning

AstroMuninn Lite is currently distributed as an unsigned desktop application.

That means:

- macOS Gatekeeper may block launch of a browser-downloaded `.dmg` or `.app`
- Windows Defender SmartScreen may warn before launch of a downloaded installer
- script-based installs can reduce some of that friction because they avoid or
  remove the browser-added download flags, but they do not make Lite signed or
  notarized

If you want the lowest-friction install path right now, use the copy-and-paste
install commands below instead of downloading the files manually in a browser.

## Quick Install Commands

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.sh | bash
```

Install a specific release:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.sh | bash -s -- --version lite-vX.Y.Z
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.ps1 | iex
```

Download a specific release and launch that installer:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.ps1))) -Version lite-vX.Y.Z
```

Download the installer without launching it:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.ps1))) -Version lite-vX.Y.Z -DownloadOnly
```

## What The Script Installers Do

### macOS

The shell installer:

1. resolves the latest Lite release or the version you requested
2. downloads the Lite `.dmg` with `curl`
3. verifies the checksum with `SHA256SUMS.txt`
4. mounts the disk image
5. copies `AstroMuninn Lite.app` into `~/Applications` by default
6. removes `com.apple.quarantine` from the installed app if it is present

You can override the default app location:

```bash
curl -fsSL https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/install.sh | bash -s -- --install-dir /Applications
```

### Windows

The PowerShell installer:

1. resolves the latest Lite release or the version you requested
2. downloads the Lite installer `.exe`
3. verifies the checksum with `SHA256SUMS.txt`
4. runs `Unblock-File` on the downloaded installer when available
5. launches the installer for you

### Linux

The shell installer:

1. resolves the latest Lite release or the version you requested
2. downloads the Lite `.AppImage` with `curl`
3. verifies the checksum with `SHA256SUMS.txt`
4. installs it to `~/.local/bin/astromuninn-lite` by default
5. marks it executable
6. adds `~/.local/bin` to your PATH if needed

## Direct Download And Manual Install

Use this path if you would rather inspect the package yourself before launching
or installing it.

## Platform Artifacts

- macOS Apple Silicon: `.dmg`
- Windows x86_64: installer `.exe`
- Linux x86_64: `.AppImage`

## macOS Apple Silicon Manual Install

Recommended artifact:

- `AstroMuninn-Lite-vX.Y.Z-macos-apple-silicon.dmg`

Manual install flow:

1. download the `.dmg`
2. open the `.dmg`
3. drag `AstroMuninn Lite.app` to `Applications`
4. eject the disk image
5. launch `AstroMuninn Lite.app` from `Applications`

If Gatekeeper blocks the app and you understand the risk, remove the quarantine
attribute from the installed app:

```bash
xattr -dr com.apple.quarantine "/Applications/AstroMuninn Lite.app"
```

If you copied the app somewhere other than `/Applications`, use that path
instead.

## Windows x86_64 Manual Install

Recommended artifact:

- `AstroMuninn-Lite-vX.Y.Z-windows-x86_64-setup.exe`

Manual install flow:

1. download the installer `.exe`
2. optionally remove the browser-added Mark-of-the-Web flag
3. launch the installer
4. follow the installer prompts
5. launch AstroMuninn Lite from the Start menu or desktop shortcut

PowerShell command to remove the browser-added block flag from the installer:

```powershell
Unblock-File -Path .\AstroMuninn-Lite-vX.Y.Z-windows-x86_64-setup.exe
```

Then launch it:

```powershell
.\AstroMuninn-Lite-vX.Y.Z-windows-x86_64-setup.exe
```

If SmartScreen still appears, that is because Lite is unsigned. The script and
`Unblock-File` steps reduce some friction, but they do not add a trusted code
signature.

## Linux x86_64 Manual Install

Recommended artifact:

- `AstroMuninn-Lite-vX.Y.Z-linux-x86_64.AppImage`

Manual install flow:

```bash
chmod +x AstroMuninn-Lite-vX.Y.Z-linux-x86_64.AppImage
./AstroMuninn-Lite-vX.Y.Z-linux-x86_64.AppImage
```

Or place it somewhere durable and rename it for easier launching:

```bash
mkdir -p ~/.local/bin
cp AstroMuninn-Lite-vX.Y.Z-linux-x86_64.AppImage ~/.local/bin/astromuninn-lite
chmod +x ~/.local/bin/astromuninn-lite
```

## Verify Downloads

Each release includes a `SHA256SUMS.txt` file. Verify the checksum before
launching the app when practical.

## Update And Reinstall

- macOS / Linux: rerun the shell install command
- Windows: rerun the PowerShell installer bootstrap command or download and run
  the newer installer directly

## Uninstall

AstroMuninn Lite is a desktop app, so uninstall is package-based rather than
binary-based.

- macOS: delete `AstroMuninn Lite.app` from `Applications`
- Windows: uninstall AstroMuninn Lite from Windows Settings / Installed Apps
- Linux AppImage: delete the AppImage you installed

Lite uses the shared AstroMuninn config file. Removing the app package does not
remove that shared config automatically.

## User Guidance

For actual application usage after installation, see:

- [Lite user manual](UserManual.md)
