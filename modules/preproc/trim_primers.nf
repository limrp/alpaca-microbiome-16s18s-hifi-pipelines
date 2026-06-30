/*
 * CUTADAPT_TRIM
 * Role: Trim full-length primers with cutadapt (HiFi-16S-workflow style).
 */
process CUTADAPT_TRIM {
  tag "${sample_id}"
  publishDir { "${params.outdir}/trimmed_primers_FASTQ" }, pattern: '*.fastq.gz', mode: params.publish_dir_mode
  publishDir { "${params.outdir}/cutadapt_summary" }, pattern: '*.report', mode: params.publish_dir_mode
  conda (params.enable_conda ? params.conda_qiime2 : null)
  container params.qiime2_container
  cpus params.cutadapt_cpu

  input:
  tuple val(sample_id), path(sample_fastq)

  output:
  tuple val(sample_id), path("${sample_id}.trimmed.fastq.gz"), emit: trimmed_fastq
  path "${sample_id}.cutadapt.report", emit: cutadapt_report
  path "cutadapt_summary_${sample_id}.tsv", emit: cutadapt_summary

  script:
  """
  cutadapt -g "${params.primer_fwd}...${params.primer_rev}" \
    ${sample_fastq} \
    -o ${sample_id}.trimmed.fastq.gz \
    -j ${task.cpus} --trimmed-only --revcomp -e ${params.cutadapt_error_rate} \
    --json ${sample_id}.cutadapt.report

  input_read=$(jq -r '.read_counts | .input' ${sample_id}.cutadapt.report)
  demux_read=$(jq -r '.read_counts | .output' ${sample_id}.cutadapt.report)
  echo -e "sample\tinput_reads\tdemuxed_reads" > cutadapt_summary_${sample_id}.tsv
  echo -e "${sample_id}\t${input_read}\t${demux_read}" >> cutadapt_summary_${sample_id}.tsv
  """
}
