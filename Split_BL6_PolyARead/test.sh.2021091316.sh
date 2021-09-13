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
PAS="usage_data/THLE2_Control.pAs.usage.txt"
DB="usage_data/thle2_control.pAs.merge.coverage.txt"
scanTranscriptom="/home/longy/project/Split_BL6/THLE2_Control_data/chr10_+_1"
baseName=${scanTranscriptom##*/}
pos_file="data/positive/THLE2_Control_aug12_SC_p1r0.05u0.05/$baseName"
neg_file="data/negative/THLE2_Control_aug12_SC_p1r0.05u0.05_0/$baseName"
neg_file2="data/positive/neg2.$baseName"
Shift=12
maxPoint=12
bestEpoch=0010
polyASeqRCThreshold=1
RNASeqRCThreshold=0.05
usageThreshold=0.05
prob=0.001
penality=1
info="../Split_BL6/THLE2_Control_data/info.txt"
testid="thle2_control.pAs.single_kermax6.thle2_control_aug${Shift}_SC_p1r0.05u0.05_4-$bestEpoch"
model="bestModel/$testid.ckpt"
pre_file="maxSum/$testid.${baseName}.txt.bidirection.$maxPoint.1.txt"

#python select_positive_from_transcriptome.py --pas_file=$PAS --scan_file=$scanTranscriptom --polyASeqRCThreshold=$polyASeqRCThreshold --RNASeqRCThreshold=$RNASeqRCThreshold --usageThreshold=$usageThreshold --max_shift=$Shift --species=$spe --output=$pos_file
#python select_negative_from_transcriptome.py --pas_file=$pos_file --scan_file=$scanTranscriptom --RNASeqRCThreshold=$RNASeqRCThreshold --max_shift=$Shift --species=$spe --output=$neg_file --prob=$prob

#python evaluate2.py  --model=$model --data=$scanTranscriptom --out="test" --RNASeqRCThreshold=$RNASeqRCThreshold

#python scanTranscriptome_forward.py --testid $testid --baseName $baseName --threshold 0 --penality 1 
#python scanTranscriptome_reverse.py --testid $testid --baseName $baseName --threshold 0 --penality 1 
predict="predict/${testid}.${baseName}.txt"
echo $predict
perl postprocess.bidirection.pl $maxPoint $penality  $PAS  $DB $predict $info $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold

#python change_negative.py --pos_file=$pos_file --neg_file=$neg_file --scan_file=$scanTranscriptom --pre_file=$pre_file --RNASeqRCThreshold=$RNASeqRCThreshold --max_shift=$Shift --output=$neg_file2 --usage_file=$PAS --polyASeqRCThreshold=$polyASeqRCThreshold



#python change_all.py --pre_file="maxSum/Finetune_k562Tothle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0002.chrX_+_1.txt.bidirection.12.1.txt" --scan="../Split_BL6/thle2_control_data/chrX_+_1" --output="test" 
#python change_all.py --std_inp="47432133" --scan="../Split_BL6/THLE2_Control_data/chr1_-_5" --output="test" 

#python get_files.py --root_dir data/positive/SNU398_Control_aug12_C_p1r0.05u0.05 --round 3 --set valid
