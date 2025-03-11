#!/bin/bash

#SBATCH --account=nperrin_rana_genome
#SBATCH --partition=cpu
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=128G
#SBATCH --export=NONE
#SBATCH --job-name=Catalog_EVA
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err


## Set some directories 

STACKS_DIR=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/Stacks/
POPMAP=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/scripts/popmap.txt

## Load in Stacks

module load UHTS/Analysis/stacks/2.3e

cstacks -P $STACKS_DIR -M $POPMAP -n 4 -p 8
