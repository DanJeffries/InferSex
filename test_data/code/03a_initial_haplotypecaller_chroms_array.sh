#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=01:00:00
#eBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=99G
#SBATCH --export=NONE
#SBATCH --array=44-80 #81-10080 
#SBATCH --job-name=HapCall_chroms
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

module load Java
GATK=/storage/homefs/dj20y461/Software/gatk-4.6.1.0/gatk

WD=/storage/scratch/iee_evol/sascha/SIAS/test_data/G_aculeatus

## Note I split the chromosomes and the unplaced contigs, as they will take very different times to finish, thus hopefully I can make more efficient resource requests. 
ITERFILE=/storage/homefs/dj20y461/Infersex/InferSex/test_data/code/sample_chrom_intervals.list

## Too many array jobs for the schedular and can't use numbers above 10k, so adding 10k to each array number past the first 10k to get the right file line. 

JOB_N=$SLURM_ARRAY_TASK_ID

SAMPLE_NAME=$(sed -n "${JOB_N}p" < $ITERFILE | cut -f1)
INTERVAL=$(sed -n "${JOB_N}p" < $ITERFILE | cut -f2)

GENOME=/storage/research/iee_evol/DanJ/Stickleback/G_aculeatus/FITNESS/ref/GCF_016920845.1_GAculeatus_UGA_version5_genomic_shortnames_noY.fna
DICT=/storage/research/iee_evol/DanJ/Stickleback/G_aculeatus/FITNESS/ref/GCF_016920845.1_GAculeatus_UGA_version5_genomic_shortnames_noY.dict

if [ ! -d "$DICT" ]; then
   $GATK CreateSequenceDictionary R=$GENOME O=$DICT
fi

BAM_DIR=$WD/bams
GVCF_DIR=$WD/GVCF

if [ ! -d "$GVCF_DIR" ]; then
   mkdir $GVCF_DIR
fi

BAM=${BAM_DIR}/${SAMPLE_NAME}.fixmate.coordsorted.bam

GVCF=${GVCF_DIR}/${SAMPLE_NAME}_${INTERVAL}.g.vcf.gz

$GATK HaplotypeCaller \
	-R $GENOME \
	-I $BAM \
	-L $INTERVAL \
	-ERC GVCF \
	--output $GVCF

