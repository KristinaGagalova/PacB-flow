process CANU_ASSEMBLY {

    label 'large_task'
    tag "Assemble long reads for ${sample_id}"

     conda (params.enable_conda ? "bioconda::canu=2.2" : null)
     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/canu:canu:2.2--ha47f30e_0 ':
        'quay.io/biocontainers/canu:2.2--ha47f30e_0' }"

    input:
        tuple val(sample_id), path(reads)
    
    output:
        tuple val(sample_id), path("${sample_id}/${sample_id}.contigs.fasta"), emit: assembly
        tuple val(sample_id), path("${sample_id}/${sample_id}.report")       , emit: report
	path("versions.yml")                                                 , emit: versions

    script:
    """
    canu \
        -p ${sample_id} -d ${sample_id} \
        -maxThreads=${task.cpus} \
        genomeSize=${params.genome_size} \
        -pacbio ${reads}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
	canu: \$("canu -version | cut -d' ' -f2")
    END_VERSIONS
    """

}
