#!/bin/bash
#SBATCH --job-name=Coverage
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=2:00:00
#SBATCH --mem=50G
##SBATCH --gres=gpu:1
#SBATCH -a 0-222
##SBATCH --dependency afterok:6686802_[1-100] 



time_start=$(date +"%s")
echo "job start at" `date "+%Y-%m-%d %H:%M:%S"`
echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"
echo "My hostname is: $(hostname -s)"
echo "My task ID is $SLURM_ARRAY_TASK_ID"
echo 

###Rerember to change the array number
dir="k562_chen_data"
DB="/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt"
ENS="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz"
task='Coverage'

files=($dir/chr*)
scanTranscriptome=${files[$SLURM_ARRAY_TASK_ID]}
if [ "$task" == "Coverage" ]; then
	python extract_coverage_from_scanGenome.py --pas_file=$DB --scan_file=$scanTranscriptome
	python extract_coverage_from_scanGenome.py --pas_file=$ENS --scan_file=$scanTranscriptome --file_type='ensembl'
fi


echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($duration/3600)):$((($duration/60)%60)):$(($duration % 60))"
echo
