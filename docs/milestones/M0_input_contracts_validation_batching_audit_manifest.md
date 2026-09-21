# M0 — Input contracts, validation, experimental batching, audit manifest

**Status:** Complete

## M0A — Inspect and freeze the starting repository state
- [x] Completed.

## M0B — Freeze the sequencing samplesheet and schema contracts
- [x] Canonical samplesheet fields:
  `sample`, `dataset_id`, `data_origin`, `workflow_branch`,
  `marker`, `input_stage`, `fastq`.
- [x] `dataset_id + marker` defined as the inference-batch boundary.
- [x] `data_origin` and `workflow_branch` retained as separate concepts.
- [x] `input_stage` retained as a row-level property.

## M0C — Parse valid rows into `[meta, fastq]`
- [x] nf-schema parameter validation enabled.
- [x] Samplesheet validated with `assets/schema_samplesheet.json`.
- [x] Rows parsed into `[meta, fastq]`.

## M0D — Construct and verify `dataset_id + marker` inference batches
- [x] Batch key constructed from `dataset_id + marker`.
- [x] Samples grouped with `groupTuple()`.
- [x] Canonical M0 fixture produces six batches:
  - `dummy_16S_R01`: 2 samples
  - `dummy_16S_R02`: 2 samples
  - `dummy_18S_R01`: 2 samples
  - `dummy_18S_R02`: 2 samples
  - `dummy_alpaca_16S`: 6 samples
  - `dummy_alpaca_18S`: 6 samples

## M0E — Validate batch semantics and write `batch_manifest.tsv`
- [x] Verify metadata and FASTQ counts agree.
- [x] Reject empty batches.
- [x] Require exactly one `data_origin` per batch.
- [x] Require exactly one `workflow_branch` per batch.
- [x] Report observed `input_stage` values without requiring batch homogeneity.
- [x] Negative test confirmed that a mixed `workflow_branch` batch is rejected.
- [x] Sample IDs sorted deterministically within each manifest row.
- [x] Manifest rows sorted deterministically.
- [x] Persistent `batch_manifest.tsv` created.
- [x] Manifest contains six data rows.
- [x] Manifest `n_samples` sums to 20.

## M0F — Close M0 cleanly
- [x] Added canonical `params/test.yml`.
- [x] Added nf-core-style `--outdir`.
- [x] Canonical test run:
  `nextflow run main.nf -params-file params/test.yml`
- [x] Canonical test run exits with status `0`.
- [x] Test output:
  `results/test/pipeline_info/batch_manifest.tsv`
- [x] Added 20 tiny FASTQ fixtures required by the canonical samplesheet.
- [x] All fixture `.fastq.gz` files passed `gzip -t`.
- [x] Removed temporary `.view()` debugging closures.
- [x] Preserved useful explanatory comments.
- [x] Confirmed no taxonomy/database/inference-grid implementation leaked into M0.
- [x] Final staged patch passed `git diff --cached --check`.
- [x] M0 closure commit:
  `049bc8d feat(m0): finalize input contracts and batch manifest`
- [x] Branch pushed and synchronized with `origin/m0-input-contracts`.

## M0 checkpoint

`samplesheet → schema → [meta, fastq] → dataset_id+marker key → groupTuple() → internally valid batches → batch_manifest.tsv`

**Result:** M0 complete.
