//-----------------------------------------
// CANU assembler: doi:10.1101/gr.215087.116
//-----------------------------------------

process CANU_ASSEMBLY {

    label 'large_assemblyTask'
    tag "Assemble long reads for ${sample_id}"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/canu:2.2--ha47f30e_0'  :
	'quay.io/biocontainers/canu:2.2--ha47f30e_0'}"

    input:
        tuple val(sample_id), path(reads)
    
    output:
        tuple val(sample_id), path("${sample_id}/${sample_id}.contigs.fasta"), emit: assembly
        tuple val(sample_id), path("${sample_id}/${sample_id}.report")       , emit: report
	path("versions.yml")                                                 , emit: versions

    script:
    """
    canu \
        -p ${sample_id} \
	-d ${sample_id} \
        -maxThreads=${task.cpus} \
        genomeSize=${params.genome_size} \
        -pacbio ${reads}
    
    cat <<-VERSIONS > versions.yml
    "${task.process}":
	canu: \$(canu -version | cut -d' ' -f2)
    VERSIONS
    """

}
