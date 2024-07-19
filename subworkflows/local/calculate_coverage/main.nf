//
// Subworkflow - calculate coverage
//

include { PBMM_MAPLONG }                            from '../../../modules/local/software/pbmm/maplongreads'
include { BEDTOOLS_COVERAGE }                       from '../../../modules/local/software/bedtools/genomecoverage'
include { SEQKIT_LENGTHS }                          from '../../../modules/local/software/seqkit/fastalengths'
include { UCSC_BEDGRAPHCONVERT }                    from '../../../modules/local/software/ucsc-utilities/bedgraphtobigwig'


workflow COVERAGE_CALCULATE {

    take:
        reads_assembly    // tuple [ sample, reads, assembly ]
	
    main:
	// Split the input channel into two separate channels
	//def ch_reads    = reads_assembly.map { name, reads, assembly -> tuple(name, reads) }
	def ch_assembly = reads_assembly.map { name, reads, assembly -> tuple(name, assembly) }
	
	// get mappings
	MAPPED_READS = PBMM_MAPLONG(reads_assembly)
	
	COV_BP = BEDTOOLS_COVERAGE(MAPPED_READS.mapped_lr)
	FASTA_LENS = SEQKIT_LENGTHS(ch_assembly)
	UCSC_BEDGRAPHCONVERT(COV_BP.bedgraph, FASTA_LENS.genome_len)
	

    emit:
        mapped_lr          = MAPPED_READS.mapped_lr
	coverge_profiles   = UCSC_BEDGRAPHCONVERT.out.bigwig

}
