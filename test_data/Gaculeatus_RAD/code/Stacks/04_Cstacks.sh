#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=06:00:00
#SBATCH --tasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --export=NONE
#SBATCH --job-name=Catalog
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err



## Load in Stacks
STACKS_INSTALL=/storage/homefs/dj20y461/Software/stacks-2.68

## Set some directories
POPMAP=/storage/homefs/dj20y461/Infersex/InferSex/test_data/Gaculeatus_RAD/code/Stacks/popmap.txt
STACKS_DIR=/storage/scratch/iee/dj20y461/Stickleback/G_aculeatus/G_aculeatus_RAD/Stacks

$STACKS_INSTALL/cstacks -P $STACKS_DIR -M $POPMAP -n 4 -p 16
