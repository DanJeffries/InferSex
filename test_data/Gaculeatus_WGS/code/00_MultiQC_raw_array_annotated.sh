#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --export=NONE
#SBATCH --job-name=MultiQC
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

# @ Lou - there is an issue with this programs installation on the cluster, which seems to have arisen since the last update. So don't worry about running this script now. I have already done it for these samples anyway and can tell you that everything is fine :) I included it here just so you can see that it is part of the process. 


## In this script we are running a program called "MultiQC", which runs some quality statistics on the raw data. This can be useful for informing the raw data processing needed before we align to the genome and call SNPs. 
## MultiQC actually takes, as input, the results of a different programe called FastQC. FastQC is the one that actually does the quality assessment. MultiQC just takes many FastQCs outputs and summarises them in useful ways.  

module load MultiQC/1.11-foss-2021a

## I put the fastqc outputs for the relevant here:

FASTQC_OUTPUTS_DIR=/storage/research/iee_evol/Lou/Alaska_fastqs_trimmed/fastqc_files

## make the output directory 

MULTIQC_OUTDIR=/storage/research/iee_evol/Lou/Alaska_fastqs_trimmed/MultiQC

if [ ! -d "$MULTIQC_OUTDIR" ]
then
    mkdir -p $MULTIQC_OUTDIR
fi  

## run multiqc

multiqc  $FASTQC_OUTPUTS_DIR -o $MULTIQC_OUTDIR

