# M03 — Input Contracts and Regression Validation

**Roadmap:** Reduced-Scope Thesis Roadmap v0.3
**Date:** 2026-10-15
**Status:** Validation passed; Git closure pending
**Historical relationship:** Extends the already-closed historical thesis M0 milestone without replacing or modifying its original evidence.

## 1. Objective

Verify and strengthen input-contract validation, dataset/marker batching, deterministic batch-manifest generation, and automated regression coverage before beginning M04 — DADA2 inference.

## 2. Implemented and validated

- Seven-column samplesheet contract preserved.
- Dataset and marker batching validated.
- Mixed data origins and workflow branches within batches rejected.
- Mixed input stages permitted within otherwise valid biological-processing batches.
- `biological + controlled` combination rejected.
- Empty samplesheets rejected.
- Deterministic batch-manifest generation verified.
- Automated nf-test regression suite implemented.
- Test execution isolated from existing scientific outputs.

## 3. Regression evidence

**Final reported result:** 23 passed, 0 failed, 0 skipped.

**Versions:**
- Nextflow: 26.04.6, build 12646
- nf-test: 0.9.5
- nf-schema: 2.7.3, based on execution logs
- Java: Eclipse Temurin 17.0.10+7

**Test files:**
- `nf-test.config`
- `tests/main.nf.test`
- `tests/README.md`

**Final reported JUnit evidence:** `/tmp/m03-regression.V28z8N/junit.xml`

The final review found no blocking issues for beginning M04.

## 4. Input provenance decision

The deterministic batch manifest records batch-level metadata, membership, sample counts and observed input stages.

It does not contain all seven original samplesheet fields or sample-to-FASTQ paths.

Therefore, the original source samplesheet must remain available and be preserved with the M04 analysis provenance.

A separate input manifest is not required for M03 closure, provided the source samplesheet and batch manifest jointly supply the necessary information.

## 5. JVM incident

An earlier nf-test execution encountered a native JVM segmentation fault (`SIGSEGV`).

- Original diagnostic: `hs_err_pid178.log`
- Original report preserved in a private evidence directory outside Git.
- SHA-256 integrity check: PASS.
- Later complete regression runs: PASS, including the final 23-case suite.
- Root cause: Unknown.
- Status: Nonblocking; monitor for recurrence.

**Private archive:** `~/my_projects/thesis_2026/private_evidence/M03_JVM_SIGSEGV_2026-10-15/`

The raw JVM crash report must not be committed to the public thesis repository.

## 6. Closure review

- [x] Automated regression suite implemented.
- [x] All 23 regression tests passed.
- [x] New input-validation rules tested.
- [x] Deterministic batch-manifest behavior tested.
- [x] Independent read-only review reported no blocking findings.
- [x] JVM crash report preserved with a verified checksum.
- [ ] User reviews the exact Git diff and untracked test files.
- [ ] User reviews and accepts this milestone evidence.
- [ ] Explicitly stage approved M03 files only.
- [ ] Review staged diff and perform Git commit.

**Milestone acceptance:** M03 may be marked complete after final user review and reviewed Git closure.

## 7. Handoff to M04

M04 must preserve the original samplesheet and exact sample-to-FASTQ mapping, validate the frozen controlled 16S R01 input files, and implement genuine DADA2 inference using the approved scientific configuration.

Historical M0 and frozen simulator M0.5/M1 evidence remain unchanged.
