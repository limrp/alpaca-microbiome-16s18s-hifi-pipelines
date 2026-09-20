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
    // ch_batches.view { batch_key, metas, fastqs -> 
    //     // Collect in a list all the ids of the samples of each batch
    //     def sample_ids = metas.collect { meta -> meta.id }
    //     // View the batches in a nicer and summarized way
    //     "BATCH: dataset_id = ${batch_key.dataset_id} | marker = ${batch_key.marker} | n = ${sample_ids.size()} | samples = ${sample_ids.join(', ')} "
    // }

    // Validation of grouped batches
    ch_valid_batches = ch_batches.map { batch_key, metas, fastqs ->
        
        // Used right now for validation
        def origins  = metas.collect { meta -> meta.data_origin }.unique()
        def branches = metas.collect { meta -> meta.workflow_branch }.unique()

        // These two summaries are not currently used by the validation itself.
        // They are local to this map closure and are not emitted downstream.
        // The manifest step will derive them again from `metas`.
        // def stages   = metas.collect { meta -> meta.input_stage }.unique().sort()
        // def sample_ids = metas.collect { meta -> meta.id }.sort()

        if (metas.size() != fastqs.size()) {
            throw new IllegalArgumentException(
                "Batch ${batch_key.dataset_id} + ${batch_key.marker}: " +
                "metadata count (${metas.size()}) does not match FASTQ count (${fastqs.size()})"
            )
        }

        if (metas.isEmpty()) {
            throw new IllegalArgumentException(
                "Batch ${batch_key.dataset_id} + ${batch_key.marker}: batch contains no samples"
            )
        }

        if (origins.size() != 1) {
            throw new IllegalArgumentException(
                "Batch ${batch_key.dataset_id} + ${batch_key.marker}: " +
                "multiple data_origin values found: ${origins}"
            )
        }

        if (branches.size() != 1) {
            throw new IllegalArgumentException(
                "Batch ${batch_key.dataset_id} + ${batch_key.marker}: " +
                "multiple workflow_branch values found: ${branches}"
            )
        }

        [batch_key, metas, fastqs]
    }
    // Temporary view to help us inspect the semantic validation once 
    // before creating the persistent manifest
    // ch_valid_batches.view { batch_key, metas, fastqs ->

    //     def origins  = metas.collect { it.data_origin }.unique()
    //     def branches = metas.collect { it.workflow_branch }.unique()
    //     def stages   = metas.collect { it.input_stage }.unique().sort()
    //     def sample_ids = metas.collect { it.id }.sort()

    //     "BATCH CHECK: " +
    //     "dataset_id=${batch_key.dataset_id} | " +
    //     "marker=${batch_key.marker} | " +
    //     "n=${sample_ids.size()} | " +
    //     "data_origin=${origins} | " +
    //     "workflow_branch=${branches} | " +
    //     "input_stages=${stages} | " +
    //     "samples=${sample_ids.join(',')}"
    // }

    // Create one TSV manifest row for each validated batch
    ch_batch_manifest_rows = ch_valid_batches.map { batch_key, metas, fastqs ->

        def origins    = metas.collect { it.data_origin }.unique().sort()
        def branches   = metas.collect { it.workflow_branch }.unique().sort()
        def stages     = metas.collect { it.input_stage }.unique().sort()
        def sample_ids = metas.collect { it.id }.sort()

        [
            batch_key.dataset_id,
            batch_key.marker,
            origins[0],
            branches[0],
            stages.join(','),
            sample_ids.size(),
            sample_ids.join(',')
        ].join('\t')
    }

    // Temporary inspection before writing the actual manifest
    ch_batch_manifest_rows.view { row ->
        "MANIFEST ROW: ${row}"
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