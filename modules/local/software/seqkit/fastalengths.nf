//-----------------------------------------
// seqkit2: doi:10.1002/imt2.191.
//-----------------------------------------

process SEQKIT_LENGTHS {

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqkit:2.8.1--h9ee0642_0  '  :
        'quay.io/biocontainers/seqkit:2.8.1--h9ee0642_0'}"

    label 'small_task'
    tag "Calculate genome lengths for ${sample_id}."

    input:
        tuple val(sample_id), path(fasta_assembly)

    output:
        tuple val("${sample_id}"), path("${sample_id}.genome"), emit: genome_len

    script:
    """
    seqkit fx2tab --length --only-id ${fasta_assembly} --name --out-file ${sample_id}.genome
    
    cat <<-VERSIONS > versions.yml
    "${task.process}":
	seqkit: \$(seqkit version | cut -d' ' -f2)
    VERSIONS
    """
}
    
