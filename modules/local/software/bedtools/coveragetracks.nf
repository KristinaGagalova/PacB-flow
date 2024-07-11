process BEDTOOLS_COVERAGE {

    label 'small_task'
    tag "Calculate coverage tracks for ${sample_id}."

     conda (params.enable_conda ? "bioconda::bedtools=2.31.1" : null)
     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.31.1--hf5e1c6e_1'  :
        'quay.io/biocontainers/bedtools:2.27.1--he941832_2'}" //missing 2.31

    input:
        tuple val(sample_id), path(assembly)
        path(ref_genome)

    output:
        tuple val("${sample_id}"), path("${sample_id}/${sample_id}.ntjoin.scaffolds.fa"), emit: assembly


    
