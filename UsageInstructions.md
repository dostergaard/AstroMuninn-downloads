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

# Preview monitor decisions without copying or moving files
astromuninn --monitor /path/to/live/capture --destination /path/to/organized --dry-run
```

Monitor mode includes supported files already present at startup and new FITS or
XISF arrivals. Files must remain unchanged for the configured quiet period and
pass read-only validation before organization. Structural validation is the
default; full payload/checksum validation is optional in `config.json`.

`Ctrl+C` closes admission of new work and cooperatively cancels validation. A
Copy or Move already in progress may settle safely before cancellation completes.
If a genuinely unavailable/full destination aborts the session, correct or
reselect the destination and start a new monitor session. Ordinary missing
directories may be recreated by the normal workflow.

---

## Command Line Options

```
Options:
  -s, --source <SOURCE>            Source directory containing astrophotography images
      --monitor <MONITOR_DIR>      Monitor a directory continuously and process new files as they appear
  -d, --destination <DESTINATION>  Destination directory for organized images
  -c, --copy                       Copy files instead of moving them
  -n, --dry-run                    Dry run (don't actually move/copy files)
  -p, --nina-path <NINA_PATH>      Use NINA path template for organizing files
  -q, --silent                     Run silently (no output except errors)
  -f, --config <CONFIG>            Path to configuration file (default: ~/.config/astromuninn/config.json)
  -h, --help                       Print help
  -V, --version                    Print version
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
  "nina_path_template": "$$TARGETNAME$$\\$$DATE$$\\$$FILTER$$",
  "monitor": {
    "poll_interval_seconds": 10,
    "quiet_period_seconds": 5,
    "validation_timeout_seconds": 300,
    "full_validation": false,
    "validation_limits": {
      "max_header_bytes": 67108864,
      "max_working_bytes": 268435456,
      "max_structures": 100000,
      "max_decoded_bytes": 68719476736
    },
    "resources": {
      "mode": "auto",
      "max_working_bytes": 268435456,
      "max_worker_threads": null,
      "max_in_flight_files": null,
      "max_readers_per_volume": null,
      "max_writers_per_volume": null,
      "max_queued_files": null
    }
  }
}
```

Missing monitor fields use backward-compatible defaults. With automatic caps,
the finite fallbacks are at most 4 workers, equal in-flight capacity, 2 readers
and 1 writer per observed volume, active/queue capacity 128, and 256 MiB of
aggregate managed memory. If CPU availability cannot be observed, the worker
fallback is 2. These are conservative defaults, not universal hardware
recommendations. Active scheduling state is bounded separately from handled
history, so a session can process far more than 128 files. Config changes are
snapshotted when a monitor starts and take effect after starting a new session.

The validated release baseline uses local storage. NAS/SMB, disconnected
removable storage, real disk-full behavior, and every Windows storage topology
have not received manual acceptance.

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
