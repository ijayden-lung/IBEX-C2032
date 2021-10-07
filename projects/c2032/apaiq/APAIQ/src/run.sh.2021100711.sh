#!/bin/bash
#SBATCH --job-name=APAIQ
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=30
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=1:00:00
#SBATCH --mem=80G
##SBATCH --gres=gpu:1
##SBATCH -a 0-45
##SBATCH --dependency afterok:6686802_[1-100] 

time_start=$(date +"%s")
echo "job start at" `date "+%Y-%m-%d %H:%M:%S"`
echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"
echo "My hostname is: $(hostname -s)"
echo "My task ID is $SLURM_ARRAY_TASK_ID"
echo 



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
#python APAIQ.py --input_plus=$WIG_plus --input_minus=$WIG_minus --out_dir=$out_dir  --fa_file=$fa_file  --name=$sample_name --DB_file $DB  --model $model

cd /home/longy/project/apaiq/APAIQ/src/

#time python APAIQ.v.0.3.py --input_plus='/home/longy/project/apaiq/APAIQ/demo/fwd2.norm.bedGraph' --input_minus='/home/longy/project/apaiq/APAIQ/demo/rev2.norm.bedGraph' --fa_file='/home/longy/project/apaiq/oneLine/hg38'  --name='test1' --model '/home/longy/project/apaiq/APAIQ/model/snu398_model.ckpt'  --DB_file='/home/longy/project/apaiq/demo/polyADB3_gencode.pAs.txt' 
#time python -u APAIQ.v.0.3.py   --input_file='../demo/RNAseq.depth.bedGraph' --fa_file='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.dna.primary_assembly.fa' --model '/home/longy/project/apaiq/APAIQ/model/snu398_model.ckpt'  --DB_file='/home/longy/project/apaiq/demo/polyADB3_gencode.pAs.txt'  --name='block3'
time python -u APAIQ.v.0.3.py   --input_file='../demo/RNAseq.depth.bedGraph' --fa_file='/home/longy/project/apaiq/oneLine' --model '/home/longy/project/apaiq/APAIQ/model/snu398_model.ckpt'  --DB_file='/home/longy/project/apaiq/demo/polyADB3_gencode.pAs.txt'  --name='threadpool'
#time python -u APAIQ.v.0.3.py   --input_file='../demo/small.fwd.norm.bedGraph' --fa_file='/home/longy/project/apaiq/oneLine/hg38' --model '/home/longy/project/apaiq/APAIQ/model/snu398_model.ckpt'  --DB_file='/home/longy/project/apaiq/demo/polyADB3_gencode.pAs.txt'  --name='small2'

echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($duration/3600)):$((($duration/60)%60)):$(($duration % 60))"
echo
