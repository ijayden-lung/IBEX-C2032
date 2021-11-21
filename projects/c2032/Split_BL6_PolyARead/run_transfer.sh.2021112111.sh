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
prob=1 
Shift=12
window=201
augmentation="aug$Shift" ####augmentation= [AUG NOAUG]
combination='SC' ####combination = [SCP SC SP CP S C P]
epochs=500
maxPoint=12
penality=1
######Modified distance<38 PAS usage jiaquan
######Check gene RPS8 chr1:44778703 44778755
old='k562'
cell='hepg2' #[k562,hepg2,huh7,thle2,snu398]
spe='hg38'
round=4
learning_rate=5e-4 #####small learning rate for fine tuning
task='statistics'   ##task = [preparation training evaluation statistics]
bestEpoch=0
transfer="Transfer" ##[Transfer Finetune]
trainid="${transfer}_${old}To${cell}"
if [ "$old" == "huh7" ]; then
	oldmodel="bestModel/huh7_control.pAs.single_kermax6.huh7_control_aug8_SC_p1r0.03u0.05_4-0021.ckpt"
elif [ "$old" == "k562" ]; then
	oldmodel="bestModel/k562_chen.pAs.single_kermax6.k562_chen_aug8_SC_p3.5r0.03u0.05_4-0020.ckpt"
elif [ "$old" == "hepg2" ]; then
	oldmodel="bestModel/HepG2_Control.pAs.single_kermax6.HepG2_Control_aug12_SC_p1r0.05u0.05_4-0010.ckpt"
elif [ "$old" == "snu398" ]; then
	oldmodel="bestModel/snu398_control.pAs.single_kermax6.snu398_control_aug12_SC_p1r0.05u0.05_4-0038.ckpt"
elif [ "$old" == "thle2" ]; then
	oldmodel="bestModel/thle2_control.pAs.single_kermax6.thle2_control_aug12_SC_p1r0.05u0.05_4-0010.ckpt"
elif [ "$old" == "bl6" ]; then
	oldmodel="bestModel/bl6_rep1.pAs.single_kermax6.bl6_rep1_aug8_SC_p5r0.03u0.05_4-0004.ckpt"
elif [ "$old" == "kh" ]; then
	oldmodel="bestModel/Finetune_k562Tohepg2.hepg2_control_aug8_SC_p1r0.03u0.05_4-0056.ckpt"
elif [ "$old" == "hk" ]; then
	oldmodel="bestModel/Finetune_hepg2Tok562.k562_chen_aug8_SC_p5r0.03u0.05_4-0007.ckpt"
fi

if [ "$cell" == "hepg2" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="HepG2_Control"
	block_num=210   
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05

elif [ "$cell" == "k562" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="K562_Chen"
	block_num=165
	polyASeqRCThreshold=3.5
	RNASeqRCThreshold=0.05
	usageThreshold=0.05

elif [ "$cell" == "brain" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="human_brain"
	block_num=430
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


elif [ "$cell" == "huh7" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="huh7_control"
	block_num=310
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05

elif [ "$cell" == "thle2" ]; then
	ENS='/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz'
	sample="thle2_control"
	block_num=114
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.05
	usageThreshold=0.05

elif [ "$cell" == "bl6" ]; then
	ENS='/home/longy/cnda/ensembl/Mus_musculus.GRCm38.103.gtf.gz'
	sample="bl6_rep1"
	block_num=212
	polyASeqRCThreshold=5
	RNASeqRCThreshold=0.05
	usageThreshold=0.05
fi

if [ $transfer != "Finetune" ] && [ $transfer != "Transfer" ]; then
	echo "Invalid transfer pamater $transfer"
	exit 1
fi

model=$oldmodel
roundName="${sample}_${augmentation}_${combination}_p${polyASeqRCThreshold}r${RNASeqRCThreshold}u${usageThreshold}_${round}"
Testid="${trainid}.${roundName}-${bestEpoch}"
if [ $transfer == "Finetune" ] && [ $task != "training" ]; then
	echo "use fine tune model"
	#model="bestModel/Finetune_thle2Tohepg2.hepg2_control_aug8_SC_p1r0.03u0.05_4-0069.ckpt"
	#model="bestModel/Finetune_k562Tothle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0002.ckpt"
	#model="bestModel/Finetune_hepg2Tothle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0001.ckpt"
	#model="bestModel/Finetune_k562Tohepg2.hepg2_control_aug8_SC_p1r0.03u0.05_4-0056.ckpt"
	#model="bestModel/Finetune_khTothle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0023.ckpt"
	#model="bestModel/Finetune_hkTokthle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0012.ckpt"
	model="bestModel/NewFinetune_k562Tothle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0004.ckpt"
fi
	
echo $model
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


elif [ "$task" == "get" ]; then
	echo "starting task $task"
	sbatch --job-name='get' --array=0-$block_idx --export=dir=$dir,ENS=$ENS,PAS=$PAS,Testid=$Testid,maxPoint=$maxPoint,penality=$penality,task='get' run_array_blocks.sh

elif [ "$task" == "statistics" ]; then
	echo "starting task $task"
	echo $Testid
	echo $roundName
	python merge_postpropose.py --root_dir=$dir --round=$roundName --trainid=$Testid --sets='all' --maxPoint $maxPoint --penality $penality

else
	echo "Invalid task parameter"
	echo "task = [preparation training evaluation statistics]"
fi
