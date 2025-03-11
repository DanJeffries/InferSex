#!/bin/bash

#SBATCH --account=nperrin_rana_genome
#SBATCH --partition=cpu
#SBATCH --time=02-00:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=128G
#SBATCH --export=NONE
#SBATCH --job-name=Populations_ALL
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

## Set some directories 

STACKS_DIR=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/Stacks/
POPMAP=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/scripts/popmap.txt

POP_OUTDIR=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/Stacks/Populations_ALL_write_single/

if [ ! -d $POP_OUTDIR ]; then
        mkdir $POP_OUTDIR
fi

## Load in Stacks

module load UHTS/Analysis/stacks/2.3e

populations 	-P $STACKS_DIR \
		-O $POP_OUTDIR \
		-M $POPMAP \
		-p 3 \
		-r 0.8 \
		--write-single-snp \
		--hwe \
		--vcf \
		--plink \
		-t 48 \
		
