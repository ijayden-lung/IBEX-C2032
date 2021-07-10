#!/bin/bash
#SBATCH --job-name=scanGenome
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=8:00:00
#SBATCH --mem=100G
##SBATCH --gres=gpu:1
#SBATCH -a 0-45
##SBATCH --dependency afterok:6686802_[1-100] 

#source activate ML

echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"
rep="Control"
spe="hg38"
name="K562"
window=201
allsteps=(1 1 1 1 1 1)
allstrands=("str2" "str1" "str2" "str1" "str2" "str1")
allsigns=("+" "-" "+" "-" "+" "-")
#allchrs=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" "chr11" "chr12" "chr13" "chr14" "chr15" "chr16" "chr17" "chr18"  "chr19" "chrX")  
allchrs=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" "chr11" "chr12" "chr13" "chr14" "chr15" "chr16" "chr17" "chr18"  "chr19" "chrX" "chr20" "chr21" "chr22")  
for ((i=0;i<=119;i++))
do
	b=$(( $i % 2 ))
	c=$(( $i / 2))
	steps[$i]=${allsteps[$b]}
	strands[$i]=${allstrands[$b]}
	signs[$i]=${allsigns[$b]}
	chrs[$i]=${allchrs[$c]}
done

step=${steps[$SLURM_ARRAY_TASK_ID]}
strand=${strands[$SLURM_ARRAY_TASK_ID]}
sign=${signs[$SLURM_ARRAY_TASK_ID]}
chr=${chrs[$SLURM_ARRAY_TASK_ID]}

#python split_chr.py

WIG="STAR/${name}_${rep}/Signal.Unique.${strand}.out.${chr}.wig"
root_dir="${name}_${rep}_data"
if [ ! -d ${name}_${rep}_data ];then
	mkdir -p ${name}_${rep}_data
fi
Trim="${name}_${rep}_data/${spe}.pAs.scanGenome.${chr}.${strand}.Win${window}.txt"
if [ "$spe" == "hg38" ]; then
	DB="/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt"
	ENS="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz" 
elif [ "$spe" == "mm10" ]; then
	DB="/home/longy/workspace/apa_predict/pas_dataset/bl6.pAs.tianbin.txt"
	ENS="/home/longy/cnda/ensembl/Mus_musculus.GRCm38.102.gtf.gz"
fi

#perl generate_slidingWidnows.pl $WIG $Trim $window $step $sign $chr $spe

#perl extract_coverage_from_scanGenome.db.pl $Trim $DB
#perl extract_coverage_from_scanGenome.ens.pl $Trim $ENS
#perl extract_coverage_from_scanGenome.db.pl $Trim "polyA_seq/callPeakK562_Chen.bed"



ens_chr=${chr/chr/}
fa_file="/home/longy/cnda/ensembl/oneLine/$spe.$ens_chr.fa"
python generate_windows.py --input_file=$WIG --root_dir=$root_dir --ens_file=$ENS --fa_file=$fa_file

#python extract_coverage_from_scanGenome.db.py --pas_file="/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt" --scan_file="test_data/chr21_-_0"

#python split_chr.py --root_dir ${name}_${rep}_data --ens_file $ENS --input_file $Trim

if [ "$name" == "BL6" ]; then
	polyASeqRCThreshold=5
elif [ "$name" == "HepG2" ]; then
	polyASeqRCThreshold=1
elif [ "$name" == "K562" ]; then
	polyASeqRCThreshold=3
fi
####Extract upstream read
#Predict="/home/longy/project/Split_BL6/polyA_seq/${name}_${rep}.pAs.predict.aug8_SC_p5r10u0.05_4-0026.12.2.usage.txt"
#Predict="/home/longy/project/Split_BL6/polyA_seq/HepG2_Control.pAs.predict.aug8_SC_p1r5u0.05_3-0060.12.1.usage.txt"
#Predict="/home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.predict.aug8_SC_p3r9u0.05_4-0072.12.1.usage.txt"
#out="/home/longy/project/Split_BL6_PolyARead/usage_data/${name}_${rep}.pAs.scanGenome.${chr}.${strand}.Win${window}.txt"
#Predict="/home/longy/project/Split_BL6/polyA_seq/HepG2_Control.pAs.predict.aug8_SC_p1r5u0.05_4-0060.12.1.usage.txt"
#Predict="/home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.predict.aug8_SC_p3r9u0.05_4-0072.12.1.usage.txt"
Predict="/home/longy/project/Split_BL6_PolyARead/usage_data/BL6_REP1.pAs.usage.txt"
out="/home/longy/project/Split_BL6_PolyARead/usage_data/${name}_${rep}.pAs.scanGenome.${chr}.${strand}.Win${window}.txt"


#perl extract_updownstream_read.pl  $Predict $WIG $out $polyASeqRCThreshold 550 $sign $chr
#perl extract_upstream_read.pl  $Predict $WIG $out $polyASeqRCThreshold 500 $sign $chr


#######Extrac PolyA 
#Hi YongKang,
#Please check the attached perl script to extract the polyA reads from bam file.
#You need two step to get the output in bedgraph format.
#(1) run the perl script:
#cd ../Split_BL6_PolyARead/
NAME="K562_ZRANB2"
#samtools sort -n -m 1G -@ 1 -l 9 -o BAM/${NAME}.sortedByName.bam STAR/${NAME}/Aligned.sortedByCoord.out.bam
#perl extract.polyA.reads.pl BAM/${NAME}.sortedByName.bam BAM/${NAME}.bed PE
#perl BAM/callCluster.pl BAM/${NAME}.bed BAM/${NAME}.cluster PE
