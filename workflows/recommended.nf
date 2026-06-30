nextflow.enable.dsl=2

include { qc_only } from './qc_only'
include { DADA2_RECOMMENDED } from '../modules/dada2/dada2_run'
include { VSEARCH_RECOMMENDED } from '../modules/vsearch/vsearch_run'
include { USEARCH_RECOMMENDED } from '../modules/usearch/usearch_run'

workflow recommended {
  take:
  samples_ch

  main:
  // Always run QC-only steps first.
  qc_only(samples_ch)

  // Placeholder recommended runs (replace with real implementations)
  DADA2_RECOMMENDED('run')
  VSEARCH_RECOMMENDED('run')
  USEARCH_RECOMMENDED('run')

  emit:
  qc_report = qc_only.out.qc_report
}
