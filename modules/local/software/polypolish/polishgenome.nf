process POLYPOLISHFILT {

    label 'medium_task'
    tag "Filter mapped reads."

     conda (params.enable_conda ? "bioconda::polypolish=0.6.0" : null)
     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/polypolish:0.6.0--hdbdd923_0'  :
        'quay.io/biocontainers/polypolish:0.6.0--h4c94732_1'}"

    input:
        tuple val(sample_id), path(reads_mapped1)
	tuple val(sample_id), path(reads_mapped2)

    output:
        tuple path( sample_id ), path("${sample_id}_filt1.sam"), emit: reads_filt1
	tuple path( sample_id ), path("${sample_id}_filt2.sam"), emit: reads_filt2
        path("versions.yml")                                   , emit: versions

    script:
    """
    polypolish filter \
	--in1 ${reads_mapped1} \
	--in2 ${reads_mapped2} \
	--out1 ${sample_id}_filt1.sam \
	--out2 ${sample_id}_filt2.sam

    cat <<-VERSIONS > versions.yml
    "${task.process}":
        polypolysh: \$(bwa 2>&1 | grep \"Version\" | awk '{print \$2}')
    VERSIONS
    """
}

process POLYPOLISHPOLISH {

    label 'medium_task'
    tag "Polish genome with mapped reads."

    conda (params.enable_conda ? "bioconda::polypolish=0.6.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
       'https://depot.galaxyproject.org/singularity/polypolish:0.6.0--hdbdd923_0'  :
       'quay.io/biocontainers/polypolish:0.6.0--h4c94732_1'}"

    input:
        tuple val(sample_id), path(reads_filt1)
        tuple val(sample_id), path(reads_filt2)
	tuple val(sample_id), path(genome)

    output:
        tuple path( sample_id ), path("${sample_id}_polished.fasta"), emit: genome_polished
        path("versions.yml")                                        , emit: versions

    script:
    """
    polypolish polish \
	${genome} \
        ${reads_filt1} \
        ${reads_filt2} > {sample_id}_polished.fasta

    cat <<-VERSIONS > versions.yml
    "${task.process}":
        polypolysh: \$(bwa 2>&1 | grep \"Version\" | awk '{print \$2}')
    VERSIONS
    """

}

