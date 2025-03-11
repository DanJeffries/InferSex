#!/bin/bash

#SBATCH --account=nperrin_rana_genome
#SBATCH --partition=cpu
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=180G
#SBATCH --export=NONE
#SBATCH --job-name=T2B
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err


## Set some directories 

STACKS_DIR=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/Stacks
POPMAP=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/scripts/popmap.txt

## Load in Stacks

module load gcc/9.3.0
module load stacks/2.53


tsv2bam -P $STACKS_DIR -M $POPMAP -t 32 

