nextflow.enable.dsl=2

include { qc_only } from './qc_only'
include { DADA2_GRID } from '../modules/dada2/dada2_run'
include { VSEARCH_GRID } from '../modules/vsearch/vsearch_run'
include { USEARCH_GRID } from '../modules/usearch/usearch_run'

workflow benchmarking {
  take:
  samples_ch

  main:
  // Always run QC-only steps first.
  qc_only(samples_ch)

  // DADA2 grid runs
  dada2_grid_ch = Channel
    .fromPath(params.grid_dada2, checkIfExists: true)
    .splitCsv(header: true, sep: '\t')
    .mapWithIndex { row, idx ->
      def run_id = row.run_id ?: "dada2_${idx+1}"
      tuple(run_id, row)
    }
  DADA2_GRID(dada2_grid_ch)

  // VSEARCH grid runs
  vsearch_grid_ch = Channel
    .fromPath(params.grid_vsearch, checkIfExists: true)
    .splitCsv(header: true, sep: '\t')
    .mapWithIndex { row, idx ->
      def run_id = row.run_id ?: "vsearch_${idx+1}"
      tuple(run_id, row)
    }
  VSEARCH_GRID(vsearch_grid_ch)

  // USEARCH grid runs
  usearch_grid_ch = Channel
    .fromPath(params.grid_usearch, checkIfExists: true)
    .splitCsv(header: true, sep: '\t')
    .mapWithIndex { row, idx ->
      def run_id = row.run_id ?: "usearch_${idx+1}"
      tuple(run_id, row)
    }
  USEARCH_GRID(usearch_grid_ch)

  emit:
  qc_report = qc_only.out.qc_report
}
