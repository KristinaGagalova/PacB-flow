process PBMM_MAPLONG {

    label 'medium_task'
    tag "Mapping long reads ${sample_id}"

     conda (params.enable_conda ? "bioconda::pbmm=1.14" : null)
     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pbmm2:1.14.99--h9ee0642_0'  :
	'quay.io/biocontainers/pbmm2:1.13.1_build3'}"

    input:
        tuple val(sample_id)  , path(reads)
	tuple val(assembly_id), path(assembly)
    
    output:
        tuple val(assembly_id), path("${assembly_id}.lr.sort.bam"), emit: mapped_lr
	path("versions.yml")                                      , emit: versions

    script:
    """
    pbmm2 index ${assembly} \
		${sample_id}.mmi \
		--preset SUBREAD
    
    pbmm2 align ${sample_id}.mmi \
	${reads} \
	${assembly_id}.lr.sort.bam \
	--preset SUBREAD \
	--sort \
	-j ${task.cpus} -J ${task.cpus} 

    cat <<-VERSIONS > versions.yml
    "${task.process}":
        pbmm: \$(pbmm2 --version | grep "^pbmm2" | cut -d":" -f2 | cut -d" " -f2)
    VERSIONS
    """
}
