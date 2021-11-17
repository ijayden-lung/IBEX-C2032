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

polyAthreshold=-1
ENS="/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz"
#coverage="../Figures/SNU398/predicted.txt"
coverage="SNU398_Control.pAs.coverage.txt"
target="SNU398_Control.pAs.bed"
target2="SNU398_Control.pAs.txt"
#new="SNU398_Control.usage.txt"
new="SNU398_Control.regression.txt"
mod1="../../Split_BL6/polyA_seq/modSNU398_1.bed"
mod2="../../Split_BL6/polyA_seq/modSNU398_2.bed"

#perl generate_bed.pl $coverage $target
#perl generate_bedFrompredicted.pl $coverage $target
#perl generate_result.pl $coverage $target2
#bedtools coverage -a $target -b $mod1 -S -sorted -counts > $target.021.counts
#bedtools coverage -a $target -b $mod2 -S -sorted -counts > $target.022.counts
#perl merge_rep.pl $target.021.counts $target.022.counts $target.info

#perl calculate_usage.tianbin.pl $target2 $target.info $new  $ENS $polyAthreshold
perl calculate_usage.tianbin.pl $coverage $target.info $new  $ENS $polyAthreshold

#rm $target $target.021.counts $target.022.counts $target.info $target.info.cutoff
