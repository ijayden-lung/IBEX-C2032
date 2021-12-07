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
rep="Chen"
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


WIG="../Split_BL6/STAR/${name}_${rep}/Signal.Unique.${strand}.out.${chr}.wig"
python change_gt.py  --scan_file=$WIG --pre_file='usage_data/K562_Chen.pAs.usage.txt'  --output="results/${chr}.${strand}" --chromosome=$chr --strand=$sign

