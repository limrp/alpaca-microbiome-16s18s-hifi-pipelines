/*
 * DADA2_GRID
 * Role: Run DADA2 across a parameter grid (benchmarking mode scaffold).
 * NOTE: This is a scaffold placeholder; replace the script with the real DADA2 execution.
 */
process DADA2_GRID {
  tag "${run_id}"
  publishDir { "${params.outdir}/benchmarking/dada2" }, mode: params.publish_dir_mode
  cpus params.dada2_cpu

  input:
  tuple val(run_id), val(p)

  output:
  path "dada2_grid_${run_id}.tsv", emit: grid_result

  script:
  def row = p.collect { k, v -> "${k}=${v}" }.join('\t')
  """
  echo -e "run_id\tparams" > dada2_grid_${run_id}.tsv
  echo -e "${run_id}\t${row}" >> dada2_grid_${run_id}.tsv
  """
}

/*
 * DADA2_RECOMMENDED
 * Role: Run DADA2 with a single recommended configuration (recommended mode scaffold).
 * NOTE: Replace with the real DADA2 implementation.
 */
process DADA2_RECOMMENDED {
  publishDir { "${params.outdir}/recommended/dada2" }, mode: params.publish_dir_mode
  cpus params.dada2_cpu

  input:
  val(dummy)

  output:
  path "dada2_recommended.done"

  script:
  """
  echo "DADA2 recommended run placeholder" > dada2_recommended.done
  """
}
