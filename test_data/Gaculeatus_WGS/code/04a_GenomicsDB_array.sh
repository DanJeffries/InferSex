#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=99G
#SBATCH --export=NONE
#SBATCH --array=2-21
#SBATCH --job-name=GenDB_INT_array
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

module load Java
GATK=/storage/homefs/dj20y461/Software/gatk-4.6.1.0/gatk

WD=/storage/scratch/iee_evol/sascha/SIAS/test_data/G_aculeatus

SAMPLE_MAP_TEMPLATE=/storage/homefs/dj20y461/Infersex/InferSex/test_data/code/GVCF_sample_map_template.txt
INTERVALS=/storage/scratch/iee_evol/sascha/SIAS/test_data/G_aculeatus/Intervals_GVCF.txt
INTERVAL=$(sed -n "${SLURM_ARRAY_TASK_ID}p" < $INTERVALS)

SAMPLE_MAP_DIR=/storage/homefs/dj20y461/Infersex/InferSex/test_data/code/GVCF_sample_maps

if [ ! -d $SAMPLE_MAP_DIR ]; then
   mkdir $SAMPLE_MAP_DIR
fi

SAMPLE_MAP=$SAMPLE_MAP_DIR/GVCF_sample_map_${INTERVAL}.txt

sed "s/XXX/$INTERVAL/g" $SAMPLE_MAP_TEMPLATE > $SAMPLE_MAP

GenDB_DIR=$WD/GenDB_${INTERVAL}/

TMP_DIR=/storage/scratch/iee_evol/sascha/SIAS/test_data/G_aculeatus/GenDB_temp

if [ ! -d $TMP_DIR ]; then
   mkdir $TMP_DIR
fi

## remove any previous attempts at making the genDB 

if [ -d $GenDB_DIR ]; then
   rm ${GenDB_DIR}* -rf
   rmdir $GenDB_DIR
fi

READER_THREADS=16

$GATK GenomicsDBImport \
	--sample-name-map $SAMPLE_MAP \
	--tmp-dir $TMP_DIR \
	--intervals $INTERVAL\
	--genomicsdb-workspace-path $GenDB_DIR \
	--reader-threads $READER_THREADS \
	--consolidate \
	--verbosity DEBUG

#$GATK --java-options "-Xmx128g -Xms128g" GenomicsDBImport \
