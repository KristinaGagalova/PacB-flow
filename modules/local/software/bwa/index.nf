process BWA_INDEX {

    tag "${meta}"
    label 'small_task'

    conda (params.enable_conda ? "bioconda::bwakit=0.7.17" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'quay.io/biocontainers/bwakit:0.7.17.dev1--hdfd78af_1':
        null }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${fasta}.*"), emit: index
    path "versions.yml"                , emit: versions

    script:
    """
    bwa mem index ${fasta}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$("bwa -version")
    END_VERSIONS
    """
}
