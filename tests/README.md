# M03 regression tests

These tests exercise the production `main.nf` input-validation and batching path.
They use synthetic metadata and the 20 tiny, tracked FASTQs in `test_inputs/reads`.
They do not run inference or interpret fixture labels as biological evidence.

## Run in isolation

Verified tools: Nextflow 26.04.6 build 12646 and nf-test 0.9.5. The production
configuration pins nf-schema 2.7.3; that plugin must already be installed.
No additional nf-test plugins, containers, databases, or packages are required.

Run the following from the repository root:

```bash
m03_run=$(mktemp -d /tmp/m03-regression.XXXXXX)
M03_TEST_ROOT="$m03_run" NXF_OFFLINE=true \
    nf-test test tests/main.nf.test \
    --config nf-test.config \
    --log "$m03_run/nf-test.log" \
    --junitxml "$m03_run/junit.xml" --ci
m03_status=$?
printf 'Exit status: %s\nEvidence directory: %s\n' "$m03_status" "$m03_run"
exit "$m03_status"
```

Equivalent test invocation on one line, after creating `m03_run` above:

```bash
M03_TEST_ROOT="$m03_run" NXF_OFFLINE=true nf-test test tests/main.nf.test --config nf-test.config --log "$m03_run/nf-test.log" --junitxml "$m03_run/junit.xml" --ci; m03_status=$?; printf 'Exit status: %s\nEvidence directory: %s\n' "$m03_status" "$m03_run"; exit "$m03_status"
```

`M03_TEST_ROOT` selects the test work directory. Use a fresh directory for every
invocation; the configuration rejects an existing `nf-test` work directory.
Launch from the repository root: nf-test 0.9.5 discovers tests relative to its
launch directory even with an absolute `--config` path. The explicit `--log`
option protects the existing repository `.nf-test.log`. Each test
gets its own derived samplesheet, Nextflow launch/cache/work directories, logs,
and output directory below `$m03_run/nf-test`. Original FASTQs are only read;
derived sheets resolve their paths absolutely. `--ci` prevents automatic snapshot
creation, and the suite contains no snapshot assertions. `NXF_OFFLINE=true`
prevents Nextflow from downloading missing plugins. Keep the evidence directory
for review; these instructions do not perform cleanup.

## Assertions

The suite defines 23 independently runnable cases:

| Cases | Expected result |
| --- | --- |
| Canonical samplesheet | Six exact batch rows, 20 unique samples, sizes 2/2/2/2/6/6, correct metadata and membership |
| Reversed input rows | Same exact manifest bytes as the canonical case |
| Different markers in one dataset | Separate 16S and 18S batches |
| Same marker in different datasets | Separate R01 and R02 dataset batches |
| Mixed origins; mixed branches | Failure with the specific batch-validation diagnostic |
| Mixed stages in a simulated biological-processing batch | Success, sorted `analysis_ready,primer_present` stages |
| Biological origin with biological branch | Success with exact manifest metadata |
| Biological origin with controlled branch | Schema rejection with the cross-field diagnostic |
| Empty samplesheet | Schema rejection with a clear nonempty-sheet diagnostic |
| Invalid enum, one case per enum field (4) | Schema failure with the field's diagnostic |
| Missing required column, one case per column (7) | Validation failure identifying the missing field |
| Duplicate sample ID across datasets | Failure identifying the duplicated ID |
| Missing FASTQ | Failure with the FASTQ-path diagnostic |

All rejection cases also require a nonzero workflow exit status and no batch
manifest. Diagnostics are checked in captured stdout/stderr because nf-test
0.9.5 leaves `workflow.errorReport` empty for the observed Nextflow 26.04.6
batch-validation error. Positive cases compare complete UTF-8 bytes, including row ordering,
sample ordering, header, and final newline, against explicit expected strings
in the test source. Canonical and reversed runs use the same fixed expectation,
so both passing establishes byte equality without test-order dependence or
reading historical result files. These expectations are not generated from the
workflow's outputs or accepted through snapshots.

The suite tests a missing column separately for each required field; it does not
claim exhaustive coverage of blank cell representations or malformed CSV/TSV.
Full logs, generated input sheets, parameters, and outputs are retained under the
evidence directory. `junit.xml` records individual names, results, and timings.

## Remaining M03 decisions

- No additional cross-field origin/branch rules are implied beyond the approved compatibility policy; mixed input stages remain accepted.
- Retain the deterministic batch manifest and preserve the source samplesheet for the complete sample-to-FASTQ mapping; no separate input manifest is required for M03.
- Review test evidence before closing v0.3/M03; historical M0 closure is preserved.

The test DSL and isolation settings follow the [nf-test 0.9.5 configuration
source](https://github.com/askimed/nf-test/blob/v0.9.5/docs/docs/configuration.md)
and the installed pipeline-test implementation. The production samplesheet schema
was updated to reject `biological + controlled` and empty samplesheets; the
workflow, fixtures, and historical milestone documents were not changed.
