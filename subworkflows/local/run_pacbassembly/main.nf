//
// Subworkflow - assembly
//

include { CANU_ASSEMBLY }                        from '../../../modules/local/software/canu/assemblereads'
include { PBMM_MAPLONG as PBMM_MAPPRIMARY }      from '../../../modules/local/software/pbmm/maplongreads'
include { PBMM_MAPLONG as PBMM_MAPSCAFFOLD }     from '../../../modules/local/software/pbmm/maplongreads'
include { ABYSS_FAC }                            from '../../../modules/local/software/abyss/abyssfac-stats'
include { NTJOIN_SCAFFOLD }                      from '../../../modules/local/software/ntjoin/scaffoldassembly'

workflow ASSEMBLY_PIPELINE {

    take:
        assembly_lr // tuple [sample, lr_reads ]
        assembly_sr // tuple [sample, sr1_reads, sr2_reads]    

    main:

	// run primary assembly
        CANU_ASSEMBLY_OUT = CANU_ASSEMBLY(assembly_lr)
        ABYSS_FAC(CANU_ASSEMBLY_OUT.assembly)
	PBMM_MAPPRIMARY(
		assembly_lr,
		CANU_ASSEMBLY.out.assembly
		)
	
	// scaffold if reference genome is provided        
        if (params.ntjoin_ref) {
            // ntJoin scaffolding
	    Channel.fromPath( params.ntjoin_ref, checkIfExists: true)
				.set { ntJoin_input_ref }
	    NTJOIN_SCAFFOLD(CANU_ASSEMBLY.out.assembly,	ntJoin_input_ref)
	    PBMM_MAPSCAFFOLD(assembly_lr,
			 NTJOIN_SCAFFOLD.out.assembly
			)
        }

        // Collect outputs
        //all_outputs = CANU_ASSEMBLY_OUT.assembly.map { it -> Channel.of(it[1]) }
        //if (params.ntjoin_ref) {
       	//	all_outputs = all_outputs.mix(NTJOIN_SCAFFOLD.out.assembly.map { it -> Channel.of(it[1]) })
        //	}
        //all_outputs.collect()
	//	.set { combined_outputs }
	//combined_outputs.view()
	//ABYSS_FAC(combined_outputs)

    emit:
        versions    = CANU_ASSEMBLY.out.versions
        lr_stats    = ABYSS_FAC.out.assembly_stats
        lr_mappings = PBMM_MAPPRIMARY.out.mapped_lr
	lr_scaffold = PBMM_MAPSCAFFOLD.out.mapped_lr
	scaffolded  = NTJOIN_SCAFFOLD.out.assembly
	

}
