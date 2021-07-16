#! /bin/bash
#SBATCH --job-name=Bed
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=4:00:00
#SBATCH --mem=100G
##SBATCH -a 0
##SBATCH --gres=gpu:1

ENS="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz"

coverage="../../Split_BL6_PolyARead/coverage_data/Finetune_k562Tothle2.thle2_control.coverage.txt"
target="Finetune.thle2_control.pAs.bed"
new="Finetune.thle2_control.usage.txt"
mod1="../../Split_BL6/polyA_seq/modTHLE2_1.bed"
mod2="../../Split_BL6/polyA_seq/modTHLE2_2.bed"

perl generate_bed.pl $coverage $target
bedtools coverage -a $target -b $mod1 -S -sorted -counts > $target.021.counts
bedtools coverage -a $target -b $mod2 -S -sorted -counts > $target.022.counts
perl merge_rep.pl $target.021.counts $target.022.counts $target.info

perl calculate_usage.tianbin.pl $coverage $target.info $new  $ENS


rm $target $target.021.counts $target.022.counts $target.info $target.info.cutoff