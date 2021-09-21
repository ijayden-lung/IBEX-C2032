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


data="../data/bl6.pAs.predict.REP1.fiveround3.txt"
target="bl6.pAs.predict.fiveround3"
ENS="/home/longy/cnda/ensembl/Mus_musculus.GRCm38.100.gtf.gz"
refSeq="/home/longy/cnda/refSeq/mm10.refGene.gtf.gz"


#perl generate_bed.pl $data $target.bed
#bedtools coverage -a $target.bed -b modMSX_021.bed -S -sorted -counts > $target.021.counts
#bedtools coverage -a $target.bed -b modMSX_022.bed -S -sorted -counts > $target.022.counts
#perl merge_rep.pl $target.021.counts $target.022.counts $target.info

#perl calculate_usage.predict.pl $data $target.bed.info $target.usage.txt $ENS $refSeq
#perl calculate_usage.tianbin.pl $data $target.info $target.usage.txt $ENS

#rm *counts
#rm *info

scanGenome="bl6.pAs.scanGenome.fiveround3.txt"
predict="bl6.pAs.predict.fiveround3.usage.txt"
data="../usage_data/bl6.pAs.tianbin.usage.train.v3.txt"
out1="bl6.pAs.subset.predict.txt"
out2="bl6.pAs.subset.tianbin.txt"

#perl subset_gene.pl $scanGenome $predict $data $out1 $out2
#perl different.pl


#perl regression2.pl $predict  bl6.pAs.predict.fiveround3.readCount.txt bl6.pAs.compare2.txt
#perl regression_blank30.pl $predict  bl6.pAs.predict.fiveround3.readCount.txt $scanGenome bl6.pAs.compare2.txt
