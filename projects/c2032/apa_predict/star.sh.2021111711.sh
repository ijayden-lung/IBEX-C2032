#!/bin/bash
#PBS -q fat
#PBS -N STAR
#PBS -l nodes=1:ppn=6
#PBS -o ${out}
#PBS -j oe 
#PBS -l walltime=12:00:00
fq1=$1
fq2=$2
genomeIndex=$3
inp=$4

if [ ! -d ${inp} ];then
	mkdir -p ${inp}
fi
cd $inp
echo 'starting mapping with STAR'

#STAR  --runThreadN 6 --genomeDir /home/longy/cnda/STAR_INDEX/$genomeIndex  --readFilesIn $fq1 $fq2 --outSAMtype BAM SortedByCoordinate --outSAMattrIHstart 0  --outFilterMultimapScoreRange 0  --alignEndsType EndToEnd  --readFilesCommand zcat --outFilterIntronMotifs RemoveNoncanonicalUnannotated --outSAMstrandField intronMotif --bamRemoveDuplicatesType UniqueIdenticalNotMulti  -outReadsUnmapped Fastq --outWigType wiggle  --outWigNorm None --limitBAMsortRAM 20000000000 --sjdbFileChrStartEnd /home/longy/workspace/apa_predict/SPR_SJ.out.tab

####INDEX for sorted bam file
echo 'generating index with samtools'
samtools index -@ 6 Aligned.sortedByCoord.out.bam

echo 'finished'
