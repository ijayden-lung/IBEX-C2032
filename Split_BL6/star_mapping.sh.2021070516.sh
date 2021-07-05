#!/bin/bash
#SBATCH --job-name=STAR
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=16:00:00
#SBATCH --output=log.%J
#SBATCH --error=err.%J
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --dependency=afterok:8186700
#SBATCH --mem=300G
#SBATCH -a 0

#####Modify parameter
threads=16
#input=(BL6_REP1 BL6_REP2)
#input=(HUM_Brain_REP1 HUM_Brain_REP2 HUM_Brain_REP3)
#input=(HepG2_ETF1)
dir='/home/longy/project/Split_BL6' ####Parental Directory

:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/mm10len100"
sam=${input[$SLURM_ARRAY_TASK_ID]} #####Get Sample Name
fq1="/home/longy/workspace/apa_predict/fastq/${sam}_1.fastq.gz"
fq2="/home/longy/workspace/apa_predict/fastq/${sam}_2.fastq.gz"
inp=$dir/STAR/bl6_rep1
BL

:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len100"
#fq1="/home/longy/project/Split_BL6/STAR/K562_zranb2/ENCFF880DON.fastq.gz"
#fq2="/home/longy/project/Split_BL6/STAR/K562_zranb2/ENCFF899MED.fastq.gz"
#fq3="/home/longy/project/Split_BL6/STAR/K562_zranb2/ENCFF308UBT.fastq.gz"
#fq4="/home/longy/project/Split_BL6/STAR/K562_zranb2/ENCFF953CAQ.fastq.gz"
#inp=$dir/STAR/K562_ZRANB2
BL


:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len149"
fq1="/home/longy/project/Split_BL6/STAR/K562_Chen/K562-mRNA_R1_001.fastq.gz"
fq2="/home/longy/project/Split_BL6/STAR/K562_Chen/K562-mRNA_R2_001.fastq.gz"
inp=$dir/STAR/K562_Chen
BL


:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len100"
fq1="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF970XPJ.fastq.gz"
fq2="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF295GVT.fastq.gz"
fq3="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF447YTB.fastq.gz"
fq4="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF210CQX.fastq.gz"
fq5="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF325DLF.fastq.gz"
fq6="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF616AQI.fastq.gz"
fq7="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF914FKR.fastq.gz"
fq8="/home/longy/project/Split_BL6/STAR/HepG2_Control/ENCFF838TBG.fastq.gz"
inp=$dir/STAR/HepG2_Control

:<<BL
#fq1="/home/longy/project/Split_BL6/STAR/HepG2_ETF1/ENCFF144IXI.fastq.gz"
#fq2="/home/longy/project/Split_BL6/STAR/HepG2_ETF1/ENCFF283BFT.fastq.gz"
#fq3="/home/longy/project/Split_BL6/STAR/HepG2_ETF1/ENCFF478SRL.fastq.gz"
#fq4="/home/longy/project/Split_BL6/STAR/HepG2_ETF1/ENCFF739UUY.fastq.gz"
#inp=$dir/STAR/HepG2_ETF1
#inp=$dir/STAR/HepG2_Merge
BL

:<<BL
fq1="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF312ANF.fastq.gz"
fq2="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF124WIZ.fastq.gz"
fq3="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF339ZUH.fastq.gz"
fq4="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF292HLM.fastq.gz"
fq5="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF326WTJ.fastq.gz"
fq6="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF767QZM.fastq.gz"
fq7="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF273KVQ.fastq.gz"
fq8="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF751LOM.fastq.gz"
fq9="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF743EKS.fastq.gz"
fq10="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF553PEN.fastq.gz"
fq11="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF352SRA.fastq.gz"
fq12="/home/longy/project/Split_BL6/STAR/K562_Control/ENCFF852RBO.fastq.gz"
inp=$dir/STAR/K562_Merge
BL

:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len75
fq1="/home/longy/project/Split_BL6/STAR/SNU398/SRR10022387_1.fastq.gz"
fq2="/home/longy/project/Split_BL6/STAR/SNU398/SRR10022387_2.fastq.gz"
fq3="/home/longy/project/Split_BL6/STAR/SNU398/SRR10022388_1.fastq.gz"
fq4="/home/longy/project/Split_BL6/STAR/SNU398/SRR10022388_2.fastq.gz"
inp=$dir/STAR/SNU398
BL
:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len149"
fq1="$dir/STAR/HUH7/ERR3284679_1.fastq.gz"
fq2="$dir/STAR/HUH7/ERR3284679_2.fastq.gz"
fq3="$dir/STAR/HUH7/ERR3284689_1.fastq.gz"
fq4="$dir/STAR/HUH7/ERR3284689_2.fastq.gz"
fq5="$dir/STAR/HUH7/ERR3284697_1.fastq.gz"
fq6="$dir/STAR/HUH7/ERR3284697_2.fastq.gz"
inp=$dir/STAR/HUH7
BL
:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len75"
fq1="$dir/STAR/THLE2/SRR8040781_1.fastq.gz"
fq2="$dir/STAR/THLE2/SRR8040781_2.fastq.gz"
fq3="$dir/STAR/THLE2/SRR8040782_1.fastq.gz"
fq4="$dir/STAR/THLE2/SRR8040782_2.fastq.gz"
fq5="$dir/STAR/THLE2/SRR8040783_1.fastq.gz"
fq6="$dir/STAR/THLE2/SRR8040783_2.fastq.gz"
fq7="$dir/STAR/THLE2/SRR8040784_1.fastq.gz"
fq8="$dir/STAR/THLE2/SRR8040784_2.fastq.gz"
fq9="$dir/STAR/THLE2/SRR8040785_1.fastq.gz"
fq10="$dir/STAR/THLE2/SRR8040785_2.fastq.gz"
fq11="$dir/STAR/THLE2/SRR8040786_1.fastq.gz"
fq12="$dir/STAR/THLE2/SRR8040786_2.fastq.gz"
fq13="$dir/STAR/THLE2/SRR8040787_1.fastq.gz"
fq14="$dir/STAR/THLE2/SRR8040787_2.fastq.gz"
fq15="$dir/STAR/THLE2/SRR8040788_1.fastq.gz"
fq16="$dir/STAR/THLE2/SRR8040788_2.fastq.gz"
fq17="$dir/STAR/THLE2/SRR8040789_1.fastq.gz"
fq18="$dir/STAR/THLE2/SRR8040789_2.fastq.gz"
fq19="$dir/STAR/THLE2/SRR8040790_1.fastq.gz"
fq20="$dir/STAR/THLE2/SRR8040790_2.fastq.gz"
fq21="$dir/STAR/THLE2/SRR8040791_1.fastq.gz"
fq22="$dir/STAR/THLE2/SRR8040791_2.fastq.gz"
fq23="$dir/STAR/THLE2/SRR8040792_1.fastq.gz"
fq24="$dir/STAR/THLE2/SRR8040792_2.fastq.gz"
inp=$dir/STAR/THLE2
BL

#:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len100"
fq1="/home/longy/workspace/apa_predict/fastq/HUM_Brain_REP1_1.fastq.gz"
fq2="/home/longy/workspace/apa_predict/fastq/HUM_Brain_REP1_2.fastq.gz"
inp=$dir/STAR/human_brain
#BL

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
STAR  --twopassMode Basic --runThreadN $threads --genomeDir $genomeIndex  --readFilesIn $fq1 $fq2 --outSAMtype BAM SortedByCoordinate --outSAMattrIHstart 0  --outFilterMultimapScoreRange 0  --alignEndsType Local  --readFilesCommand zcat  --outSAMstrandField intronMotif --outFilterType BySJout --outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --outWigType wiggle --outWigNorm RPM


####INDEX for sorted bam file
echo 'generating index with samtools'
#samtools index -@ $threads Aligned.sortedByCoord.out.bam
gtf="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.102.gtf"
#gtf="/home/longy/cnda/ensembl/Mus_musculus.GRCm38.102.gtf"
#featureCounts -a $gtf -o count  -T 32 -s 2 Aligned.sortedByCoord.out.bam 

echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($durat ion/3600)):$((($duration/60)%60)):$(($duration % 60))"
