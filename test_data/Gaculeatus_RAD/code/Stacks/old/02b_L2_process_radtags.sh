#!/bin/bash
#SBATCH -J L2_process_radtags
#SBATCH --nodes 1
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=8
#SBATCH --time=12:00:00
#SBATCH --mem=64G
#SBATCH --account=nperrin_rana_genome
#SBATCH --partition cpu
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

WD=/work/FAC/FBM/DEE/nperrin/rana_genome/EVA/
BARCODES=${WD}/raw/L2_barcodes.txt
OUTDIR=${WD}/demultiplexed/

module add stacks/2.53 

mkdir $OUTDIR

process_radtags \
	-f ${WD}/raw/tp125_L2_R1_001_mPDECwAzb0Ad.fastq.gz \
	-o $OUTDIR \
	-b $BARCODES \
	-r \
	-c \
	-q \
	-i gzfastq \
	-e sbfI 
