//
// Subworkflow - assembly
//

include { CANU_ASSEMBLY }                           from '../../../modules/local/software/canu/assemblereads'
//include { PBMM_MAPLONG as PBMM_MAPPRIMARY }         from '../../../modules/local/software/pbmm/maplongreads'
//include { PBMM_MAPLONG as PBMM_MAPSCAFFOLDREF }     from '../../../modules/local/software/pbmm/maplongreads'
//include { PBMM_MAPLONG as PBMM_MAPSCAFFOLDREADS }   from '../../../modules/local/software/pbmm/maplongreads'
include { ABYSS_FAC }                               from '../../../modules/local/software/abyss/abyssfac-stats'
include { NTJOIN_SCAFFOLD }                         from '../../../modules/local/software/ntjoin/scaffoldassembly'
include { NTLINK_SCAFFOLD }                         from '../../../modules/local/software/ntlink/scaffoldassembly'
include { COVERAGE_CALCULATE as COV_PRIMARY }       from '../../../subworkflows/local/calculate_coverage/main'
include { COVERAGE_CALCULATE as COV_SCAF }          from '../../../subworkflows/local/calculate_coverage/main'
include { COVERAGE_CALCULATE as COV_SCAFREF }       from '../../../subworkflows/local/calculate_coverage/main'

workflow ASSEMBLY_PIPELINE {

    take:
        assembly_lr // tuple [sample, lr_reads ]
        assembly_sr // tuple [sample, sr1_reads, sr2_reads]    

    main:
	//
	allAssembliesChannel = Channel.empty()

	// run primary assembly
        CANU_ASSEMBLY_OUT = CANU_ASSEMBLY(assembly_lr)
	assembly_lr.join(CANU_ASSEMBLY_OUT.assembly)
                        .set { ch_readslr_assembly }

        COV_PRIMARY(ch_readslr_assembly)
        ASSEMBLY = CANU_ASSEMBLY_OUT
	ASSEMBLY.assembly
                .map { it -> it[1] }
                .mix(allAssembliesChannel)
                .collect()
                .set { all_assemblies}
	
        // run scaffolding with long reads
	def nam_suffix = ''
	if (params.ntlink_run) {
	    // ntLink scaffolding
            ASSEMBLY = NTLINK_SCAFFOLD(
	    		ASSEMBLY.assembly,
	    		assembly_lr
			)
	    // rename input lr
	    nam_suffix = "${nam_suffix}.ntlink"
	    assembly_lr
    		.map { val, path -> tuple("${val}${nam_suffix}", path) }
		.set { assembly_lr_scaf }
            assembly_lr_scaf.join(ASSEMBLY.assembly)
                	.set { ch_readslr_assembly_scaf }
	    
	    COV_SCAF(ch_readslr_assembly_scaf)
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
	    nam_suffix = "${nam_suffix}.ntjoin"
            assembly_lr
                .map { val, path -> tuple("${val}${nam_suffix}", path) }
                .set { assembly_lr_scafref }
	    assembly_lr_scafref.join(ASSEMBLY.assembly)
                        .set { ch_readslr_assembly_scaf_ref }
	    COV_SCAFREF(ch_readslr_assembly_scaf_ref)

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
