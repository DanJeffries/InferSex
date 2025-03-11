#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=01:00:00
#SBATCH --tasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --export=NONE
#SBATCH --array=1-27
#SBATCH --job-name=Sstacks
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err


## Load in Stacks
STACKS_INSTALL=/storage/homefs/dj20y461/Software/stacks-2.68

## Set some directories
POPMAP=/storage/homefs/dj20y461/Infersex/InferSex/test_data/Gaculeatus_RAD/code/Stacks/popmap.txt
STACKS_DIR=/storage/scratch/iee/dj20y461/Stickleback/G_aculeatus/G_aculeatus_RAD/Stacks

## File containing a list of sample names to iterate over in the array. 

ITERFILE=/storage/homefs/dj20y461/Infersex/InferSex/test_data/Gaculeatus_RAD/code/Stacks/sample_names.txt

SAMPLE=$(sed -n ${SLURM_ARRAY_TASK_ID}p $ITERFILE)  ## Use a sed one-liner and the SLURM_ARRAY_TASK_ID to get the appropriate line in the $ITERFILE

## Load in Stacks

echo "sstacks -c ${STACKS_DIR} -s ${STACKS_DIR}/${SAMPLE} -o $STACKS_DIR -p 4"

$STACKS_INSTALL/sstacks -c ${STACKS_DIR} -s ${STACKS_DIR}/${SAMPLE} -o $STACKS_DIR -p 4

