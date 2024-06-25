//
// Subworkflow - assembly
//

include { CANU_ASSEMBLY } from '../../../modules/local/software/canu/assemblereads'
include { PBMM_MAPLONG }  from '../../../modules/local/software/pbmm/maplongreads'
include { ABYSS_FAC }     from '../../../modules/local/software/abyss/abyssfac-stats'

workflow ASSEMBLY_PIPELINE {

    take:
        assembly_lr // tuple [sample, lr_reads ]
        assembly_sr // tuple [sample, sr1_reads, sr2_reads]    

    main:
        // run primary assembly
        CANU_ASSEMBLY(assembly_lr)
        ABYSS_FAC(CANU_ASSEMBLY.out.assembly)
	PBMM_MAPLONG(
		assembly_lr,
		CANU_ASSEMBLY.out.assembly
		)
  
    emit:
        versions = CANU_ASSEMBLY.out.versions
        lr_stats = ABYSS_FAC.out.assembly_stats
        lr_mappings = PBMM_MAPLONG.out.mapped_lr

}
