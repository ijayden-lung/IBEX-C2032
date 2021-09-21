#!/bin/bash
#
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --time=01:00:00
#SBATCH --mem=64G
#SBATCH --mincpus=30

cd /ibex/scratch/zhanb0d/SMAD4
module load cutadapt
module load samtools
#SAMPLE=5g_1_4_N345-20_S103_L001
SAMPLE=${1}
echo processing $SAMPLE
ADAPTER_FWD=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
ADAPTER_REV=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
DATA_PATH=./raw_data
if [ ! -f ./trimmed/$SAMPLE.trimmed_1.cut2.fastq.gz ]; then
        echo start trimming
        cutadapt --minimum-length 30 -a $ADAPTER_FWD -A $ADAPTER_REV -q 20 -j 30 -o ./trimmed/$SAMPLE.trimmed_1.fastq.gz -p ./trimmed/$SAMPLE.trimmed_2.fastq.gz $DATA_PATH/$SAMPLE'_R1_001.fastq.gz' $DATA_PATH/$SAMPLE'_R2_001.fastq.gz' > log.cut1.$SAMPLE
		#cutadapt --minimum-length 30 -g "^T{20}" -j 30 -o ./trimmed/$SAMPLE.trimmed_1.cut2.fastq.gz ./trimmed/$SAMPLE.trimmed_1.fastq.gz > log.cut2.$SAMPLE
		perl cut.leading.nucleotides.pl ./trimmed/$SAMPLE.trimmed_1.fastq.gz ./trimmed/$SAMPLE.trimmed_1.cut2.fastq ^T+ > log.cut2.$SAMPLE
		gzip ./trimmed/$SAMPLE.trimmed_1.cut2.fastq

else
        echo trimming finished 
fi

echo running STAR 
GTF=/ibex/scratch/zhanb0d/genome/gencode.v37.annotation.gtf
GENOME_DIR=/ibex/scratch/zhanb0d/genome/star_index/hg38/149
OVERHANG=149
if [ ! -f ./star/$SAMPLE.Aligned.out.bam ]; then
        echo run STAR
		# only map the read1 
        STAR --runMode alignReads --runThreadN 30 --readFilesIn ./trimmed/$SAMPLE.trimmed_1.fastq.gz  \
        --readFilesCommand zcat --genomeDir $GENOME_DIR --sjdbGTFfile $GTF --outFileNamePrefix ./star/$SAMPLE. --sjdbOverhang $OVERHANG \
        --outReadsUnmapped Fastx --chimSegmentMin 20 --outSAMtype BAM Unsorted SortedByCoordinate --outWigType bedGraph --limitBAMsortRAM 60011450942
else
        echo STAR is compelete 
fi

echo running featuteCounts 
if [ ! -f ./count/$SAMPLE.gene.reverse.count ]; then
    echo run featureCounts
   featureCounts -a $GTF -o ./count/$SAMPLE.gene.reverse.count ./star/$SAMPLE.Aligned.out.bam -s 2 -F GTF -T 30 -O
   featureCounts -a $GTF -o ./count/$SAMPLE.gene.forward.count ./star/$SAMPLE.Aligned.out.bam -s 1 -F GTF -T 30 -O
        
else
    echo counting finished
fi

