#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --export=NONE
#SBATCH --array=1-480
#SBATCH --job-name=SAMSTATS
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

module load vital-it
module load UHTS/Analysis/samtools/1.10

## This script runs samtools stats and samtools coverage to calculate some simple stats summarising the read alignments. 

## use different iterfile than for the alignment. This one just has sample names, not full paths. This way we can give the directory containing the bams, rather than the path to the fastq. 
ITERFILE=/storage/research/iee_evol/Lou/Alaska_data/sample_names.txt
SAMPLE_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" < $ITERFILE) ## use iterfile to get the sample name

WD=/storage/scratch/iee/lm15k096/

samtools stats $WD/bams/${SAMPLE_NAME}.fixmate.coordsorted.bam > $WD/bams/${SAMPLE_NAME}.stats
samtools coverage $WD/bams/${SAMPLE_NAME}.fixmate.coordsorted.bam > $WD/bams/${SAMPLE_NAME}.depths

## Calculate some averages and add to the end of each file
egrep -v '#|chrUn|chrM' $WD/bams/${SAMPLE_NAME}.depths | awk '{ sum += $6; n++ } END { if (n > 0) print "\n## Avg. perc. bases. covered = " sum / n; }' >> $WD/bams/${SAMPLE_NAME}.depths
egrep -v '#|chrUn|chrM' $WD/bams/${SAMPLE_NAME}.depths | awk '{ sum += $7; n++ } END { if (n > 0) print "## Avg. coverage = " sum / n; }' >> $WD/bams/${SAMPLE_NAME}.depths

~
