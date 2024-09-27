//-----------------------------------------
// bedtools: doi:10.1093/bioinformatics/btq033
//-----------------------------------------

process BEDTOOLS_COVERAGE {

    label 'small_task'
    tag "Calculate coverage tracks for ${sample_id}."

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.31.1--hf5e1c6e_1'  :
        'quay.io/biocontainers/bedtools:2.27.1--he941832_2'}" //missing 2.31

    input:
        tuple val(sample_id), path(bam_reads)

    output:
        tuple val("${sample_id}"), path("${sample_id}.bedgraph"), emit: bedgraph

    script:
    """
    bedtools genomecov -ibam ${bam_reads} -bg > ${sample_id}.bedgraph

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version | sed -e "s/bedtools v//g")
    END_VERSIONS
    """
}
    
