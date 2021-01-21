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


data="../usage_data/hg38.pAs.tianbin.usage.train.v3.txt"
out1="hg38.pAs.subset.predict.txt"
out2="hg38.pAs.subset.tianbin.txt"

perl regression_blank30.pl bl6.pAs.predicted.usage.txt bl6.pAs.readCount.txt bl6.pAs.compare2.txt
