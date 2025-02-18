#!/bin/bash

#SBATCH --partition=bdw
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --export=NONE
#SBATCH --array=182-189  
#SBATCH --job-name=Trim_align_and_filter_alignments
#SBATCH --output=%x_%A-%a.out
#SBATCH --error=%x_%A-%a.err

## load necassary modules

module add Trimmomatic/0.39-Java-11
module add BWA/0.7.17-GCC-10.3.0
module add samblaster/0.1.26-GCC-10.3.0
module add SAMtools/1.13-GCC-10.3.0
module add Sambamba/0.8.2-GCC-10.3.0

echo "start time" ## tracking how long it takes 
date

## Set some bash variables to control the sample used by each job. 

WD=/storage/scratch/iee_evol/sascha ## set working directory

ITER_FILE=/storage/homefs/dj20y461/Infersex/InferSex/test_data/sample_paths.txt  ## the job array will iterate over this file, which contains paths to each sample fastq files. 

SAMPLE_FASTQ_PATH=$(sed -n "${SLURM_ARRAY_TASK_ID}p" < $ITER_FILE)  ## assign a bash variable containing the file path (uses the array job number to take the corresponding line number from the list of file paths). 

SAMPLE_NAME=$(echo $SAMPLE_FASTQ_PATH | rev | cut -f1 -d'/' | rev) ## get just the sample name from the file path, for cleaner file naming later on. 

######### Trimming ##############################################################################################################################################################################################

# Raw sequencing data can contain low quality reads or read portions and erroneously incorporated adapter sequences. So "Read trimming" is done to remove as much of this bad data as possible. here we use a programme called trimmomatic. 

ADAPTERS=/software.9/software/Trimmomatic/0.39-Java-11/adapters/NexteraPE-PE.fa  ## list of illumina sequencing adapters to check for in the raw data

TRIMMED_OUTDIR=$WD/trimmed ## set the directory to output the trimmed data. 

## This loop checks to see if the directory is there, and if not, it creates it. 

if [ ! -d "$TRIMMED_OUTDIR" ]
then
    mkdir $TRIMMED_OUTDIR
fi

## Set names for the output files. The data are paired end, so there are 4 potential output files. One for each end containing data we want to keep. One for each end containing reads for which its partner (mate) was trimmed. The latter can be kept if needed, though this can affect SNP calling (which often relies on mate-pair aligning). 

SAMPLE_R1_trimmed=$TRIMMED_OUTDIR/${SAMPLE_NAME}.R1.trimmed.fastq.gz
SAMPLE_R1_unpaired=$TRIMMED_OUTDIR/${SAMPLE_NAME}.R1.unpaired.fastq.gz
SAMPLE_R2_trimmed=$TRIMMED_OUTDIR/${SAMPLE_NAME}.R2.trimmed.fastq.gz
SAMPLE_R2_unpaired=$TRIMMED_OUTDIR/${SAMPLE_NAME}.R2.unpaired.fastq.gz

## and now run trimmomatic. 

java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE \
	-threads 20 \
        $SAMPLE_FASTQ_PATH*_R1_*fastq.gz $SAMPLE_FASTQ_PATH*_R2_*fastq.gz \
        $SAMPLE_R1_trimmed $SAMPLE_R1_unpaired \
        $SAMPLE_R2_trimmed $SAMPLE_R2_unpaired \
        ILLUMINACLIP:${ADAPTERS}:3:30:10 SLIDINGWINDOW:4:20 MINLEN:25 HEADCROP:7


######### Aligning ##############################################################################################################################################################################################

# Once the data has been trimmed, we can align it to the genome. 

DATA_DIR=$WD/trimmed

GENOME_IDX=/storage/research/iee_evol/DanJ/Stickleback/G_aculeatus/FITNESS/ref/BWA/GCF_016920845.1_GAculeatus_UGA_version5_genomic_shortnames_noY

## Get the read group info to add to bams from the first read of every file

## "Read groups" refer to batches in the sequencing data production. E.g. reads that were produced by a specific sequencing machine, a specific flow cell, or a specific lane. Or for a specific library preparation (sample). Each of these can introduce batch effects in the sequencing data. If we add this info here, it will be stored in the alignment file and we can use it later to check for systematic errors in the data that correspond to any of these batch effects. 

## The read group information we need is in the raw data files, in the header of each read. It has a specific format so we can parse it and get the relevant info. 

HEADER=$(zcat $SAMPLE_R1_trimmed | head -n1) ## get first read ID line. Read group info is the same for all reads in each file, so we only need to check the first read to get the info we need. 

INSTRUMENT=$(echo $HEADER | cut -f1 -d':'| sed 's/@//g')
RUN=$(echo $HEADER | cut -f2 -d':')
FLOWCELL=$(echo $HEADER | cut -f3 -d':')
LANE=$(echo $HEADER | cut -f4 -d':')
BARCODES=$(echo $HEADER | cut -f2 -d' '| cut -f4 -d':' | sed 's/+/-/g')

echo "@RG\tID:${SAMPLE_NAME}\tPL:ILLUMINA\tPU:${FLOWCELL}.${LANE}\tSM:${SAMPLE_NAME}\tCN:MCGILL\tBC:${BARCODES}" ## the various bits of information we need are formatted into this readgroup string which will be added to the alignments. Note it will be different for every sample. 

echo $READGROUP_STRING

BAMDIR=$WD/bams/  ## set the directory for the alignment files to be output

## again make directory if needed. 

if [ ! -d "$BAMDIR" ]; then
   mkdir $BAMDIR
fi


## Read alignments to a genome can be messy. All sorts of errors can occur. For instance the two reads in a mate pair may not align near eachother, or in the correct orientation or the alignments can be low confidence. Sequence reads can also be "duplicates" of one another, in that multiple reads come from the same DNA fragment in the library. Ideally each read pair will come from a unique DNA library fragment, otherwise we introduce bias in SNP calling. However such duplicates can only be identified at the alignment stage (they will strt and end at exactly the same points in the genome). So, before we start SNP calling, we need to filter badly aligned or duplicated reads. The nice thing is that the tools for aligning and alignment filtering are easily combined using pipes "|" in bash. So below we align the trimmed fastq data using bwa mem, pipe the output straight to samblaster, which removes duplicates, then to samtools fixmate, which fixes or removes badly aligned mate pairs, and then we sort the bam, which is a requirement of a lot of downstream analyses.     

BAM_FIX_COORDSORT=${BAMDIR}/${SAMPLE_NAME}.fixmate.coordsorted.bam ##

bwa mem -t 20 \
        -R $(echo "@RG\tID:${SAMPLE_NAME}\tPL:ILLUMINA\tPU:${FLOWCELL}.${LANE}\tSM:${SAMPLE_NAME}\tCN:MCGILL\tBC:${BARCODES}") \
        $GENOME_IDX \
        $SAMPLE_R1_trimmed \
        $SAMPLE_R2_trimmed | \
samblaster | \
samtools fixmate \
	-m \
        -@ 20 \
        - \
	- | \
samtools sort \
	-@ 20 \
	-O BAM \
	-o $BAM_FIX_COORDSORT \
	-

samtools index -c -@ 20 $BAM_FIX_COORDSORT

## End time
echo "end time"
date




