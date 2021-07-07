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
old='thle2'
spe='snu398' #[k562,hepg2,huh7,thle2,snu398]
round=4
learning_rate=1e-4 #####small learning rate for fine tuning
task='evaluation'   ##task = [preparation training evaluation statistics]
transfer="Finetune" ##[Transfer Finetune]
bestEpoch=0069
if [ "$old" == "huh7" ]; then
	oldmodel="bestModel/huh7_control.pAs.single_kermax6.huh7_control_aug8_SC_p1r0.03u0.05_4-0021.ckpt"
elif [ "$old" == "k562" ]; then
	oldmodel="bestModel/k562_chen.pAs.single_kermax6.k562_chen_aug8_SC_p5r0.03u0.05_4-0010.ckpt"
elif [ "$old" == "hepg2" ]; then
	oldmodel="bestModel/hepg2_control.pAs.single_kermax6.hepg2_control_aug8_SC_p1r0.03u0.05_4-0143.ckpt"
elif [ "$old" == "snu398" ]; then
	oldmodel="bestModel/snu398_control.pAs.single_kermax6.snu398_control_aug8_SC_p1r0.03u0.05_4-0206.ckpt"
elif [ "$old" == "thle2" ]; then
	oldmodel="bestModel/thle2_control.pAs.single_kermax6.thle2_control_aug8_SC_p1r0.03u0.05_4-0012.ckpt"
fi

if [ "$spe" == "hepg2" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="hepg2_control"
	block_num=280   
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05

elif [ "$spe" == "k562" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="k562_chen"
	block_num=223
	polyASeqRCThreshold=5
	RNASeqRCThreshold=0.03
	usageThreshold=0.05

elif [ "$spe" == "brain" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="human_brain"
	block_num=571
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05

elif [ "$spe" == "snu398" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="snu398_control"
	block_num=406
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05


elif [ "$spe" == "huh7" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="snu398_control"
	block_num=310
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05

elif [ "$spe" == "thle2" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="thle2_control"
	block_num=152
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05

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

if [ $transfer != "Finetune" ] && [ $transfer != "Transfer" ]; then
	echo "Invalid transfer pamater $transfer"
	exit 1
fi

trainid="${transfer}_${old}To${spe}"
model=$oldmodel
roundName="${sample}_${augmentation}_${combination}_p${polyASeqRCThreshold}r${RNASeqRCThreshold}u${usageThreshold}_${round}"
Testid="${trainid}.${roundName}-${bestEpoch}"
if [ $transfer == "Finetune" ] && [ $task != "training" ]; then
	model="Model/${Testid}.ckpt"
fi
	
dir="../Split_BL6/${sample}_data"
DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
info="../Split_BL6/${sample}_data/info.txt"
echo $block_num
block_idx=$(($block_num-1))
valid_idx=$(($block_num/5-1))
train_idx=$(($block_num/5*4-1))
test_idx=$(($block_num%5-1))
#########PARAMETER CHANGED


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
	python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='all' --maxPoint $maxPoint --penality $penality

else
	echo "Invalid task parameter"
	echo "task = [preparation training evaluation statistics]"
fi
