/*
 * USEARCH_GRID
 * Role: Run USEARCH/UNOISE3 across a parameter grid (benchmarking mode scaffold).
 * NOTE: Replace with the real USEARCH implementation.
 */
process USEARCH_GRID {
  tag "${run_id}"
  publishDir { "${params.outdir}/benchmarking/usearch" }, mode: params.publish_dir_mode
  cpus params.usearch_cpu

  input:
  tuple val(run_id), val(p)

  output:
  path "usearch_grid_${run_id}.tsv", emit: grid_result

  script:
  def row = p.collect { k, v -> "${k}=${v}" }.join('\t')
  """
  echo -e "run_id\tparams" > usearch_grid_${run_id}.tsv
  echo -e "${run_id}\t${row}" >> usearch_grid_${run_id}.tsv
  """
}

/*
 * USEARCH_RECOMMENDED
 * Role: Run USEARCH with a single recommended configuration (recommended mode scaffold).
 */
process USEARCH_RECOMMENDED {
  publishDir { "${params.outdir}/recommended/usearch" }, mode: params.publish_dir_mode
  cpus params.usearch_cpu

  input:
  val(dummy)

  output:
  path "usearch_recommended.done"

  script:
  """
  echo "USEARCH recommended run placeholder" > usearch_recommended.done
  """
}
