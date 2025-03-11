#!/bin/bash

#SBATCH --account=nperrin_rana_genome
#SBATCH --partition=cpu
#SBATCH --time=02-00:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=128G
#SBATCH --export=NONE
#SBATCH --job-name=Populations_field_adults
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err


## Set some directories 

STACKS_DIR=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/Stacks/
POPMAP=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/scripts/popmap_Field_adults.txt

POP_OUTDIR=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/Stacks/Populations_field_adults/

if [ ! -d $POP_OUTDIR ]; then
        mkdir $POP_OUTDIR
fi

## Load in Stacks

module load UHTS/Analysis/stacks/2.3e

populations 	-P $STACKS_DIR \
		-O $POP_OUTDIR \
		-M $POPMAP \
		-p 1 \
		-r 0.8 \
		--hwe \
		--vcf \
		-t 48 \
		
