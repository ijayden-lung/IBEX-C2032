#!/bin/bash
#SBATCH --job-name=scanGenome
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=100:00:00
#SBATCH --mem=10G
##SBATCH --gres=gpu:1
##SBATCH -a 0-45
##SBATCH --dependency afterok:6686802_[1-100] 

time_start=$(date +"%s")
echo "job start at" `date "+%Y-%m-%d %H:%M:%S"`
echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"
echo "My hostname is: $(hostname -s)"
echo "My task ID is $SLURM_ARRAY_TASK_ID"
echo 

sample_name="THLE2"
RNASeqRCThreshold=0.05
window=201
fa_file="/home/longy/cnda/ensembl/oneLine/hg38"
WIG_plus="/home/longy/project/Split_BL6/STAR/THLE2_Control/Signal.Unique.str2.out.wig"
WIG_minus="/home/longy/project/Split_BL6/STAR/THLE2_Control/Signal.Unique.str1.out.wig"
model="/home/longy/project/Split_BL6_PolyARead/bestModel/THLE2_Control.pAs.single_kermax6.THLE2_Control_aug12_SC_p1r0.05u0.05_4-0003.ckpt"
DB="/home/longy/project/Split_BL6_PolyARead/usage_data/THLE2_Control.pAs.merge.coverage.txt"

root_dir="$sample_name"
if [ ! -d $root_dir ];then
	mkdir -p $root_dir
fi

####unstranded
#python generate_windows.py --input_file=$WIG --out_dir=$root_dir  --fa_file=$fa_file 
####stranded
python generate_windows.py --input_plus=$WIG_plus --input_minus=$WIG_minus --out_dir=$root_dir  --fa_file=$fa_file  --name=$sample_name


for file in $root_dir/data/*
do
	baseName=${file##*/}
	#baseName=${sample_name}.$baseName
	python evaluate.py --model $model --baseName $baseName --out_dir $root_dir --RNASeqRCThreshold=$RNASeqRCThreshold --name=$sample_name
	python scanTranscriptome_forward.py --baseName $baseName --out_dir $root_dir --name=$sample_name
	python scanTranscriptome_reverse.py --baseName $baseName --out_dir $root_dir --name=$sample_name
	python postprocess.py --baseName $baseName --out_dir $root_dir --DB_file $DB --name=$sample_name
done

#python evaluate.py --model $model --baseName $baseName --out_dir $root_dir --RNASeqRCThreshold=$RNASeqRCThreshold
#python scanTranscriptome_forward.py --baseName $baseName --out_dir $root_dir
#python scanTranscriptome_reverse.py --baseName $baseName --out_dir $root_dir
#python postprocess.py --baseName $baseName --out_dir $root_dir --DB_file $DB

echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($duration/3600)):$((($duration/60)%60)):$(($duration % 60))"
echo
