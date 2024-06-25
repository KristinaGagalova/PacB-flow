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

## Output
```
results/processing/canu/*  #primary assemby and report
results/processing/abyss/* #assembly stats
results/processing/pbmm/*  #primary assembly long reads alignment
```
