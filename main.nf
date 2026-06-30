nextflow.enable.dsl=2

// include { qc_only } from './workflows/qc_only'
// include { benchmarking } from './workflows/benchmarking'
// include { recommended } from './workflows/recommended'

process QC_ONLY_TEST {
    tag "qc_only jaja"

    output:
    path "message.txt", emit: message

    script:
    """
    echo "This is the qc only mode!" > message.txt
    """
}

process BENCHMARKING_TEST {
    tag "benchmarking jeje"

    output:
    path "message.txt", emit: message

    script:
    """
    echo "This is the benchmarking mode!" > message.txt
    """
}

process RECOMMENDED_TEST {
    tag "recommended jiji"

    output:
    path "message.txt", emit: message

    script:
    """
    echo "This is the recommended mode!" > message.txt
    """
}

workflow {
  // // Discover input FASTQ files and assign sample IDs from filenames.
  // samples_ch = Channel
  //   .fromPath("${params.input}/*.{fastq,fq}.gz", checkIfExists: true)
  //   .map { f ->
  //     def sample_id = f.baseName.replaceAll(/\.f(ast)?q$/, "")
  //     tuple(sample_id, f)
  //   }

  main:
  log.info "Selected mode: ${params.mode}"

  if (params.mode == 'qc_only') {
    QC_ONLY_TEST()
    selected_message = QC_ONLY_TEST.out.message

  } else if (params.mode == 'benchmarking') {
    BENCHMARKING_TEST()
    selected_message = BENCHMARKING_TEST.out.message

  } else if (params.mode == 'recommended') {
    RECOMMENDED_TEST()
    selected_message = RECOMMENDED_TEST.out.message

  } else {
    error "Unknown --mode: ${params.mode}. Use qc_only, benchmarking, or recommended."
  }

  // each output should be assigned in the publish section of the entry workflow
  // https://docs.seqera.io/nextflow/workflow
  publish:
  // The name messages is important because it must match the name in the top-level output {} block.
  messages = selected_message
}

output {
  messages {
    path "${params.mode}"
    mode 'copy'
    overwrite true
  }
}
