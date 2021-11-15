#!/bin/bash
#SBATCH --job-name=Dapars
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=1:00:00
#SBATCH --mem=50G
#SBATCH -a 0-45
##SBATCH --gres=gpu:1
##SBATCH --dependency afterok:6686802_[1-100] 


###Total 201 blocks
###Num of Train: 144, Num of valid 36, Num of test: 21


allchrs=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" "chr11" "chr12" "chr13" "chr14" "chr15" "chr16" "chr17" "chr18" "chr19" "chrX" "chr20" "chr21" "chr22")
allstr=("str2" "str1")
for ((i=0;i<=45;i++))
do
	b=$(( $i % 2 ))
	c=$(( $i / 2))
	strs[$i]=${allstr[$b]}
	chrs[$i]=${allchrs[$c]}
done

str=${strs[$SLURM_ARRAY_TASK_ID]}
chr=${chrs[$SLURM_ARRAY_TASK_ID]}

UTR="hg38_ensembl_extracted_3UTR.${str}.bed"
DEPTH="../sequencing_depth.txt"
WIG="/home/longy/project/Split_BL6/STAR/SNU398_Control/Signal.Unique.${str}.out.${chr}.wig"
#perl modified_wig.pl  $WIG $chr snu398.$str.$chr.wig 259.0674
WIG="/home/longy/project/Split_BL6/STAR/THLE2_Control/Signal.Unique.${str}.out.${chr}.wig"
#perl modified_wig.pl  $WIG $chr thle2.$str.$chr.wig 99.8004
WIG="/home/longy/project/Split_BL6/STAR/K562_Chen/Signal.Unique.${str}.out.${chr}.wig"
#perl modified_wig.pl  $WIG $chr k562.$str.$chr.wig 267.3797
WIG="/home/longy/project/Split_BL6/STAR/HepG2_Control/Signal.Unique.${str}.out.${chr}.wig"
#perl modified_wig.pl  $WIG $chr hepg2.$str.$chr.wig 148.3680

#python Dapars2_Multi_Sample.py --wig_file="snu398.$str.$chr.wig,thle2.$str.$chr.wig,k562.$str.$chr.wig,hepg2.$str.$chr.wig" --out_dir="data_${str}" --utr_file=$UTR --res_file="pAs" --depth_file=$DEPTH --chr=$chr

