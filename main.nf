#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

workflow {

  // 1. Validate parameters
  validateParameters()
  // Create a nice summary of the Launch settings (parameters, file paths, etc)
  log.info paramsSummaryLog(workflow) 
  
  // 2. Parse input samplesheet -> [meta, fastq]
  ch_samples = Channel
      .fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_samplesheet.json"))
      // .view { "After Channel.fromList(samplesheetToList(,)): ${it}"}
      .map { meta, fastq -> println "meta map: ${meta}\nfastq: ${fastq}\n"}

  // Routing to a determined workflow using mode parameter
  if (params.mode == "benchmarking") {
    log.info """
        =========================================
        --------- BENCHMARKING WORKFLOW ---------
        Comparing inference methods and databases
        =========================================
    """
    // Later add WORKFLOW:
    // BENCHMARKING()

  } else if (params.mode == "recommended") {
    log.info """
        ========================================
        --------- RECOMMENDED WORKFLOW ---------
        Running the selected analysis strategy
        ========================================
    """
    // Later add WORKFLOW:
    // RECOMMENDED()

  } else {
    error """
    Invalid mode: ${params.mode}.
    Valid modes: benchmarking, recommended
    """
  }

}