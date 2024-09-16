//
// Subworkflow - polish genome
//

include { BWA_INDEX }                            from '../../../modules/nf-core/bwa/index/main'
include { BWAMEM_MAPALL as BWAMEM_R1 }           from '../../../modules/local/software/bwa/mapallreads'
include { BWAMEM_MAPALL as BWAMEM_R2 }           from '../../../modules/local/software/bwa/mapallreads'
include { POLYPOLISHFILT }                       from '../../../modules/local/software/polypolish/polishgenome'
include { POLYPOLISHPOLISH }                     from '../../../modules/local/software/polypolish/polishgenome'

workflow POLISH_GENOME {

    take:
        sample_pair_genome        // tuple [ sample, reads_pair1, reads_pair2, genome ]

    main:
        // Separate channels for reads1, reads2, and genome
        sample_pair_genome.map { sample, reads1, reads2, genome -> tuple(sample, reads1) }
                        .set { reads_pair1 }

        sample_pair_genome.map { sample, reads1, reads2, genome -> tuple(sample, reads2) }
                        .set { reads_pair2 }

        // Index genome for each sample using the correct genome
	sample_pair_genome.map { sample, reads1, reads2, genome -> tuple(sample, genome) }
			.set { genome_channel }

	// Step 2: Pass the genome to the BWA_INDEX process
	indexed_genome = BWA_INDEX(genome_channel)
	
	
        // Map reads individually using the indexed genome output as input for the index
        reads_R1 = BWAMEM_R1(
		reads_pair1,
        	"R1",
        	indexed_genome.index)

         reads_R2 = BWAMEM_R2(
		reads_pair2,
                "R2",
                indexed_genome.index
            )

        // Pair reads together
        reads_R1.reads_mapped.join(reads_R2.reads_mapped)
                .set { ch_readsR1_readsR2 }
	//ch_readsR1_readsR2.view()
        // Polypolish filtering step
        FILT_READS = POLYPOLISHFILT(ch_readsR1_readsR2)

        // Polypolish polishing genome step
        polished_genome = POLYPOLISHPOLISH(
                FILT_READS.reads_filt,
                sample_pair_genome.map { 
			sample, reads1, reads2, genome -> tuple(sample, genome) 
		} // pass the original genome
        )

    emit:
	//index_gen = indexed_genome.index
	filt_reads  = FILT_READS.reads_filt
        polished_genome = polished_genome.genome_polished
}

