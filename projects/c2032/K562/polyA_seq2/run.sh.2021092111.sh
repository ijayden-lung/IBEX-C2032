#! /bin/bash
#SBATCH --job-name=Bed
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=log.%J
#SBATCH --time=1:00:00
#SBATCH --mem=24G
#SBATCH -a 0
#SBATCH --gres=gpu:1


ENS="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.101.gtf.gz";

#data="/home/longy/project/Split_BL6_PolyARead/usage_data/K562_Control.pAs.coverage.txt"
data="../Control_stat/hg38.pAs.control.txt"
target="K562_Control.pAs"
new="K562_Control.pAs.usage.txt"

perl generate_bed.pl $data $target.bed
bedtools coverage -a $target.bed -b modK562_Z2_1.bed -S -sorted -counts > $target.Z21.counts
bedtools coverage -a $target.bed -b modK562_Z2_2.bed -S -sorted -counts > $target.Z22.counts
perl merge_rep.pl $target.Z21.counts $target.Z22.counts $target.info


perl calculate_usage.tianbin.pl $data $target.info $target.info.cutoff $ENS

#perl overlap.pl
perl process_error_name.pl $ENS $target.info.cutoff $new.txt
