#!/bin/bash
#SBATCH --job-name=Train_Join
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
#SBATCH -a 0-200
##SBATCH --dependency afterok:6686802_[1-100] 


###Total 201 blocks
###Num of Train: 144, Num of valid 36, Num of test: 21

time_start=$(date +"%s")
echo "job start at" `date "+%Y-%m-%d %H:%M:%S"`
echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"
echo "My hostname is: $(hostname -s)"
echo "My task ID is $SLURM_ARRAY_TASK_ID"
echo 

:<<BL ####
dir="../Split_BL6/scanGenome_data/Blocks"
PAS="../Split_BL6/usage_data/bl6.pAs.usage.txt"
DB="../Split_BL6/usage_data/bl6.pAs.coverage.txt"
info='../Split_BL6/scanGenome_data/Blocks/info.txt'
BL

files=($dir/chr*)
scanTranscriptome=${files[$SLURM_ARRAY_TASK_ID]}

if [ "$task" == "Prepare" ]; then
	baseround=${round:0:-2}
	if [ ! -d ./data/positive/$baseround ];then
		mkdir -p ./data/positive/$baseround
	fi
	echo "extract_coverage_from_scanGenome.pl $PAS $scanTranscriptome $baseround $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold $Shift"
	perl extract_coverage_from_scanGenome.pl $PAS $scanTranscriptome $baseround $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold $Shift
	if [ ! -d ./data/negative/$round ];then
		mkdir -p ./data/negative/$round
	fi
	#perl select_negative_from_scanGenome.pl $PAS $scanTranscriptome $round $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold $prob $Shift
	echo "perl select_negative_from_scanGenome.reserved.pl $ENS $scanTranscriptome $round $RNASeqRCThreshold $prob $Shift"
	perl select_negative_from_scanGenome.reserved.pl $ENS $scanTranscriptome $round $RNASeqRCThreshold $prob $Shift
	#perl select_negative_from_scanGenome.onlymodtif.pl $ENS $scanTranscriptome $round $RNASeqRCThreshold $prob $Shift
fi

if [ "$task" == "get" ]; then
	scans=($dir/chr*)
	scan=${scans[$SLURM_ARRAY_TASK_ID]}
	baseName=${scan##*/}
	bidirection="maxSum/${Testid}.${baseName}.txt.bidirection.${maxPoint}.${penality}.txt"
	#out="results/${Testid}.${maxPoint}.${penality}.${baseName}.txt"
	out2="results/Coverage.${Testid}.${maxPoint}.${penality}.${baseName}.txt"
	perl change_all.pl $ENS $PAS $bidirection $scan $out2
fi


#task='eva'
if [ "$task" == "Evaluation" ]; then
	source ~/.bashrc
	conda activate ML
	cmd="python get_files.py --root_dir $dir --round $round --set $setName"
	va=$($cmd 2>&1)
	IFS=' ' read -r -a array <<< "$va"
	scanTranscriptome=${array[$SLURM_ARRAY_TASK_ID]}
	echo $scanTranscriptome

	baseName=${scanTranscriptome##*/}
	predict="predict/$Testid.$baseName.txt"
	echo "Starting evaluation"
	echo $predict
	python3 evaluate.py --model $model --data $scanTranscriptome --out $predict --cov $RNASeqRCThreshold --polyAfile $polyAfile  --combination $combination --window $window

	#New="Yes"
	#python3 scanTranscriptome.py --testid $Testid --baseName $baseName --threshold $maxPoint
	#python3 statScan.py --testid $Testid --baseName $baseName --threshold $maxPoint --info $info --pasfile $PAS --polyASeqRCThreshold $polyASeqRCThreshold --RNASeqRCThreshold $RNASeqRCThreshold --usageThreshold $usageThreshold
	#predict_res="map/${Testid}.${baseName}.peak${maxPoint}.txt"

	New="No"
	perl scanGenome.maximum_sum4.chr.pl  0 $penality $predict
	perl scanGenome.maximum_sum4.reverse.chr.pl 0 $penality $predict
	perl postprocess.bidirection.pl $maxPoint $penality  $PAS  $DB $predict $info $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold
	predict_res="maxSum/$Testid.$baseName.txt.bidirection.$maxPoint.$penality.txt"

	number=${round: -1}
	((number+=1))
	newround=${round:0:-1}$number

	if [ ! -d data/negative/$newround ];then
		mkdir -p data/negative/$newround
	fi
	negative="data/negative/$round/$baseName"
	out="data/negative/$newround/$baseName"
	if [ $setName = 'train' ];then
		echo
		echo "perl change_negative.pl $ENS $predict_res $PAS $scanTranscriptome $negative $out $round $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold $Shift $New"
		#perl change_negative.pl $ENS $predict_res $PAS $scanTranscriptome $negative $out $round $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold $Shift $New
	else
		echo
		#cp data/negative/$round/$baseName data/negative/$newround/$baseName
		#perl change_negative.pl $ENS $predict_res $PAS $scanTranscriptome $negative $out $round $polyASeqRCThreshold $RNASeqRCThreshold $usageThreshold $Shift $New
	fi
fi


echo "job  end  at" `date "+%Y-%m-%d %H:%M:%S"`
time_end=$(date +"%s")
duration=$(($time_end-$time_start))
echo "Run time: $(($duration/3600)):$((($duration/60)%60)):$(($duration % 60))"
echo
