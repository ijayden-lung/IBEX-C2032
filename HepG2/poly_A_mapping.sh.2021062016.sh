#!/bin/bash
#SBATCH --job-name=PolyAMap
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=4:00:00
#SBATCH --mem=50G
##SBATCH -a 0
##SBATCH --gres=gpu:1


fq1="/home/longy/project/Split_BL6/STAR/K562_Chen/K562-3-seq_R1_001.fastq.gz"
fq2="/home/longy/project/Split_BL6/STAR/K562_Chen/K562-3-seq_R2_001.fastq.gz"
trimfq1="/home/longy/project/Split_BL6/STAR/K562_Chen/trimmed/K562-3-seq_R1_001.fastq.gz"
trimfq2="/home/longy/project/Split_BL6/STAR/K562_Chen/trimmed/K562-3-seq_R2_001.fastq.gz"
cutfq1="/home/longy/project/Split_BL6/STAR/K562_Chen/trimmed/K562-3-seq_cutpolyA_R1_001.fastq.gz"
cutfq2="/home/longy/project/Split_BL6/STAR/K562_Chen/trimmed/K562-3-seq_cutpolyA_R2_001.fastq.gz"

#fq1="/home/longy/project/Split_BL6/STAR/K562_3seq/K562-3-seq_R1_001.fastq.gz"
#fq2="/home/longy/project/Split_BL6/STAR/K562_3seq/K562-3-seq_R2_001.fastq.gz"
#trimfq1="/home/longy/project/Split_BL6/STAR/K562_3seq/K562-3-seq_cutadapt_R1_001.fastq.gz"
#trimfq2="/home/longy/project/Split_BL6/STAR/K562_3seq/K562-3-seq_cutadapt_R2_001.fastq.gz"
#cutfq1="/home/longy/project/Split_BL6/STAR/K562_3seq/K562-3-seq_cutpolyA_R1_001.fastq.gz"
#cutfq2="/home/longy/project/Split_BL6/STAR/K562_3seq/K562-3-seq_cutpolyA_R2_001.fastq.gz"
ADAPTER_FWD=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
ADAPTER_REV=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
#cutadapt --minimum-length 30  -a N{12}$ADAPTER_FWD -A $ADAPTER_REV -q 20 -j 32 -o $trimfq1 -p $trimfq2 $fq1 $fq2
#cutadapt --minimum-length 30  -g "T{18}N{2}"  -A "N{2}A{18}" -q 20 -j 32  -o $cutfq1 -p $cutfq2 $trimfq1 $trimfq2

genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len75"
#cd /home/longy/project/Split_BL6/STAR/K562_3seq/
fq1="/home/longy/project/polyAseq_data/61_GAAGTG_S61_R1_001.fastq.gz"
STAR  --twopassMode None --runThreadN 32 --genomeDir $genomeIndex  --readFilesIn $fq1  --outSAMtype BAM Unsorted  --outSAMattrIHstart 0  --outFilterMultimapScoreRange 0  --alignEndsType EndToEnd  --readFilesCommand zcat --limitBAMsortRAM 40000000000  --outReadsUnmapped Fastx --outFilterType BySJout --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000  --alignMatesGapMax 1000000
