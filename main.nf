#!/usr/bin/env nextflow

//Call DSL2
nextflow.enable.dsl=2

/*  ======================================================================================================
 *  HELP MENU
 *  ======================================================================================================
 */
//ver = manifest.version


//Input parameters list
params.help      = null
params.outputdir = "results"

//--------------------------------------------------------------------------------------------------------
// Validation - validation from nf-core for input results

include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'

if (params.help) {
   log.info paramsHelp("nextflow run ...")
   exit 0
}

// Validate input parameters
validateParameters()

// Print summary of supplied parameters
log.info paramsSummaryLog(workflow)

//--------------------------------------------------------------------------------------------------------
// Main workflow 
include { PBFLOW_WORKFLOW } from './workflows/run_pacbassembly.nf'

workflow {

	PBFLOW_WORKFLOW()

}
