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
ENS="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz"
cell="HepG2"
coverage="pAs.txt"
target="${cell}.bed"
new="${cell}.pAs.usage.txt"
PAS="../usage_data/${cell}_Control.pAs.usage.txt"
DB="../usage_data/${cell}_Control.pAs.coverage.txt"
OUT="../Figures/${cell}/predicted.Dapar2.txt"
mod1="../../Split_BL6/polyA_seq/mod${cell}_1.bed"
mod2="../../Split_BL6/polyA_seq/mod${cell}_2.bed"

perl generate_bed.pl $coverage $target $cell
perl postprocess.bidirection.pl $PAS $DB ${cell}.pAs.coverage.txt $OUT 1 0.05 0.05
#bedtools coverage -a $target -b $mod1 -S -sorted -counts > $target.021.counts
#bedtools coverage -a $target -b $mod2 -S -sorted -counts > $target.022.counts
#perl merge_rep.pl $target.021.counts $target.022.counts $target.info

#perl calculate_usage.tianbin.pl pAs.coverage.txt $target.info $new  $ENS $polyAthreshold


#rm $target $target.021.counts $target.022.counts $target.info $target.info.cutoff
