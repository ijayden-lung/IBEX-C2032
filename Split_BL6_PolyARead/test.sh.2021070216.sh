#!/bin/bash
#SBATCH --job-name=STAR
#SBATCH --partition=batch
#SBATCH --nodes=4
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --output=log.%J
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --dependency=afterok:8186700
#SBATCH --mem=100G


spe='hg38'
PAS="usage_data/k562_chen.pAs.usage.txt"
scanTranscriptom="/home/longy/project/Split_BL6/k562_chen_data/chr1_+_0"
baseName=${scanTranscriptom##*/}
pos_file="data/positive/test.$baseName"
neg_file="data/positive/neg.$baseName"
Shift=8
polyASeqRCThreshold=5
RNASeqRCThreshold=0.03
usageThreshold=0.05
prob=0.001

#python select_positive_from_transcriptome.py --pas_file=$PAS --scan_file=$scanTranscriptom --polyASeqRCThreshold=$polyASeqRCThreshold --RNASeqRCThreshold=$RNASeqRCThreshold --usageThreshold=$usageThreshold --max_shift=$Shift --species=$spe --output=$pos_file
#python select_negative_from_transcriptome.py --pas_file=$pos_file --scan_file=$scanTranscriptom --RNASeqRCThreshold=$RNASeqRCThreshold --max_shift=$Shift --species=$spe --output=$neg_file --prob=$prob

python evaluate2.py  --model="" --data=$scanTranscriptom --out="" --RNASeqRCThreshold=$RNASeqRCThreshold
