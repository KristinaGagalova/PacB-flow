process UCSC_BEDGRAPHCONVERT {

    label 'big_task'
    tag "Calculate coverage tracks for ${sample_id}."

     conda (params.enable_conda ? "bioconda::bedgraphtobigwig=455" : null)
     container 'https://depot.galaxyproject.org/singularity/ucsc-bedgraphtobigwig:455--h2a80c09_1' 

    input:
        tuple val(sample_id), path(bedgraph)
	tuple val(sample_id), path(fasta_lens)

    output:
        tuple val("${sample_id}"), path("${sample_id}.bw"), emit: bigwig

    script:
    """
    bedGraphToBigWig ${bedgraph} ${fasta_lens} ${sample_id}.bw
    """
}
