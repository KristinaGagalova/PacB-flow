//
// Subworkflow 
//

include { CANU_ASSEMBLY } from '../../../modules/local/software/canu/assemblereads'


workflow ASSEMBLY_PIPELINE {

    take:
        assembly_lr // tuple [sample, lr_reads ]
        assembly_sr // tuple [sample, sr1_reads, sr2_reads]    

    main:
        // run primary assembly
        CANU_ASSEMBLY(assembly_lr)    
  
    emit:
        versions = CANU_ASSEMBLY.out.versions

}
