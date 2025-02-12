#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=01:00:00
#eBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=99G
#SBATCH --export=NONE
#SBATCH --array=1-80   
#SBATCH --job-name=HapCall_chroms
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

module load picard/2.25.5-Java-13

WD=/storage/scratch/iee_evol/lm15k096/

## Note I split the chromosomes and the unplaced contigs, as they will take very different times to finish, thus hopefully I can make more efficient resource requests. 
ITERFILE=/storage/scratch/iee_evol/lm15k096/FITNESS_selection_scan_LOU/code/sample_chrom_intervals.list

## Too many array jobs for the schedular and can't use numbers above 10k, so adding 10k to each array number past the first 10k to get the right file line. 
JOB_N=$(( $SLURM_ARRAY_TASK_ID + 10000 ))

SAMPLE_NAME=$(sed -n "${JOB_N}p" < $ITERFILE | cut -f1)
INTERVAL=$(sed -n "${JOB_N}p" < $ITERFILE | cut -f2)

GENOME=/storage/research/iee_evol/DanJ/Stickleback/G_aculeatus/FITNESS/ref/GCF_016920845.1_GAculeatus_UGA_version5_genomic_shortnames_noY.fna
DICT=/storage/research/iee_evol/DanJ/Stickleback/G_aculeatus/FITNESS/ref/GCF_016920845.1_GAculeatus_UGA_version5_genomic_shortnames_noY.dict

if [ ! -d "$DICT" ]; then
   java -jar $EBROOTPICARD/picard.jar CreateSequenceDictionary R=$GENOME O=$DICT
fi

BAM_DIR=$WD/bams
GVCF_DIR=$WD/GVCF

if [ ! -d "$GVCF_DIR" ]; then
   mkdir $GVCF_DIR
fi

export JAVA_HOME=/storage/homefs/lm15k096/software/jdk-17.0.12
export PATH=$JAVA_HOME/bin:$PATH

BAM=${BAM_DIR}/${SAMPLE_NAME}.fixmate.coordsorted.bam

GVCF=${GVCF_DIR}/${SAMPLE_NAME}_${INTERVAL}.g.vcf.gz

/storage/homefs/lm15k096/software/gatk-4.6.1.0/gatk HaplotypeCaller \
	-R $GENOME \
	-I $BAM \
	-L $INTERVAL \
	-ERC GVCF \
	--output $GVCF

#echo "job_N: $JOB_N"
#echo "sample_name: $SAMPLE_NAME"
#echo "interval: $INTERVAL"
