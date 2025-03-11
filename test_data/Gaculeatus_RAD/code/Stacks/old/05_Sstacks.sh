#!/bin/bash

#SBATCH --account=nperrin_rana_genome
#SBATCH --partition=cpu
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=99G
#SBATCH --export=NONE
#SBATCH --array=1-140
#SBATCH --job-name=Sstacks_EVA
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err


## Set some directories 

STACKS_DIR=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/Stacks/

## File containing a list of sample names to iterate over in the array. 

ITERFILE=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/scripts/samples.txt

SAMPLE=$(sed -n ${SLURM_ARRAY_TASK_ID}p $ITERFILE | cut -f1)  ## Use a sed one-liner and the SLURM_ARRAY_TASK_ID to get the appropriate line in the $ITERFILE

## Load in Stacks

module load UHTS/Analysis/stacks/2.3e

echo "sstacks -c ${STACKS_DIR} -s ${STACKS_DIR}/${SAMPLE} -o $STACKS_DIR -p 4"

sstacks -c ${STACKS_DIR} -s ${STACKS_DIR}/${SAMPLE} -o $STACKS_DIR -p 4

