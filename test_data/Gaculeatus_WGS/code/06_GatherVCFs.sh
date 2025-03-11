#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --export=NONE
#SBATCH --job-name=Gather
#SBATCH --output=%x_%A.out
#SBATCH --error=%x_%A.err

module load Java
GATK=/storage/homefs/dj20y461/Software/gatk-4.6.1.0/gatk

WD=/storage/scratch/iee_evol/sascha/SIAS/test_data/G_aculeatus/
VCFs_LIST=/storage/homefs/dj20y461/Infersex/InferSex/test_data/code/joint_vcf_paths.txt
OUTDIR=$WD/Unfiltered_VCF

if [ ! -d "$OUTDIR" ]; then
   mkdir $OUTDIR
fi

$GATK GatherVcfs \
   -I $VCFs_LIST \
   -O $OUTDIR/Joint_all_unfiltered.vcf


