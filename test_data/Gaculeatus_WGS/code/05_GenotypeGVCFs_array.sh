#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=99G
#SBATCH --export=NONE
#SBATCH --job-name=GT_GVCFs
#SBATCH --array=4
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

module load Java
GATK=/storage/homefs/dj20y461/Software/gatk-4.6.1.0/gatk

WD=/storage/scratch/iee_evol/sascha/SIAS/test_data/G_aculeatus

INTERVALS=/storage/scratch/iee_evol/sascha/SIAS/test_data/G_aculeatus/Intervals_GVCF.txt
INTERVAL=$(sed -n "${SLURM_ARRAY_TASK_ID}p" < $INTERVALS)

ASSEMBLY=/storage/homefs/dj20y461/Stickleback/G_aculeatus/FITNESS/ref/GCF_016920845.1_GAculeatus_UGA_version5_genomic_shortnames_noY.fna
GENDB=$WD/GenDBs/GenDB_${INTERVAL}
OUTDIR=$WD/Joint_VCFs/Joint_${INTERVAL}/

if [ ! -d $OUTDIR ]; then
   mkdir -p $OUTDIR
fi

$GATK GenotypeGVCFs \
   -R ${ASSEMBLY} \
   -V gendb://${GENDB} \
   -O ${OUTDIR}/${INTERVAL}.vcf 



