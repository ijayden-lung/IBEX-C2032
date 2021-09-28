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


####set up enviroment
export PYTHONPATH="/home/longy/project/APAIQ/src:$PYTHONPATH"

sample_name="HepG2"
fa_file="oneLine/hg38"
WIG_plus="demo/test.plus.wig"
WIG_minus="demo/test.minus.wig"
model="demo/test_model.ckpt"
DB="demo/polyADB3_gencode.pAs.txt"
out_dir='out_dir'

####unstranded
#python src/APAIQ.py --input_file=$WIG --out_dir=$out_dir  --fa_file=$fa_file  --name=$sample_name --DB_file $DB --model $model

####stranded
python src/APAIQ.py --input_plus=$WIG_plus --input_minus=$WIG_minus --out_dir=$out_dir  --fa_file=$fa_file  --name=$sample_name --DB_file $DB  --model $model


echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($duration/3600)):$((($duration/60)%60)):$(($duration % 60))"
echo
