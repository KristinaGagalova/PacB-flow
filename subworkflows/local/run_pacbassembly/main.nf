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

        // Run primary assembly
        CANU_ASSEMBLY_OUT = CANU_ASSEMBLY(assembly_lr)
        assembly_lr.join(CANU_ASSEMBLY_OUT.assembly)
                   .set { ch_readslr_assembly }
        COV_PRIMARY(ch_readslr_assembly)
        ASSEMBLY = CANU_ASSEMBLY_OUT
        ASSEMBLY.assembly
                .map { it -> it[1] }
                .mix(allAssembliesChannel)
                .collect()
                .set { all_assemblies }

        // Default suffix
        nam_suffix = ''

        // Long read scaffolding (ntLink) if ntlink_run is True
        if (params.ntlink_run) {

            ASSEMBLY = NTLINK_SCAFFOLD(ASSEMBLY.assembly, assembly_lr)
            nam_suffix = ".ntlink"

            // Update `assembly_lr_scaf` with suffix after ntLink
            assembly_lr.map { val, path -> tuple("${val}${nam_suffix}", path) }
                       .set { assembly_lr_scaf }
            // Join ntLink assembly and run COV_SCAF
            assembly_lr_scaf.join(ASSEMBLY.assembly)
                            .set { ch_readslr_assembly_scaf }
            // Run COV_SCAF at ntLink stage
            def cov_scaf_output = COV_SCAF(ch_readslr_assembly_scaf)

            // Ensure the assembly after ntLink is mixed into all assemblies
            ASSEMBLY.assembly
                    .map { it -> it[1] }
                    .mix(all_assemblies)
                    .collect()
                    .set { all_assemblies }

        }

        // NTJoin scaffolding (if ntjoin_ref is provided)
	// Run NTJoin scaffolding AFTER ntLink and COV_SCAF if both are used
	if (params.ntjoin_ref) {
		if (file(params.ntjoin_ref).exists()) {
                	        ntJoin_input_ref = file(params.ntjoin_ref)
                	} else {
                        	throw new FileNotFoundException("File ${params.ntjoin_ref} does not exist.")
                	}
	}

	if (params.ntlink_run && params.ntjoin_ref) {

    		// Wait for ntLink and COV_SCAF to finish before running NTJoin
    		ch_readslr_assembly_scaf
        		.set { delayed_assembly_lr_scaf }
    		// Now run NTJOIN_SCAFFOLD on the delayed channel
    		ASSEMBLY = NTJOIN_SCAFFOLD(ASSEMBLY.assembly, ntJoin_input_ref)

    		// Update `assembly_lr_scafref` with suffix after NTJoin
    		delayed_assembly_lr_scaf.map { val, reads, fasta -> tuple("${val}.ntjoin", reads) }
                	            .set { assembly_lr_scafref }

    		// Join NTJoin assembly and run COV_SCAFREF
    		assembly_lr_scafref.join(ASSEMBLY.assembly)
                	       .set { ch_readslr_assembly_scaf_ref }

    		// Run COV_SCAFREF at NTJoin stage
    		def cov_scafref_output = COV_SCAFREF(ch_readslr_assembly_scaf_ref)

		// Ensure the assembly after ntJoin is mixed into all assemblies
            	ASSEMBLY.assembly
                    .map { it -> it[1] }
                    .mix(allAssembliesChannel)
                    .collect()
                    .set { all_assemblies }

	} else if (params.ntjoin_ref) {
    		// If only ntJoin_ref is provided, run NTJOIN directly
    		ASSEMBLY = NTJOIN_SCAFFOLD(ASSEMBLY.assembly, ntJoin_input_ref)

    		// Update `assembly_lr_scafref` with suffix after NTJoin
    		assembly_lr.map { val, path -> tuple("${val}.ntjoin", path) }
               		.set { assembly_lr_scafref }

    		// Join NTJoin assembly and run COV_SCAFREF
		assembly_lr_scafref.join(ASSEMBLY.assembly)
                	.set { ch_readslr_assembly_scaf_refOnly	}

    		// Run COV_SCAFREF at NTJoin stage
    		def cov_scafref_output = COV_SCAFREF(ch_readslr_assembly_scaf_refOnly)
		
		// Ensure the assembly after ntJoin is mixed into all assemblies
            	ASSEMBLY.assembly
                    .map { it -> it[1] }
                    .mix(allAssembliesChannel)
                    .collect()
                    .set { all_assemblies }
	}
	
        // Run stats on final output
        ABYSS_FAC(all_assemblies)

    emit:
        versions = CANU_ASSEMBLY.out.versions
        scaffolded = ASSEMBLY.assembly
        // Uncomment the following if emitting these values
        // cov_scaf_output = cov_scaf_output
        // cov_scafref_output = cov_scafref_output
}
