#!/bin/bash
#SBATCH --job-name=STAR
#SBATCH --partition=batch
#SBATCH --nodes=4
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=4:00:00
#SBATCH --output=log.%J
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --dependency=afterok:8186700
#SBATCH --mem=100G
#SBATCH -a 0

#####Modify parameter
threads=16
input=(BL6_REP1 BL6_REP2)
dir='/home/longy/project/Split_BL6' ####Parental Directory
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/mm10len100"

sam=${input[$SLURM_ARRAY_TASK_ID]} #####Get Sample Name
fq1="/home/longy/workspace/apa_predict/fastq/${sam}_1.fastq.gz"
fq2="/home/longy/workspace/apa_predict/fastq/${sam}_2.fastq.gz"
inp=$dir/STAR/$sam                      ###Working Directory
if [ ! -d $dir/STAR ];then
	mkdir -p $dir/STAR
fi
if [ ! -d $inp ];then
	mkdir -p $inp
fi
cd $inp                      #####Go to Working Directory

time_start=$(date +"%s")
echo "job start at" `date "+%Y-%m-%d %H:%M:%S"`
echo "This is job #${SLURM_ARRAY_JOB_ID}, with parameter ${input[$SLURM_ARRAY_TASK_ID]}"
echo "My hostname is: $(hostname -s)"
echo "My task ID is $SLURM_ARRAY_TASK_ID"
echo


#fastqc $fq1
#echo 'cut adapter'
#cutadapt -j $threads --minimum-length=50 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o $trfq1 -p $trfq2 $fq1 $fq2
#cutadapt -j $threads --minimum-length=15 -a TGGAATTCTCGGGTGCCAAGG -o $trfq1 $fq1


echo 'starting mapping with STAR'
echo "mapping with $sam"

#STAR  --twopassMode Basic --runThreadN $threads --genomeDir $genomeIndex  --readFilesIn $fq1 $fq2 --outSAMtype BAM SortedByCoordinate --outSAMattrIHstart 0  --outFilterMultimapScoreRange 0  --alignEndsType Local  --readFilesCommand zcat --outFilterIntronMotifs RemoveNoncanonicalUnannotated --outSAMstrandField intronMotif --outReadsUnmapped Fastq --outWigType wiggle  --outWigNorm None --limitBAMsortRAM 40000000000 


###ENCODE
#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
srun STAR  --twopassMode Basic --runThreadN $threads --genomeDir $genomeIndex  --readFilesIn $fq1 $fq2 --outSAMtype BAM SortedByCoordinate --outSAMattrIHstart 0  --outFilterMultimapScoreRange 0  --alignEndsType Local  --readFilesCommand zcat  --outSAMstrandField intronMotif --outFilterType BySJout --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --outWigType wiggle --outWigNorm None

var1='fefa'
if [ $var1 = 'fefa' ];then
	echo $var1
else
	echo 'nono'
fi



####INDEX for sorted bam file
echo 'generating index with samtools'
#samtools index -@ $threads Aligned.sortedByCoord.out.bam

echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($duration/3600)):$((($duration/60)%60)):$(($duration % 60))"
