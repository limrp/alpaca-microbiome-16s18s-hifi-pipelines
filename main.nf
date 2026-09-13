#!/usr/bin/env nextflow

nextflow.enable.dsl=2

workflow {

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