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
#SBATCH --mem=10G
##SBATCH --gres=gpu:1
#SBATCH --dependency afterok:15061039_[0-191] 
##SBATCH -a 0-39

#########TRAIN
######Yongkang Long Update at Jan 05, 2021. 
######Tommorrow. I have to write function of data augmentation. Augmentation every epoch
#""""Check bl6 gene number""""
echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"

##########################################################################
#########PARAMETER CHANGED
prob=1 ##### K562 0.00922
Shift=8
window=201
augmentation="aug$Shift" ####augmentation= [AUG NOAUG]
combination='SC' ####combination = [SCP SC SP CP S C P]
epochs=500
maxPoint=12
penality=1
######Modified distance<38 PAS usage jiaquan
######Check gene RPS8 chr1:44778703 44778755
spe='HepG2'
round=4
learning_rate=6e-4 #####small learning rate for fine tuning
task='statistics'   ##task = [preparation training evaluation statistics]
if [ "$spe" == "HepG2" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="HepG2_Control"
	block_num=315   
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	#oldmodel="bestModel/BL6_REP1.pAs.single_kermax6.BL6_REP1_aug8_SC_p5r10u0.05_4-0026.ckpt"
	oldmodel="bestModel/K562_Chen.pAs.single_kermax6.K562_Chen_aug8_SC_p5r0.03u0.05_4-0024.ckpt"
	trainid="Finetune_K562ToHepG2"
	
	roundName="${sample}_${augmentation}_${combination}_p${polyASeqRCThreshold}r${RNASeqRCThreshold}u${usageThreshold}_${round}"
	Testid="${trainid}.${roundName}-${bestEpoch}"
	#Testid="Transfer_K562ToHepG2_24"
	model=$oldmodel
	
	dir="../Split_BL6/${sample}_data/Blocks"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
	info="../Split_BL6/${sample}_data/Blocks/info.txt"

elif [ "$spe" == "K562" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="K562_Chen"
	block_num=192
	polyASeqRCThreshold=7
	RNASeqRCThreshold=9
	usageThreshold=0.05
	trainid="${sample}.pAs.single_kermax6"
	dir="../Split_BL6/K562_Chen_data/Blocks"
	DB="../Split_BL6_PolyARead/usage_data/K562_Chen.pAs.coverage.txt"
	info="../Split_BL6/K562_Chen_data/Blocks/info.txt"


elif [ "$spe" == "BL6" ]; then
	ENS='/home/longy/cnda/ensembl/Mus_musculus.GRCm38.103.gtf.gz'
	sample="BL6_REP1"
	block_num=247
	polyASeqRCThreshold=5
	RNASeqRCThreshold=10
	usageThreshold=0.05
	maxPoint=12
	penality=1
	trainid="${sample}.pAs.single_kermax6"
fi
block_idx=$(($block_num-1))
valid_idx=$(($block_num/5-1))
train_idx=$(($block_num/5*4-1))
test_idx=$(($block_num%5-1))
#########PARAMETER CHANGED
###########################################################################


###########################################################################
###########IMPORTANT FILE PATH
PAS="../Split_BL6_PolyARead/usage_data/${sample}.pAs.usage.txt"
polyAfile="../Split_BL6_PolyARead/BAM/BL6_REP1.PolyACount.txt"

###########IMPORTANT FILE PATH
###########################################################################


if [ "$task" == "training" ]; then
	echo "starting task $task"
	#python3 prep_data.py --root_dir data --round $roundName  --out bl6.pAst.text.npz
	echo $oldmodel
	python3 train.py --root_dir data --block_dir $dir --round $roundName  --trainid $trainid.$roundName --model $oldmodel --polyAfile $polyAfile  --combination $combination --learning_rate $learning_rate --epochs $epochs


elif [ "$task" == "evaluation" ]; then
	###Num of Train: 144, Num of valid 36, Num of test: 21
	echo "starting task $task"
	sbatch --job-name='Eva_train' --array=0-$train_idx  --export=dir=$dir,ENS=$ENS,PAS=$PAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='train',task='Evaluation',window=$window run_array_blocks.sh
	sbatch --job-name='Eva_valid' --array=0-$valid_idx  --export=dir=$dir,ENS=$ENS,PAS=$PAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='valid',task='Evaluation',window=$window run_array_blocks.sh
	sbatch --job-name='Eva_test' --array=0-$test_idx --export=dir=$dir,ENS=$ENS,PAS=$PAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='test',task='Evaluation',window=$window run_array_blocks.sh


elif [ "$task" == "statistics" ]; then
	echo "starting task $task"
	python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='train' --maxPoint $maxPoint --penality $penality
	python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='valid' --maxPoint $maxPoint --penality $penality
    python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='test' --maxPoint $maxPoint --penality $penality

else
	echo "Invalid task parameter"
	echo "task = [preparation training evaluation statistics]"
fi
