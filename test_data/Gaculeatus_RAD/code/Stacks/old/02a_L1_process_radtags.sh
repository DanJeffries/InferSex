#!/bin/bash
#SBATCH -J process_radtags
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
BARCODES=${WD}/raw/L1_barcodes.txt
OUTDIR=${WD}/demultiplexed/

module add stacks/2.53 

mkdir $OUTDIR

process_radtags \
	-f ${WD}/raw/616_L1_R1_001_kA8xO8JFY6tD.fastq.gz \
	-o $OUTDIR \
	-b $BARCODES \
	-r \
	-c \
	-q \
	-i gzfastq \
	-e sbfI 
