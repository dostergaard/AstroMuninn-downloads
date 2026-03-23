# AstroMuninn CLI Usage

This page covers the AstroMuninn CLI product.

For the desktop app, see:

- [lite/README.md](lite/README.md)
- [lite/UserManual.md](lite/UserManual.md)

## Basic Usage

```bash
# Move files
astromuninn --source /path/to/images --destination /path/to/organized

# Copy instead of move
astromuninn --source /path/to/images --destination /path/to/organized --copy

# Dry run
astromuninn --source /path/to/images --destination /path/to/organized --dry-run
```

### Monitor Mode

```bash
# Monitor a live capture directory until stopped (Ctrl-C)
astromuninn --monitor /path/to/live/capture --destination /path/to/organized
```

---

## Command Line Options

```
Options:
  -s, --source <SOURCE_DIR>       Source directory containing astrophotography images
      --monitor <MONITOR_DIR>     Monitor directory for new astrophotography files
  -d, --destination <DEST_DIR>    Destination directory for organized images
  -c, --copy                      Copy files instead of moving them
  -n, --dry-run                   Don't actually move/copy files (preview only)
  -p, --nina-path <TEMPLATE>      Use NINA path template for organizing files
  -q, --silent                    Run silently (no output except errors)
  -f, --config <CONFIG_FILE>      Path to configuration file
```

Notes:

* Use either `--source` or `--monitor` (not both).
* In monitor mode, the monitor directory must already exist.
* Monitor mode runs continuously until interrupted.

---

## Configuration

Running the tool without arguments generates a default config file:

* Linux: `~/.config/astromuninn/config.json`
* macOS: `~/Library/Application Support/astromuninn/config.json`
* Windows: `%APPDATA%\astromuninn\config.json`

Example configuration:

```json
{
  "organization": {
    "primary_group": "Target",
    "secondary_group": "Date",
    "tertiary_group": "Filter"
  },
  "nina_path_template": "$TARGETNAME$\\$DATE$\\$FILTER$"
}
```

---

## Example Output Structure

```
destination/
├── M31/
│   ├── 2025-01-14/
│   │   └── Luminance/
│   │       └── M31_L_300s_001.fits
```

---

## Real-World Scenarios

### Reorganizing Historical Archives

Point AstroMuninn at a legacy archive and let it walk the entire directory tree. It will locate FITS and XISF files and rebuild a clean, structured hierarchy based solely on metadata extracted from the headers.

This is particularly useful when:

* File names are inconsistent
* Sessions were copied between drives
* Targets were renamed over time
* Directory structures drifted

### Recovering "Lost" Files

AstroMuninn does not depend on filenames. If you have FITS or XISF files buried somewhere in a drive tree, it can locate them and place them correctly in your structured hierarchy.

---

## Naming Standards And Conventions

AstroMuninn builds folder structures from metadata embedded in your images. Consistent naming conventions produce better results.

For example, AstroMuninn cannot infer that:

* `M 31`
* `Messier 31`
* `Andromeda Galaxy`
* `M31`

all refer to the same target, at least not yet.

Likewise, different capture software populates metadata differently:

* N.I.N.A. uses the Telescope field from your profile.
* ASIAIR may populate the `TELESCOP` keyword with the mount name.
* Other software may use different conventions.

Understanding how your capture software writes metadata will help you design a predictable organization strategy.
