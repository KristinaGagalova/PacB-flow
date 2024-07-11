//
// Subworkflow - assembly
//

include { CANU_ASSEMBLY }                           from '../../../modules/local/software/canu/assemblereads'
include { PBMM_MAPLONG as PBMM_MAPPRIMARY }         from '../../../modules/local/software/pbmm/maplongreads'
include { PBMM_MAPLONG as PBMM_MAPSCAFFOLDREF }     from '../../../modules/local/software/pbmm/maplongreads'
include { PBMM_MAPLONG as PBMM_MAPSCAFFOLDREADS }   from '../../../modules/local/software/pbmm/maplongreads'
include { ABYSS_FAC }                               from '../../../modules/local/software/abyss/abyssfac-stats'
include { NTJOIN_SCAFFOLD }                         from '../../../modules/local/software/ntjoin/scaffoldassembly'
include { NTLINK_SCAFFOLD }                         from '../../../modules/local/software/ntlink/scaffoldassembly'

workflow ASSEMBLY_PIPELINE {

    take:
        assembly_lr // tuple [sample, lr_reads ]
        assembly_sr // tuple [sample, sr1_reads, sr2_reads]    

    main:
	//
	allAssembliesChannel = Channel.empty()

	// run primary assembly
        CANU_ASSEMBLY_OUT = CANU_ASSEMBLY(assembly_lr)
	PBMM_MAPPRIMARY(
		assembly_lr,
		CANU_ASSEMBLY_OUT.assembly
		)
        ASSEMBLY = CANU_ASSEMBLY_OUT
	ASSEMBLY.assembly
                .map { it -> it[1] }
                .mix(allAssembliesChannel)
                .collect()
                .set { all_assemblies}
	
        // run scaffolding with long reads
	if (params.ntlink_run) {
	    // ntLink scaffolding
            ASSEMBLY = NTLINK_SCAFFOLD(
	    		ASSEMBLY.assembly,
	    		assembly_lr
			)
	    PBMM_MAPSCAFFOLDREADS(assembly_lr,
                         ASSEMBLY.assembly
                        )
	    ASSEMBLY.assembly
                	.map { it -> it[1] }
                	.mix(all_assemblies)
                	.collect()
                	.set { all_assemblies }
	
	} 
	
	if (params.ntjoin_ref) {
	    // ntJoin scaffolding
            Channel.fromPath( params.ntjoin_ref, checkIfExists: true )
                                .set { ntJoin_input_ref }
            ASSEMBLY = NTJOIN_SCAFFOLD(ASSEMBLY.assembly, ntJoin_input_ref)
            PBMM_MAPSCAFFOLDREF(assembly_lr,
                        ASSEMBLY.assembly
                        )

	    ASSEMBLY.assembly
                .map { it -> it[1] }
                .mix(all_assemblies)
                .collect()
                .set { all_assemblies }
	}
	
	// run stats on final output   
	ABYSS_FAC(all_assemblies)

    emit:
        versions    = CANU_ASSEMBLY.out.versions
        //lr_stats    = ABYSS_FAC.out.assembly_stats
	scaffolded  = ASSEMBLY.assembly
	

}
