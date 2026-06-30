/*
 * VSEARCH_GRID
 * Role: Run VSEARCH across a parameter grid (benchmarking mode scaffold).
 * NOTE: Replace with the real VSEARCH implementation.
 */
process VSEARCH_GRID {
  tag "${run_id}"
  publishDir { "${params.outdir}/benchmarking/vsearch" }, mode: params.publish_dir_mode
  cpus params.vsearch_cpu

  input:
  tuple val(run_id), val(p)

  output:
  path "vsearch_grid_${run_id}.tsv", emit: grid_result

  script:
  def row = p.collect { k, v -> "${k}=${v}" }.join('\t')
  """
  echo -e "run_id\tparams" > vsearch_grid_${run_id}.tsv
  echo -e "${run_id}\t${row}" >> vsearch_grid_${run_id}.tsv
  """
}

/*
 * VSEARCH_RECOMMENDED
 * Role: Run VSEARCH with a single recommended configuration (recommended mode scaffold).
 */
process VSEARCH_RECOMMENDED {
  publishDir { "${params.outdir}/recommended/vsearch" }, mode: params.publish_dir_mode
  cpus params.vsearch_cpu

  input:
  val(dummy)

  output:
  path "vsearch_recommended.done"

  script:
  """
  echo "VSEARCH recommended run placeholder" > vsearch_recommended.done
  """
}
