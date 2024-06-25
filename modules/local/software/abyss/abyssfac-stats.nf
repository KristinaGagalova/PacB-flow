process ABYSS_FAC {

    label 'small_task'
    tag "Calculating assembly stats for ${sample_id}"

     conda (params.enable_conda ? "bioconda::abyss=2.3.7" : null)
     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abyss:2.3.7--hec08913_1'  :
	'quay.io/biocontainers/abyss:2.3.7--h103dbdd_4'}"

    input:
	tuple val(assembly_id), path(assembly)
    
    output:
        tuple val(assembly_id), path("${assembly_id}.lr_stats"), emit: assembly_stats
	path("versions.yml")                                   , emit: versions

    script:
    """
    abyss-fac ${assembly} > ${assembly_id}.lr_stats

    cat <<-VERSIONS > versions.yml
    "${task.process}":
        abyss-fac: \$(abyss-fac --version | head -n 1 | cut -d" " -f3)
    VERSIONS    
    """
}
