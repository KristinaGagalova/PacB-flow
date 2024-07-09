# PacB-flow
PacBio long reads assebly workflow based on Nextflow.    


Summary of the workflow is shown below
![nf-pipeline](img/Nf-pacbflow.png)

## Nexflow pipeline
Nexflow version has to be >22.10.7, please install it following the instructions [here](https://www.nextflow.io/docs/latest/install.html).

## How to run the pipeline
The assembly requires significant memory usage, thus the use of an HPC is recommended. Local machines are not able to handle the high memory peak.    

Pawsey - Setonix run setup
```
nextflow run ./main.nf \
	-resume \
        -profile pawsey_setonix,singularity \
        --manifest samples.tsv
```

## Manifest file format
The manifest contains the pairing of short and long reads to be used for the assembly. An example of the manifest can be found in ```testrun_manifest/samples.csv```.    
```
sampleId,lr_reads,sr_read1,sr_read2
name,/path/to/longreads,/path/to/pair1,/path/to/pair2
```

## Scaffolding with reference genome
The pipeline will use a reference genome if provides and will use it for scaffolding with ntJoin pipeline. If not provided, it will skip this step. Please refer to the parameters for PacB-flow with scaffolding. Refer to the [ntJoin](https://github.com/bcgsc/ntJoin) code for more details.                 
ntJoin can get multiple genomes as an input; for simplicity, we only use one at the time here.    

Example script
```
nextflow run ./main.nf -resume \
        -profile pawsey_setonix,singularity \
        --manifest samples.tsv \
        --ntjoin_ref '/path/to/refgenome/PacB-flow/GCA_900231935.2_ERZ478497_genomic.fna' \ 
	--ntjoin_ref_weights '2' \ #string, weight for refernce genome
        --ntjoin_w 500 \ # window size
        --ntjoin_k 24 \ # kmer size
        --ntjoin_no_cut 'True' # do not cut input genome
```

## Output
```
results/processing/canu/*    #primary assemby and report
results/processing/abyss/*   #assembly stats
results/processing/pbmm/*    #primary assembly long reads alignment
results/processing/ntjoin/*  #scaffolded genome
```
