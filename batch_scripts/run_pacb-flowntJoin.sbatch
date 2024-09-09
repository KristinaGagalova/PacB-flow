#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=24GB #requirements may be high in case user downloads large images
#SBATCH --partition=work
#SBATCH --time=1-00:00:00
#SBATCH --account=y95
#SBATCH --mail-type=ALL
#SBATCH --export=NONE

module load nextflow/23.10.0
module load singularity/4.1.0-slurm

# IMPORTANT: singularity cache dir needs to be specified in order to download image when running default
export NXF_SINGULARITY_CACHEDIR="./work"

nextflow run ./main.nf -resume \
	-profile pawsey_setonix,singularity \
	--manifest samples.tsv \
	--ntjoin_ref '/scratch/y95/kgagalova/projectPaoTheen/reads/canu2/GCA_900231935.2_ERZ478497_genomic.fna' \
        --ntjoin_ref_weights '2' \
        --ntjoin_w 500 \
        --ntjoin_k 24 \
	--ntjoin_no_cut 'True'
