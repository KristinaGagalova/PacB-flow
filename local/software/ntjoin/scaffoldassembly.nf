process NTJOIN_SCAFFOLD {

    label 'medium_task'
    tag "Scaffold ${sample_id} with reference."

     conda (params.enable_conda ? "bioconda::ntjoin=1.1.3" : null)
     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ntjoin:1.1.3--py39hd65a603_0'  :
        'quay.io/biocontainers/ntjoin:1.1.3--py39hd65a603_0'}"

    input:
        tuple val(sample_id), path(assembly)
	path(ref_genome)

    output:
        tuple val("${sample_id}.ntjoin"), path("${sample_id}/${sample_id}.ntjoin.scaffolds.fa"), emit: assembly
        tuple val("${sample_id}.ntjoin"), path("${sample_id}/ntjoin.path")                     , emit: scaffold_paths
	tuple val("${sample_id}.ntjoin"), path("${sample_id}/ntjoin.agp")                      , emit: scaffold_agp
        path("versions.yml")                                                                   , emit: versions

    script:
    def args_ref  = params.ntjoin_ref
    def args_refW = params.ntjoin_ref_weights
    def args_w    = params.ntjoin_w
    def args_k    = params.ntjoin_k
    // modify input for no_cut
    def ntjoin_no_cut = params.ntjoin_no_cut.toString() // needs to be first capital letter!
    def args_cut  = ntjoin_no_cut.capitalize()
    
    """
    ntJoin assemble target=${assembly} \
	references=${args_ref} \
	reference_weights=${args_refW} \
	t=${task.cpus} \
	w=${args_w} \
	k=${args_k} \
	no_cut=${args_cut} \
	mkt=True \
	agp=True \
	prefix=ntjoin
     
    mkdir -p ${sample_id}
    mv ${assembly}.k${args_k}.w${args_w}.n1.all.scaffolds.fa ${sample_id}/${sample_id}.ntjoin.scaffolds.fa
    mv ntjoin* ${sample_id}/

    #cleanup ref genome files - these must be left for other samples
    #rm ${args_ref}.k${args_k}.w${args_w}.tsv
    #rm ${args_ref}.fai

    cat <<-VERSIONS > versions.yml
    "${task.process}":
        ntJoin: \$(ntJoin help | grep "^ntJoin" | grep -v ":" | cut -d" " -f2 | head -n1)
    VERSIONS
    """
}
