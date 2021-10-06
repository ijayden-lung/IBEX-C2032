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
#SBATCH --time=2:00:00
#SBATCH --mem=50G
#SBATCH --gres=gpu:1
##SBATCH --dependency afterok:15061029_[0-191] 
##SBATCH -a 0-39

#########TRAIN
#""""Check bl6 gene number""""
echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"

##########################################################################
#########PARAMETER CHANGED
prob=0.004 ##### K562 0.00922
window=201
combination='S' ####combination = [SCP SC SP CP S C P]
epochs=500
maxPoint=12
penality=1
cell='THLE2' 
spe='hg38'
Shift=12
bestEpoch=0182
round=0
learning_rate=6e-4 #####small learning rate for fine tuning
task='training' ##tak = [preparation trainin evaluation statistics]
augmentation="aug$Shift" ####augmentation= [AUG NOAUG]
if [ "$cell" == "HepG2" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="HepG2_Control"
	block_num=210
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05


elif [ "$cell" == "liver" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="human_liver"
	block_num=455
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	trainid="${sample}.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"

elif [ "$cell" == "SNU398" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="SNU398_Control"
	block_num=301
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05

elif [ "$cell" == "snu398" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="snu398_control"
	block_num=301
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05

elif [ "$cell" == "HUH7" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="HUH7_Control"
	block_num=231
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05
	trainid="${sample}.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"

elif [ "$cell" == "thle2" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="thle2_control"
	block_num=114
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05

elif [ "$cell" == "THLE2" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="THLE2_Control"
	block_num=114
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05


elif [ "$cell" == "K562" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="K562_Chen"
	block_num=165
	polyASeqRCThreshold=3.5
	RNASeqRCThreshold=0.05
	usageThreshold=0.05


fi
roundName="${sample}_${augmentation}_${combination}_p${polyASeqRCThreshold}r${RNASeqRCThreshold}u${usageThreshold}_${round}"
block_idx=$(($block_num-1))
valid_idx=$(($block_num/5-1))
train_idx=$(($block_num/5*4-1))
test_idx=$(($block_num%5-1))
#########PARAMETER CHANGED
###########################################################################


###########################################################################
###########IMPORTANT FILE PATH
#dir="../Split_BL6/${sample}_data/Blocks"
trainid="${sample}.pAs.single_kermax6"
dir="../Split_BL6/${sample}_data"
DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
info="../Split_BL6/${sample}_data/info.txt"
PAS="../Split_BL6_PolyARead/usage_data/${sample}.pAs.usage.txt"
OLDPAS="../Split_BL6/polyA_seq/${sample}.pAs.usage.txt"
polyAfile="../Split_BL6_PolyARead/BAM/BL6_REP1.PolyACount.txt"

number=$round
((number-=1))
oldroundName=${roundName:0:-1}$number
oldmodel="Model/${trainid}.${oldroundName}-${bestEpoch}.ckpt"

Testid="${trainid}.${roundName}-${bestEpoch}"
model="Model/${Testid}.ckpt"
#model="bestModel/K562_Merge.pAs.single_kermax6.K562_Merge_aug8_SC_p4r9u0.05_4-0090.ckpt"
###########IMPORTANT FILE PATH
###########################################################################

#cd /home/longy/project/Split_BL6/
#python split_chr.py
#####Prepare data
if [ "$task" == "preparation" ]; then
	echo "starting task $task"
	####Extract PolyA 
	#perl extract.polyA.reads.pl BAM/BL6_REP1.sortedByName.bam BAM/BL6_REP1.0.8.bed PE
	sbatch --job-name='Prepare' --array=0-$block_idx --export=dir=$dir,ENS=$ENS,PAS=$PAS,round=$roundName,task='Prepare',augmentation=$augmentation,prob=$prob,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,spe=$spe,window=$window run_array_blocks.sh


elif [ "$task" == "get" ]; then
	echo "starting task $task"
	####Extract PolyA 
	#perl extract.polyA.reads.pl BAM/BL6_REP1.sortedByName.bam BAM/BL6_REP1.0.8.bed PE
	sbatch --job-name='get' --array=0-$block_idx --export=dir=$dir,ENS=$ENS,PAS=$PAS,Testid=$Testid,maxPoint=$maxPoint,penality=$penality,task='get' run_array_blocks.sh

elif [ "$task" == "training" ]; then
	echo "starting task $task"
	#python3 prep_data.py --root_dir data --round $roundName  --out bl6.pAst.text.npz
	echo $oldmodel
	python3 train.py --root_dir data --block_dir $dir --round $roundName  --trainid $trainid.$roundName --model $oldmodel --polyAfile $polyAfile  --combination $combination --learning_rate $learning_rate --epochs $epochs --window $window


elif [ "$task" == "evaluation" ]; then
	###Num of Train: 144, Num of valid 36, Num of test: 21
	echo "starting task $task"
	sbatch --job-name='Eva_train' --array=0-$train_idx  --export=dir=$dir,ENS=$ENS,PAS=$PAS,OLDPAS=$OLDPAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='train',task='Evaluation',window=$window run_array_blocks.sh
	sbatch --job-name='Eva_valid' --array=0-$valid_idx  --export=dir=$dir,ENS=$ENS,PAS=$PAS,OLDPAS=$OLDPAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='valid',task='Evaluation',window=$window run_array_blocks.sh
	sbatch --job-name='Eva_test' --array=0-$test_idx --export=dir=$dir,ENS=$ENS,PAS=$PAS,OLDPAS=$OLDPAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='test',task='Evaluation',window=$window run_array_blocks.sh


elif [ "$task" == "statistics" ]; then
	echo "starting task $task"
	python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='train' --maxPoint $maxPoint --penality $penality
	python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='valid' --maxPoint $maxPoint --penality $penality
    python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='test' --maxPoint $maxPoint --penality $penality
	python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='all' --maxPoint $maxPoint --penality $penality

else
	echo "Invalid task parameter"
	echo "task = [preparation training evaluation statistics]"
fi
