process NTLINK_SCAFFOLD {

    label 'medium_task'
    tag "Scaffold ${sample_id} with long reads."

    conda (params.enable_conda ? "bioconda::ntlink=1.3.10" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
       'https://depot.galaxyproject.org/singularity/ntlink:1.3.9--py39hd65a603_2'  :
       'quay.io/biocontainers/ntlink:1.3.10--py312hb36dd0b_2'}"

    input:
        tuple val(sample_id), path(reads), path(assembly)
	//tuple val(sample_id), path(reads)

    output:
        tuple val("${sample_id}.ntlink"), path("${sample_id}/${sample_id}.ntlink.scaffolds.fa") , emit: assembly
	tuple val("${sample_id}.ntlink"), path("${sample_id}/${sample_id}.ntlink.scaffolds.paf"), emit: alignement_reads
        path("versions.yml")                                                                    , emit: versions

    script:
    def args_w      = params.ntlink_w
    def args_k      = params.ntlink_k
    def args_z      = params.ntlink_z
    def args_rounds = params.ntlink_rounds
    """
    ntLink_rounds \
        run_rounds_gaps \
        target=${assembly} \
        reads=${reads} \
        k=${args_k} \
        w=${args_w} \
        rounds=${args_rounds} \
	paf=True \
	sensitive=True

    mkdir -p ${sample_id}
    cp -L ${assembly}.k${args_k}.w${args_w}.z${args_z}.ntLink.gap_fill.${args_rounds}rounds.fa ${sample_id}/${sample_id}.ntlink.scaffolds.fa
    cp ${assembly}.k${args_k}.w${args_w}.z${args_z}.paf ${sample_id}/${sample_id}.ntlink.scaffolds.paf

    cat <<-VERSIONS > versions.yml
    "${task.process}":
        ntLink: \$(ntLink | grep "^ntLink" | grep -v ":" | cut -d" " -f2 | head -n1)
    VERSIONS
    """
}
