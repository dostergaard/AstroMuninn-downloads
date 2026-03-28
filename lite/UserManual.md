# AstroMuninn Lite User Manual

Welcome to AstroMuninn Lite, the free for personal use GUI version of the AstroMuninn command line astrophotography image organization tool.

## Why AstroMuninn?

Astrophotography generates thousands of files across multiple nights, targets, filters, cameras, and telescope configurations. Without a consistent storage strategy, sessions become fragmented across disks, shares, and backup volumes. Over time, it becomes surprisingly easy to forget where the data for a particular target actually lives.

AstroMuninn helps you remember.

It does not invent an organizational philosophy for you — unless the simple default hierarchy meets your needs. Instead, it gives you the tools to implement **your** strategy using metadata-driven organization and N.I.N.A.-compatible path templates.

The result is a deterministic, repeatable folder structure built from the image file headers themselves — not from inconsistent filenames.

AstroMuninn:

- Reads metadata directly from your image files
- Understands FITS and XISF formats
- Supports N.I.N.A. path templates
- Handles real-world edge cases (e.g., telescope vs mount naming differences)
- Produces clean, consistent directory structures

It is built on top of the open-source **ravensky-astro** Rust libraries.

## The Name

Huginn and Muninn are the two ravens of Odin in Norse mythology. Their names mean *thought* (Huginn) and *memory* (Muninn). Each day they fly across the world and return with knowledge.

AstroMuninn serves a similar role in your observatory workflow:
it gathers what your imaging sessions already know and ensures that knowledge is not lost in your storage hierarchy.

RavenSky Observatory builds tools around this theme.

Huginn thinks. Muninn remembers.

## Overview

AstroMuninn Lite is the desktop edition of AstroMuninn for organizing
astrophotography capture files into a consistent destination folder structure
based on metadata stored in FITS and XISF files.

Lite is built for a review-first workflow:

1. choose a source directory
2. choose a destination directory
3. scan the source and preview the planned result
4. review warnings, plan-wide blocking issues, file-specific errors, and
   resolved destination paths
5. execute a copy or move when the plan looks correct, knowing Lite can skip
   file-specific blocking rows when valid files remain

## Supported Files

AstroMuninn Lite currently supports:

- FITS files: `.fits`, `.fit`, `.fts`
- XISF files: `.xisf`

Unsupported files are ignored during scan and monitor operations.

## Before You Start

You will usually need:

- a source folder containing supported astrophotography files
- a destination folder where AstroMuninn Lite can create directories and copy or
  move files
- a valid AstroMuninn path template

The default template is loaded from the shared AstroMuninn configuration. If
you already use the CLI, Lite will read the same saved template.

## Main Window Tour

### Header Bar

The header shows:

- the AstroMuninn Lite identity and RavenSky branding
- `Space required`
- `Space available`
- `Warnings`
- `Errors`
- the theme toggle

The header counts summarize the current scan or execution state. Use them as a
signal to inspect the lower panes for specific files and folders that need
attention.

### Source And Destination

Use the `Source` field to select the folder AstroMuninn Lite should read. `Source` can be any existing local folder or sub-folder to which the user has read permission. Sub-folders where read permissions are denied will be skipped. On **macOS** and **Linux**, AstroMuninn Lite can scan an entire file system starting from the root directory, including any locally attached storage devices. Network file shares have not been tested but may work if access permissions permit. Because of **Windows** use of drive letters to identify different storage devices, AstroMuninn Lite can only scan one drive at a time.

Use the `Destination` field to select the root folder where AstroMuninn Lite will build the organized directory structure. Again, the user must have appropriate access to the destination to create sub-folders and files.

You can type paths directly or use the `Browse` buttons.

### Operation Mode

AstroMuninn Lite supports two operation modes:

- `Copy`: leave the original files in the source folder and copy them into the
  organized destination structure
- `Move`: relocate the files from the source folder into the organized
  destination structure

Choose the mode before scanning so the preview reflects the intended operation.

### Actions

The action buttons are:

- `Scan`: recursively scan the source and build a preview plan
- `Execute`: apply the current scan plan
- `Monitor`: watch the source folder for newly written files and organize them
  as they become stable enough to process
- `Cancel`: stop the currently active scan, execute, or monitor task

`Execute` is only available when there is a current valid scan plan.
More specifically, the plan must still match the current form values, at least
one file must remain processable, and no blocking plan-wide issues can remain.

`Monitor` does not require a pre-scan plan and can start against an empty source
folder.

### Template

The `Template` field contains the AstroMuninn path template used to build the
destination hierarchy.

Use `Update Config` to save the current template back to the shared AstroMuninn
configuration.

Important notes:

- the template field is a plain text input in Lite
- Lite validates supported AstroMuninn tokens
- unsupported tokens are treated as errors
- the GUI preview is the dry run, so Lite does not include a separate dry-run
  toggle

### Tree

The `Tree` pane shows the computed destination hierarchy, not the raw source
folder structure.

Important behaviors:

- the tree contains directory nodes only
- files appear in the `File List` pane for the selected node or branch
- warning markers identify nodes that contain one or more warning conditions in
  that subtree

### File List

The `File List` pane shows the files associated with the selected tree node or branch.

It includes columns for:

- `File Name`
- `Target`
- `Observation / Session Date`
- `Status`

Click a column header to sort the list.

You can also drag the column dividers in the header to resize the list columns.
Long values wrap within the resized column so you can keep `Status` and the
other columns visible while reviewing a mixed set.

### Inspector

The `Inspector` pane shows details for the selected file, including:

- source path
- resolved destination path
- status and issue details
- raw metadata AstroMuninn read from the file

The inspector is intended as a troubleshooting and verification view, not a
full image-analysis tool.

## Standard Scan And Execute Workflow

Use this workflow for normal batch organization.

### 1. Select Source And Destination

Set the `Source` and `Destination` paths using the text fields or `Browse`
buttons.

### 2. Choose Copy Or Move

Set `Operation` to `Copy` or `Move`.

### 3. Confirm The Template

Review the `Template` field.

If you change it and want the new value saved for later sessions, click
`Update Config`.

### 4. Click Scan

Click `Scan` to build the plan.

AstroMuninn Lite will:

- scan the source recursively
- identify supported files
- read metadata from FITS and XISF files
- resolve destination paths from the template
- calculate warnings and errors
- build the tree, file list, and inspector data

### 5. Review The Plan

Before executing, review:

- `Warnings` and `Errors` in the header
- highlighted files in `File List`
- warning-marked folders in `Tree`
- detailed metadata and path resolution in `Inspector`
- the `Plan Issues` panel if it appears

Typical things to check:

- destination conflicts
- unreadable or corrupt metadata
- unsupported tokens in the template
- unexpected targets, dates, or camera values
- unexpected destination paths

Important phase-1 behavior:

- file-specific metadata or destination-path errors do not necessarily disable
  `Execute` if other files remain valid
- blocking template or plan-wide feasibility issues still disable `Execute`
- `Destination exists` is warning-only, but proceeding without changing the
  plan will overwrite the existing destination file

### 6. Click Execute

Click `Execute` when you are satisfied with the plan.

If the current plan still contains one or more valid files, Lite executes those
files and leaves file-specific blocking rows untouched. This phase does not yet
offer an in-app routing action for those blocked files.

During execution:

- the status line updates
- file row status updates as files are processed
- warnings and errors remain visible
- the app stays responsive

When execution finishes, verify the destination contents before deleting any
backups or source data.

## Monitor Workflow

Use `Monitor` when another application is writing files into a source folder and
you want AstroMuninn Lite to organize them automatically as they arrive.

Recommended monitor workflow:

1. set `Source` to the live capture or ingest folder
2. set `Destination` to the archive root
3. choose `Copy` or `Move`
4. confirm the template
5. click `Monitor`

Monitor behavior:

- the source folder may be empty when monitor starts
- AstroMuninn Lite waits for files to become stable enough to process
- if files already exist in the source directory, AstroMuninn Lite will
 immediately process those files then wait for new files to arrive
- the tree and file list populate as new files are discovered and organized
- `Cancel` stops the active monitor session
- you can restart monitor later against the same folders

## Warnings, Errors, And Status

### Warnings

Warnings indicate risk or a condition that deserves user review but may not
block processing.

Typical warning:

- `Destination exists`

Warnings appear in more than one place:

- header warning count
- tree warning marker
- file status text in the file list

Warnings do not necessarily block `Execute`. A destination-exists warning means
the resolved destination file is already present, and continuing with the
current plan will overwrite it.

### Errors

Errors indicate that a file or template cannot be processed correctly with the
current inputs.

Typical errors include:

- unsupported template token
- unreadable or corrupt metadata
- a destination path that cannot be resolved from the available metadata

File-specific errors leave the affected rows unprocessable. If other valid
files remain, `Execute` can still continue and will leave the errored files
untouched.

Plan-wide blocking issues, such as unsupported template tokens or insufficient
destination space, still prevent `Execute` until the problem is resolved.

### Status Line

The status line in the `Actions` section shows the current high-level state,
such as:

- loading configuration
- scanning
- monitoring
- cancellation requested
- execution complete
- error details

## Theme And About Window

AstroMuninn Lite follows the operating system light or dark theme by default
unless you have already changed it inside the app.

Use the theme button in the header to toggle between light and dark modes.

The About window is available from the application menu:

- macOS: `AstroMuninn Lite > About AstroMuninn Lite`
- Windows and Linux: `Help > About AstroMuninn Lite`

## Configuration Behavior

AstroMuninn Lite shares configuration with the AstroMuninn CLI.

AstroMuninn Lite automatically creates the shared AstroMuninn configuration file on first launch if one does not already exist.

Config file locations based on platform:

- macOS: `~/Library/Application Support/astromuninn/config.json`
- Linux: `$XDG_CONFIG_HOME/astromuninn/config.json`
- Linux default if XDG_CONFIG_HOME is unset: `~/.config/astromuninn/config.json`
- Windows: `%APPDATA%\astromuninn\config.json`
- Windows typical expanded path: `C:\Users\<username>\AppData\Roaming\astromuninn\config.json`

At this stage, Lite directly updates the saved N.I.N.A.-style path template
through the `Update Config` button. Other shared configuration behavior follows
the core AstroMuninn configuration system.

## What Lite Intentionally Does Not Include

AstroMuninn Lite is intentionally limited to the current Lite scope.

It does not currently include:

- a token builder UI
- an enhanced template editor
- real-time tree recomputation while typing in the template field
- exclusion pattern controls

These are either intentionally deferred or reserved for future product
differentiation.

## Troubleshooting

### Execute Is Disabled

Possible reasons:

- source or destination is missing
- no valid scan has been run yet
- the scan is out of date because you changed the source, destination, template,
  or operation mode
- the current plan contains blocking plan-wide issues
- the current plan no longer contains any executable files

Fix:

1. confirm source and destination
2. resolve template or other blocking plan issues, or adjust the plan until at
   least one file is executable
3. run `Scan` again

### Monitor Starts But Nothing Appears

This is normal if the source folder is empty.

While monitor is active, AstroMuninn Lite waits for newly written FITS or XISF
files to arrive and stabilize before processing them.

### Destination Exists Warnings Appear

AstroMuninn Lite found one or more files whose resolved destination path already
exists.

Review the affected rows and folders before executing. `Execute` may still stay
enabled if other files are processable, but proceeding with the current plan
will overwrite the existing destination file.

### A File Shows Metadata Errors

The file may be:

- corrupt
- incomplete
- not actually a valid FITS or XISF file
- missing enough required metadata that the destination path cannot be resolved

Select the file and review the `Inspector` details.

If other files in the scan remain valid, you can still execute the rest of the
plan. Lite will leave the errored file untouched.

### The Template Is Rejected

Lite only accepts AstroMuninn-supported tokens. A token supported by another
tool is not automatically supported in AstroMuninn Lite.

Remove or replace unsupported tokens, then scan again.

## Practical Tips

- Start with `Copy` if you are testing a new template.
- Use `Scan` after any path, mode, or template change.
- Review warnings before every execute pass.
- Use the file-list column resize handles when long filenames crowd the
  `Status` column.
- Use `Monitor` for live capture or ingest folders that may start empty.
- Use the inspector to confirm exactly how a file was interpreted before moving
  a large dataset.

## Related Documents

- Supported AstroMuninn tokens: `docs/Supported_NINA_Tokens.md`

## Support & Contributions

AstroMuninn is developed and maintained as a personal project under **RavenSky Observatory**.

**RavenSky Observatory** is currently my backyard and a single small telescope. The name was inspired by the story of Odin's two Ravens, Huginn *(thought)* and Muninn *(memory)*, because every morning after I have run imaging sessions, I awake to new data and images bringing new information and inspiration about our amazing universe.

If AstroMuninn saves you time or helps you keep your imaging archive organized, consider supporting its development with a small donation.

Donations help cover development time, testing hardware, and hosting costs.

If you would like, please check out ways that you can donate on [Buy Me a Coffee](https://buymeacoffee.com/ravenskyobservatory)

Thank you to everyone who helps keep the project moving forward.
