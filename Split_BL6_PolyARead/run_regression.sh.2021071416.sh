#!/bin/bash
#SBATCH --job-name=train
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=4:00:00
#SBATCH --mem=100G
#SBATCH --gres=gpu:1
##SBATCH -a 0-39
#SBATCH --dependency afterok:14128576_[50-80] 

#########TRAIN
######Yongkang Long Update at Jan 05, 2021. 
echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"

##########################################################################
#########PARAMETER CHANGED
bestEpoch=0990

Shift=16
epochs=3000
cell='f_hepg2'
length=1001
learning_rate=5e-4 #####small learning rate for fine tuning
task='training'   ##task = [preparation training evaluation statistics]

if [ "$spe" == "BL6" ]; then
	file_path="usage_data/BL6_REP1.pAs.predict.coverage.txt"
	trainid="mae.linear"

elif [ "$cell" == "thle2" ]; then
	file_path="coverage_data/thle2_control.pAs.usage.txt"
	trainid="Regression.p1.${cell}.shift${Shift}.$length"
elif [ "$cell" == "f_k562" ]; then
	file_path="coverage_data/Finetune.k562_chen.usage.txt"
	trainid="Regression.${cell}.shift${Shift}.$length"
elif [ "$cell" == "f_thle2" ]; then
	file_path="coverage_data/Finetune.thle2_control.usage.txt"
	trainid="Regression.${cell}.shift${Shift}.$length"
elif [ "$cell" == "f_snu398" ]; then
	file_path="coverage_data/Finetune.snu398_control.usage.txt"
	trainid="Regression.${cell}.shift${Shift}.$length"
elif [ "$cell" == "f_hepg2" ]; then
	file_path="coverage_data/Finetune.hepg2_control.usage.txt"
	trainid="Regression.${cell}.shift${Shift}.$length"
fi


if [ "$task" == "training" ]; then
	echo "starting task $task"
	python3 train.regression.py --file_path $file_path --trainid $trainid --learning_rate $learning_rate --epochs $epochs --shift $Shift --length $length

task="evaluation"
model="Model/${trainid}-${bestEpoch}.ckpt"
elif [ "$task" == "evaluation" ]; then
	python3 evaluate.regression.py --file_path $file_path --model $model --out test.txt

else
	echo "Invalid task parameter"
	echo "task = [preparation training evaluation statistics]"
fi
