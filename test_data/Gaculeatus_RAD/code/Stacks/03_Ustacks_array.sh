#!/bin/bash
#SBATCH --partition=bdw
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=80G
#SBATCH --export=NONE
#SBATCH --array=2-27
#SBATCH --job-name=Ustacks_EVA
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

## File containing a list of sample names to iterate over in the array. 

ITERFILE=/storage/homefs/dj20y461/Infersex/InferSex/test_data/Gaculeatus_RAD/code/Stacks/sample_names.txt
SAMPLE=$(sed -n ${SLURM_ARRAY_TASK_ID}p $ITERFILE) 

R1_DIR=/storage/research/iee_evol/Sascha/sascha/SIAS/test_data/G_aculeatus_RAD/fastqs
STACKS_DIR=/storage/scratch/iee/dj20y461/Stickleback/G_aculeatus/G_aculeatus_RAD/Stacks

if [ ! -d $STACKS_DIR ]; then
        mkdir $STACKS_DIR
fi

## Load in Stacks

STACKS_INSTALL=/storage/homefs/dj20y461/Software/stacks-2.68

## Ustacks command for parents - using -M 2

$STACKS_INSTALL/ustacks -f ${R1_DIR}/${SAMPLE}.fastq -i $SLURM_ARRAY_TASK_ID -o $STACKS_DIR -M 2 -m 6 -p 20 -d  ## pass all the bash variables we have made to Ustacks. 

