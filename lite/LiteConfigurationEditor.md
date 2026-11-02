# Lite Configuration Editor

Open **Configuration** in the main window. Paths, Performance, Monitor and Image
Type Presets share one draft. Switching groups keeps edits. **Apply** validates,
saves and stays open; **OK** saves and closes. **Cancel** or Escape discards only
changes since the last successful Apply. Escape inside an inline mapping edit
cancels that row first. A failed save keeps the draft open with an explanation.

Stop active processing/monitoring before Apply. Settings affect subsequent
operations. Apply replaces the idle monitor coordinator, updates the main form
and marks its preview stale. Running work is never silently reconfigured.
The file is saved through a synced temporary file and atomic replacement;
cooperating writers share a lock and stale editor snapshots are rejected.
Directory sync after replacement is best effort. External editors that ignore
locks can still race; reopen the editor after changing the file externally.

## Paths and Monitor

Source and destination have native directory pickers. Blank defaults remain
unset. The Default Path Template preserves entered strings and separators;
`$$IMAGETYPE$$` still expands the image's IMAGETYP value. It does not select an
alternate template. Existing organization and filename behavior remain intact.

Monitor durations are positive whole seconds. Validation limits are separate
from Performance's aggregate resource allowance. Byte fields accept exact whole
bytes, KiB/MiB/GiB (case insensitive), or K/M/G as binary aliases: `64 MiB`, `64 M`
and `67108864` all mean 67,108,864 bytes. No fractional quantities are rounded.
Numbers must fit unsigned 64-bit integers. Untouched numbers are preserved by
Rust, including values beyond JavaScript's exact-number range.

## Performance

These parameters govern monitoring; one-shot Scan/Execute retain their existing
behavior. Blank optional controls preserve `null` (finite automatic settings).
Auto defaults use at most four available workers (fallback two), equal in-flight
capacity, two readers and one writer per volume, and 128 active queue entries.
Serial mode uses one worker, in-flight file, reader and writer. The 256 MiB default
aggregate allowance covers managed buffers, not total process RSS; per-validation
working memory cannot exceed it. All limits retain their existing runtime meaning.

Selecting Low, Medium or Maximum reuses a compatible stored profile and changes
only the draft. It never starts benchmarks. Manual edits are Custom; they do not
overwrite stored profiles. Missing/stale results leave current settings intact.
Profiles older than 90 days, with a different CPU count, or a different policy
version require an explicit new run. This cannot detect every environmental change.

**Run Benchmarks** always shows **Start Benchmarks / Cancel** first. Run when the
computer is otherwise idle. Benchmarks use only synthetic files in owned temporary
directories and never read acquisition images. They can increase CPU, memory and
disk activity. Cancel waits for worker cleanup; blocked OS reads can delay return.
Apply/OK are unavailable while discovery or benchmarking runs.

Policy v1 reuses the pinned astro-bench 0.6.1 library's fixture generator and
full-validation measurements: eight 1024×1024 UInt16 FITS files, then Zstd XISF,
three passes at tested 1/2/4 worker counts. At most half the observed CPUs and four
workers are tested; a higher count requires 10% incremental median throughput
benefit. Low uses one worker, Medium a tested count at most half Maximum rounded
up. Profiles may coincide when extra workers provide no measured benefit.

The run uses at most 32 MiB scratch at once and requests cooperative cancellation
after 60 seconds. For this recipe, library admission estimates are below 90 MiB;
its validator reservation ceiling is 512 MiB. These are not hard process-memory
or wall-clock guarantees. Memory/reader/writer/queue settings retain conservative
existing bounds; they are **not measured host capacities**. Measurements are likely
warm-cache and omit real archive I/O, copying, metadata extraction, available-memory
pressure and foreground responsiveness. Profiles are bounded recommendations, not
throughput guarantees. Results remain draft until Apply/OK; failure/cancellation
retains prior results. Version/date/CPU/coverage and compact timing provenance are
stored, never private paths or raw per-file logs.

## Image Type Presets

Mappings are **saved for future use and do not control destination routing**.
Add/Edit uses exact IMAGETYP strings and existing template tokens. Manual entry
works without scanning; discovered values are suggestions. Empty keys/templates
and exact duplicate keys are rejected; case/whitespace are otherwise preserved.
Enter or Save row commits an inline edit to the draft; Escape/Cancel row discards
it. Remove changes only the draft; dialog Cancel can discard unapplied removals.
Finish or cancel a row edit before Apply.

Opening shows applicable cached values without reading images, labeled freshness
unchecked. **Scan** reuses the ordinary recursive inventory and metadata reader
for FITS/FIT/FTS, tiled-compressed `.fz`, and XISF files. Unchanged
preview/discovery records are reused using file
identity, size and modification time; missing/changed records are read once.
New/deleted files and draft-source changes are accounted for. Unsupported
extensions follow normal preview exclusion. Traversal/metadata errors or files
changing during reads produce a partial result with counts. Missing IMAGETYP is
reported. Suggestions never create mappings automatically.

Discovery owns a separate cancellation handle and snapshot; it cannot cancel or
mutate a copy/move preview. It performs one metadata read at a time and retains an
inventory proportional to the source, like preview. Timestamps are a freshness
heuristic, not content hashes; timestamp-preserving external mutations and changes
after a scan remain possible. No live filesystem snapshot is claimed.

## Schema changes relative to specification §8.1

```diff
- "nina_path_template": "<existing string>"
+ "default_path_template": "<identical string>"
+ "image_type_presets": [{"image_type":"LIGHT","path_template":"$$IMAGETYPE$$"}]
+ "benchmark_profiles": {
+   "version": 1,
+   "generated_unix_seconds": 0,
+   "host_parallelism": 8,
+   "coverage": "<workload, timings, provenance and limitations>",
+   "low": {"<same field names as monitor.resources>": "<values>"},
+   "medium": {"<same field names as monitor.resources>": "<values>"},
+   "maximum": {"<same field names as monitor.resources>": "<values>"}
+ }
```

The diff illustrates the two optional additions; example timestamp/values are not
measurements. Empty mappings and absent profiles are omitted on serialization.
There is no new root schema version or selected-profile field. `monitor.resources`
remains the only active resource configuration. Legacy template input loads
without rewriting the file; dual template keys (even null) are rejected. Successful
save emits only the canonical key. Other baseline values, nulls, target patterns,
organization and unknown JSON keys survive unrelated edits. Saves use deterministic
pretty JSON, so whitespace/key order are not preserved. Read-only open/Cancel does
not write configuration; temporary caches and progress are never persisted.
