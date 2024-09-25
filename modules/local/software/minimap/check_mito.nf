process MITO_ALIGN {

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/minimap2:2.28--he4a0461_0' :
        'biocontainers/minimap2:2.28--he4a0461_0' }"

    label 'small_task'
    tag "Get mito genome ${sample_id}"

    input:
	tuple val(sample_id), path(fasta_assembly)
	file(mitodb)

    output:
    	tuple val(sample_id), path("${sample_id}_MT.tab"), emit: list_mito
	path("versions.yml")                             , emit: versions

    script:
    """
    minimap2 -x asm5 ${fasta_assembly} ${mitodb} |\
	awk '{print \$6,\$6,"MT"}' | sed 's/ /\t/' | sort | uniq 1> ${sample_id}_MT.tab

    cat <<-VERSIONS > versions.yml
    "${task.process}":
	 minimap2: \$(minimap2 --version 2>&1)
    VERSIONS    
    """

}
