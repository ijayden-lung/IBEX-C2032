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
##SBATCH -a 0

#####Modify parameter
threads=16
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
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len100"
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
inp=$dir/STAR/K562_Control
BL

#:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len75"
fq1="/home/longy/project/Split_BL6/STAR/SNU398_Control/SRR10022387_1.fastq.gz"
fq2="/home/longy/project/Split_BL6/STAR/SNU398_Control/SRR10022387_2.fastq.gz"
fq3="/home/longy/project/Split_BL6/STAR/SNU398_Control/SRR10022388_1.fastq.gz"
fq4="/home/longy/project/Split_BL6/STAR/SNU398_Control/SRR10022388_2.fastq.gz"
FQ1="$fq1 $fq3"
FQ2="$fq2 $fq4"
out="SNU398"
#BL
:<<BL
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/newhg38len75"
fq1="$dir/STAR/THLE2_Control/SRR8040781_1.fastq.gz"
fq2="$dir/STAR/THLE2_Control/SRR8040781_2.fastq.gz"
fq3="$dir/STAR/THLE2_Control/SRR8040782_1.fastq.gz"
fq4="$dir/STAR/THLE2_Control/SRR8040782_2.fastq.gz"
fq5="$dir/STAR/THLE2_Control/SRR8040783_1.fastq.gz"
fq6="$dir/STAR/THLE2_Control/SRR8040783_2.fastq.gz"
fq7="$dir/STAR/THLE2_Control/SRR8040784_1.fastq.gz"
fq8="$dir/STAR/THLE2_Control/SRR8040784_2.fastq.gz"
fq9="$dir/STAR/THLE2_Control/SRR8040785_1.fastq.gz"
fq10="$dir/STAR/THLE2_Control/SRR8040785_2.fastq.gz"
fq11="$dir/STAR/THLE2_Control/SRR8040786_1.fastq.gz"
fq12="$dir/STAR/THLE2_Control/SRR8040786_2.fastq.gz"
fq13="$dir/STAR/THLE2_Control/SRR8040787_1.fastq.gz"
fq14="$dir/STAR/THLE2_Control/SRR8040787_2.fastq.gz"
fq15="$dir/STAR/THLE2_Control/SRR8040788_1.fastq.gz"
fq16="$dir/STAR/THLE2_Control/SRR8040788_2.fastq.gz"
fq17="$dir/STAR/THLE2_Control/SRR8040789_1.fastq.gz"
fq18="$dir/STAR/THLE2_Control/SRR8040789_2.fastq.gz"
fq19="$dir/STAR/THLE2_Control/SRR8040790_1.fastq.gz"
fq20="$dir/STAR/THLE2_Control/SRR8040790_2.fastq.gz"
fq21="$dir/STAR/THLE2_Control/SRR8040791_1.fastq.gz"
fq22="$dir/STAR/THLE2_Control/SRR8040791_2.fastq.gz"
fq23="$dir/STAR/THLE2_Control/SRR8040792_1.fastq.gz"
fq24="$dir/STAR/THLE2_Control/SRR8040792_2.fastq.gz"
FQ1="$fq1 $fq3 $fq5 $fq7 $fq9 $fq11 $fq13 $fq15 $fq17 $fq19 $fq21 $fq23"
FQ2="$fq2 $fq4 $fq6 $fq8 $fq10 $fq12 $fq14 $fq16 $fq18 $fq20 $fq22 $fq24"
out="THLE2"
BL



time_start=$(date +"%s")
echo "job start at" `date "+%Y-%m-%d %H:%M:%S"`
echo "This is job #${SLURM_ARRAY_JOB_ID}, with parameter ${input[$SLURM_ARRAY_TASK_ID]}"
echo "My hostname is: $(hostname -s)"
echo "My task ID is $SLURM_ARRAY_TASK_ID"
echo


echo 'starting mapping with salmon'

#./gtfToGenePred -genePredExt /home/longy/cnda/gencode/gencode.v38.annotation.gtf  examples/hg38/hg38_genes.genePred

#mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -e "select chrom, txStart, txEnd, name2, score, strand from wgEncodeGencodePolyaVM9 where name2 = 'polyA_site'" -N hg38 > gencode.polyA_sites.bed

#qapa build --db examples/hg38/ensembl.identifiers.txt -o examples/hg38/SNU398.polyA_sites.bed examples/hg38/hg38_genes.genePred >examples/hg38/output_utrs.bed


#qapa fasta -f ~/cnda/ucsc/hg38.fa examples/hg38/output_utrs.bed examples/hg38/output_sequences.fa


#salmon index -t examples/hg38/output_sequences.fa -i examples/hg38/utr_library

salmon quant -i utr_library  -l ISR -1 $FQ1 -2 $FQ2 --validateMappings -o $out -p 16


#qapa quant --db examples/hg38/ensembl.identifiers.txt THLE2/quant.sf > pau_results.txt



echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($durat ion/3600)):$((($duration/60)%60)):$(($duration % 60))"
