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
neg_file2="data/positive/neg2.$baseName"
Shift=8
polyASeqRCThreshold=5
RNASeqRCThreshold=0.03
usageThreshold=0.05
prob=0.001
pre_file="maxSum/k562_chen.pAs.single_kermax6.k562_chen_aug8_SC_p5r0.03u0.05_0-0295.chr1_+_0.txt.bidirection.12.1.txt"

#python select_positive_from_transcriptome.py --pas_file=$PAS --scan_file=$scanTranscriptom --polyASeqRCThreshold=$polyASeqRCThreshold --RNASeqRCThreshold=$RNASeqRCThreshold --usageThreshold=$usageThreshold --max_shift=$Shift --species=$spe --output=$pos_file
#python select_negative_from_transcriptome.py --pas_file=$pos_file --scan_file=$scanTranscriptom --RNASeqRCThreshold=$RNASeqRCThreshold --max_shift=$Shift --species=$spe --output=$neg_file --prob=$prob

#python evaluate2.py  --model="" --data=$scanTranscriptom --out="" --RNASeqRCThreshold=$RNASeqRCThreshold
#python change_negative.py --pos_file=$pos_file --neg_file=$neg_file --scan_file=$scanTranscriptom --pre_file=$pre_file --RNASeqRCThreshold=$RNASeqRCThreshold --max_shift=$Shift --output=$neg_file2

python change_all.py --pre_file="maxSum/Finetune_k562Tothle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0002.chrX_+_1.txt.bidirection.12.1.txt" --scan="../Split_BL6/thle2_control_data/chrX_+_1" --output="test" --spe="hg38"
