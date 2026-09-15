#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

workflow {

  // 1. Validate parameters
  validateParameters()
  // Create a nice summary of the Launch settings (parameters, file paths, etc)
  log.info paramsSummaryLog(workflow) 
  
  // 2. Validate and Parse input samplesheet -> [meta, fastq]
  ch_samples = Channel
      .fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_samplesheet.json"))
      // .view {"After .fromList(samplesheetToList: ${it}"}
  
  ch_samples_with_batch_key = ch_samples
      .map { meta, fastq -> 

          // Creating a new Groovy map for the batch key
          def batch_key = [
              dataset_id: meta.dataset_id,
              marker: meta.marker
          ]

          [batch_key, meta, fastq]
      }
      // .view {"Contents after creating batch key [batch_key, meta_map, fastq]: ${it}"} // Also works
      // .view { batch_key, meta, fastq -> "Before grouping: batch = ${batch_key} | sample = ${meta.id} | fastq = ${fastq.name}"  } // Also works
  // ch_samples_with_batch_key.view { batch_key, meta, fastq -> "Before grouping: batch = ${batch_key} | sample = ${meta.id} | fastq = ${fastq.name}" }

  // Create batches by grouping the samples using .groupTuple()
  ch_batches = ch_samples_with_batch_key
      .groupTuple() // by default groupTuple() groups using the first element of each tuple
  //ch_batches.view { "After grouping: ${it}\n" } // worked well to see the raw contents of the channel after grouping
  ch_batches.view { batch_key, metas, fastqs -> 
      // Collect in a list all the ids of the samples of each batch
      def sample_ids = metas.collect { meta -> meta.id }
      // View the batches in a nicer and summarized way
      "BATCH: dataset_id = ${batch_key.dataset_id} | marker = ${batch_key.marker} | n = ${sample_ids.size()} | samples = ${sample_ids.join(', ')} "
  }

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