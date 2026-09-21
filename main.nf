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
    
    ch_samples_with_batch_key = ch_samples
        .map { meta, fastq -> 

            // Creating a new Groovy map for the batch key
            def batch_key = [
                dataset_id: meta.dataset_id,
                marker: meta.marker
            ]

            [batch_key, meta, fastq]
        }

    // Create batches by grouping the samples using .groupTuple()
    ch_batches = ch_samples_with_batch_key
        .groupTuple() // by default groupTuple() groups using the first element of each tuple

    // Validation of grouped batches -> asks: "Is this batch valid?"
    ch_valid_batches = ch_batches.map { batch_key, metas, fastqs ->
        
        // Used right now for validation
        def origins  = metas.collect { meta -> meta.data_origin }.unique()
        def branches = metas.collect { meta -> meta.workflow_branch }.unique()

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

    // Create one TSV manifest row for each validated batch -> asks: "How should this valid batch be summarized?"
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
    // This channel is going to emit individual String values

    // Temporary inspection before writing the actual manifest
    // ch_batch_manifest_rows.view { row ->
    //     "MANIFEST ROW: ${row}"
    // }

    // Collect all manifest rows and sort them deterministically.
    // Since every row begins with dataset_id followed by marker,
    // normal string sorting orders first by dataset_id and then by marker.
    ch_sorted_batch_manifest_rows = ch_batch_manifest_rows
        .collect() 
        // produces one channel emission containing a List -> List<String>
        // in which each element is a String 
        // each String is one complete TSV row
        .map { rows -> rows.sort() }
        // this line sorts the List<String> of complete TSV rows lexicographically
        // `rows` is a Groovy List<String>.
        // In which each element is one complete TSV row represented as a String.

    // Build the complete batch manifest content:
    // one header line followed by one deterministically sorted row per batch.
    ch_batch_manifest_content = ch_sorted_batch_manifest_rows.map { rows ->

        def header = [
            'dataset_id',
            'marker',
            'data_origin',
            'workflow_branch',
            'input_stages',
            'n_samples',
            'samples'
        ].join('\t')

        ([header] + rows).join('\n') + '\n'
    }

    // Temporary inspection before writing the manifest file
    // ch_sorted_batch_manifest_rows.view { rows ->
    //     "SORTED MANIFEST ROWS:\n${rows.join('\n')}"
    // }
    // ch_batch_manifest_content.view { content ->
    //     "BATCH MANIFEST CONTENT:\n${content}"
    // }

    // Persist the complete batch manifest as a workflow audit artifact.
    ch_batch_manifest_file = ch_batch_manifest_content.collectFile(
        name: 'batch_manifest.tsv',
        storeDir: "${params.outdir}/pipeline_info",
        // storeDir: "${projectDir}/results/pipeline_info",
        sort: false,
        newLine: false
    )

    // Inspecting the Path Object and its contents
    ch_batch_manifest_file.view { manifest ->
        "BATCH MANIFEST FILE: ${manifest}\n" +
        "CONTENTS:\n${manifest.text}"
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