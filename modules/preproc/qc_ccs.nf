/*
 * QC_FASTQ
 * Role: Compute per-read and per-sample QC stats using seqkit (pre-trim).
 */
process QC_FASTQ {
  tag "${sample_id}"
  publishDir { "${params.outdir}/filtered_input_FASTQ" }, pattern: '*stats*.tsv', mode: params.publish_dir_mode
  conda (params.enable_conda ? params.conda_seqkit : null)
  container params.seqkit_container
  cpus params.qc_cpu

  input:
  tuple val(sample_id), path(sample_fastq)

  output:
  path "${sample_id}.seqkit.readstats.tsv", emit: all_seqkit_stats
  path "${sample_id}.seqkit.summarystats.tsv", emit: all_seqkit_summary

  script:
  """
  seqkit fx2tab -j $task.cpus -q --gc -l -H -n -i ${sample_fastq} |\
      csvtk mutate2 -C '%' -t -n sample -e '"${sample_id}"' > ${sample_id}.seqkit.readstats.tsv
  seqkit stats -T -j $task.cpus -a ${sample_fastq} |\
      csvtk mutate2 -C '%' -t -n sample -e '"${sample_id}"' > ${sample_id}.seqkit.summarystats.tsv
  """
}

/*
 * QC_FASTQ_POST_TRIM
 * Role: Compute per-read QC stats using seqkit after trimming.
 */
process QC_FASTQ_POST_TRIM {
  tag "${sample_id}"
  publishDir { "${params.outdir}/filtered_input_FASTQ" }, pattern: '*post_trim.tsv', mode: params.publish_dir_mode
  conda (params.enable_conda ? params.conda_seqkit : null)
  container params.seqkit_container
  cpus params.qc_cpu

  input:
  tuple val(sample_id), path(sample_fastq)

  output:
  path "${sample_id}.seqkit.readstats.post_trim.tsv", emit: all_seqkit_stats_post_trim

  script:
  """
  seqkit fx2tab -j $task.cpus -q --gc -l -H -n -i ${sample_fastq} |\
      csvtk mutate2 -C '%' -t -n sample -e '"${sample_id}"' > ${sample_id}.seqkit.readstats.post_trim.tsv
  """
}

/*
 * COLLECT_QC
 * Role: Aggregate QC TSVs and produce summary tables with csvtk.
 */
process COLLECT_QC {
  publishDir { "${params.outdir}/results/reads_QC" }, mode: params.publish_dir_mode
  conda (params.enable_conda ? params.conda_seqkit : null)
  container params.seqkit_container
  cpus params.qc_cpu

  input:
  path "*.seqkit.readstats.tsv"
  path "*.seqkit.summarystats.tsv"
  path "*.seqkit.readstats.post_trim.tsv"
  path "cutadapt_summary*.tsv"

  output:
  path "all_samples_seqkit.readstats.tsv", emit: all_samples_readstats
  path "all_samples_seqkit.readstats.post_trim.tsv", emit: all_samples_readstats_post_trim
  path "all_samples_seqkit.summarystats.tsv", emit: all_samples_summarystats
  path "seqkit.summarised_stats.group_by_samples.tsv", emit: summarised_sample_readstats
  path "seqkit.summarised_stats.group_by_samples.pretty.tsv"
  path "all_samples_cutadapt_stats.tsv", emit: cutadapt_summary

  script:
  """
  csvtk concat -t -C '%' *.seqkit.readstats.tsv > all_samples_seqkit.readstats.tsv
  csvtk concat -t -C '%' *.seqkit.readstats.post_trim.tsv > all_samples_seqkit.readstats.post_trim.tsv
  csvtk concat -t -C '%' *.seqkit.summarystats.tsv > all_samples_seqkit.summarystats.tsv
  csvtk concat -t cutadapt_summary*.tsv > all_samples_cutadapt_stats.tsv
  csvtk summary -t -C '%' -g sample -f length:q1,length:q3,length:median,avg.qual:q1,avg.qual:q3,avg.qual:median all_samples_seqkit.readstats.tsv > seqkit.summarised_stats.group_by_samples.tsv
  csvtk pretty -t -C '%' seqkit.summarised_stats.group_by_samples.tsv > seqkit.summarised_stats.group_by_samples.pretty.tsv
  """
}

/*
 * QC_REPORT
 * Role: Render an HTML QC report from aggregated TSVs.
 */
process QC_REPORT {
  publishDir { "${params.outdir}/results" }, mode: params.publish_dir_mode
  conda (params.enable_conda ? params.conda_r : null)
  container params.r_container
  cpus 1

  input:
  path readstats
  path readstats_post_trim
  path summarised_stats
  path cutadapt_stats
  path report_rmd

  output:
  path "qc_report.html", emit: qc_report_html

  script:
  """
  Rscript -e 'rmarkdown::render("${report_rmd}", params=list(readstats="${readstats}", readstats_post_trim="${readstats_post_trim}", summarised_stats="${summarised_stats}", cutadapt_stats="${cutadapt_stats}"), output_file="qc_report.html")'
  """
}
