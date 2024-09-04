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

        // Default suffix
        nam_suffix = ''

        // Long read scaffolding (ntLink)
        if (params.ntlink_run) {
            ASSEMBLY = NTLINK_SCAFFOLD(ASSEMBLY.assembly, assembly_lr)
            nam_suffix = ".ntlink"

            assembly_lr_scaf_channel = true // Flag to indicate ntLink ran
        }

        // NTJoin scaffolding (either after ntLink or standalone if only ntjoin_ref is provided)
        if (params.ntjoin_ref) {

            if (file(params.ntjoin_ref).exists()) {
                ntJoin_input_ref = file(params.ntjoin_ref)
            } else {
                throw new FileNotFoundException("File ${params.ntjoin_ref} does not exist.")
            }

            nam_suffix = assembly_lr_scaf_channel ? ".ntlink.ntjoin" : ".ntjoin"
            ASSEMBLY = NTJOIN_SCAFFOLD(ASSEMBLY.assembly, ntJoin_input_ref)
        }

        // ** After the `if` blocks, do the necessary mapping based on final suffix **
        
        // For ntLink
        assembly_lr.map { val, path -> tuple("${val}${nam_suffix}", path) }
                   .set { assembly_lr_scaf }
        assembly_lr_scaf.join(ASSEMBLY.assembly)
                        .set { ch_readslr_assembly_scaf }

        // View to check output during this step
        assembly_lr_scaf.view()

        def cov_scaf_output = COV_SCAF(ch_readslr_assembly_scaf)

        // For NTJoin
        assembly_lr.map { val, path -> tuple("${val}${nam_suffix}", path) }
                   .set { assembly_lr_scafref }
        assembly_lr_scafref.join(ASSEMBLY.assembly)
                           .set { ch_readslr_assembly_scaf_ref }

        def cov_scafref_output = COV_SCAFREF(ch_readslr_assembly_scaf_ref)

        // Map assembly outputs
        ASSEMBLY.assembly
                .map { it -> it[1] }
                .mix(all_assemblies)
                .collect()
                .set { all_assemblies }

        // Run stats on final output
        ABYSS_FAC(all_assemblies)

    emit:
        versions = CANU_ASSEMBLY.out.versions
        scaffolded = ASSEMBLY.assembly
        // Uncomment the following if emitting these values
        // cov_scaf_output = cov_scaf_output
        // cov_scafref_output = cov_scafref_output
}

