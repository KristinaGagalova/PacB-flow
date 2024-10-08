//-----------------------------------------
// Abyss: doi:10.1101/gr.214346.116
//-----------------------------------------

process ABYSS_FAC {

    label 'small_task'
    tag "Calculating assembly stats for all assemblies"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abyss:2.3.7--hec08913_1'  :
	'quay.io/biocontainers/abyss:2.3.7--h103dbdd_4'}"

    input:
	path(assemblies) // collected paths of assemblies
    
    output:
        path("all_stats.tsv"), emit: assembly_stats
	path("versions.yml") , emit: versions

    script:
    def command = params.ng50 ? "-G${params.abyss_gensize}" : " "
    """
    abyss-fac ${assemblies} ${command} > all_stats.tsv

    cat <<-VERSIONS > versions.yml
    "${task.process}":
        abyss-fac: \$(abyss-fac --version | head -n 1 | cut -d" " -f3)
    VERSIONS
    """
}
