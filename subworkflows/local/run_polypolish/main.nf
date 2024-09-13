//
// Subworkflow - polish genome
//

include { BWA_INDEX }                            from '../../../modules/nf-core/bwa/index/main'
include { BWAMEM_MAPALL as BWAMEM_R1}            from '../../../modules/local/software/bwa/mapallreads'
include { BWAMEM_MAPALL as BWAMEM_R2}            from '../../../modules/local/software/bwa/mapallreads'
include { POLYPOLISHFILT }                       from '../../../modules/local/software/polypolish/polishgenome'
include { POLYPOLISHPOLISH }                     from '../../../modules/local/software/polypolish/polishgenome'

workflow POLISH_GENOME {

    take:
	sample_pair        // tuple [ sample, pair1, pair2 ]
        genome_assembly    // tuple [ sample,  assembly ]
	

    main:

	sample_pair.map { val, reads1, reads2 -> tuple(val, reads1) }
                                    .set { reads_pair1 }
        sample_pair.map { val, reads1, reads2 -> tuple(val, reads2) }
                                    .set { reads_pair2 }
	
	// Index genome for mapping
 	GEN_INDEX = BWA_INDEX(genome_assembly)
	
	// Map reads individually
	reads_R1 = BWAMEM_R1(
		reads_pair1,
		"R1",
		GEN_INDEX.index
		)
		
	reads_R2 = BWAMEM_R2(
                reads_pair2,
                "R2",
                GEN_INDEX.index
                )

	// Polypolish prepare
        FILT_READS = POLYPOLISHFILT(reads_R1.reads_mapped, reads_R2.reads_mapped)
	// Polypolish polish genome
	POLYPOLISHPOLISH(
		FILT_READS.reads_filt1,
		FILT_READS.reads_filt2,
		genome_assembly
		)

    emit:
        polished_genome      = POLYPOLISHPOLISH.out.genome_polished

}
