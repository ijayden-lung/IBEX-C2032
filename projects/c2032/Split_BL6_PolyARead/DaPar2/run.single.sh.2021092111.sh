#!/bin/bash
#SBATCH --job-name=Dapars
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=log.%J
#SBATCH --error=err.%J
#SBATCH --time=24:00:00
#SBATCH --mem=50G
##SBATCH --gres=gpu:1
##SBATCH -a 0-200
##SBATCH --dependency afterok:6686802_[1-100] 


###Total 201 blocks
###Num of Train: 144, Num of valid 36, Num of test: 21


allchrs=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" "chr11" "chr12" "chr13" "chr14" "chr15" "chr16" "chr17" "chr18" "chr19" "chrX" "chr20" "chr21" "chr22")
allstr=("str2" "str1")
for chr in ${allchrs[@]}; do
	for str in ${allstr[@]}; do
		UTR="hg38_ensembl_extracted_3UTR.${str}.bed"
		DEPTH="sequencing_depth.txt"

		WIG="/home/longy/project/Split_BL6/STAR/SNU398_Control/Signal.Unique.${str}.out.${chr}.wig"
		perl modified_wig.pl  $WIG $chr snu398.wig 259.0674
		WIG="/home/longy/project/Split_BL6/STAR/THLE2_Control/Signal.Unique.${str}.out.${chr}.wig"
		perl modified_wig.pl  $WIG $chr thle2.wig 99.8004
		WIG="/home/longy/project/Split_BL6/STAR/K562_Chen/Signal.Unique.${str}.out.${chr}.wig"
		perl modified_wig.pl  $WIG $chr k562.wig 267.3797
		WIG="/home/longy/project/Split_BL6/STAR/HepG2_Control//Signal.Unique.${str}.out.${chr}.wig"
		perl modified_wig.pl  $WIG $chr hepg2.wig 148.3680

		python Dapars2_Multi_Sample.py --wig_file="snu398.wig,thle2.wig,k562.wig,hepg2.wig" --out_dir="data_${str}" --utr_file=$UTR --res_file="pAs" --depth_file=$DEPTH --chr=$chr
	done
done
