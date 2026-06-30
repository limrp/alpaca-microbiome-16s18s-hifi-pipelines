nextflow.enable.dsl=2

include { QC_FASTQ; QC_FASTQ_POST_TRIM; COLLECT_QC; QC_REPORT } from '../modules/preproc/qc_ccs'
include { CUTADAPT_TRIM } from '../modules/preproc/trim_primers'

workflow qc_only {
  take:
  samples_ch

  main:
  // Pre-trim QC
  qc_pre = QC_FASTQ(samples_ch)

  // Primer trimming (cutadapt)
  trimmed = CUTADAPT_TRIM(samples_ch)
  trimmed_fastq = trimmed.out.trimmed_fastq

  // Post-trim QC
  qc_post = QC_FASTQ_POST_TRIM(trimmed_fastq)

  // Aggregate QC tables
  collected = COLLECT_QC(
    qc_pre.out.all_seqkit_stats.collect(),
    qc_pre.out.all_seqkit_summary.collect(),
    qc_post.out.all_seqkit_stats_post_trim.collect(),
    trimmed.out.cutadapt_summary.collect()
  )

  // Render HTML report
  QC_REPORT(
    collected.out.all_samples_readstats,
    collected.out.all_samples_readstats_post_trim,
    collected.out.summarised_sample_readstats,
    collected.out.cutadapt_summary,
    file(params.qc_report_rmd)
  )

  emit:
  qc_report = QC_REPORT.out.qc_report_html
}
