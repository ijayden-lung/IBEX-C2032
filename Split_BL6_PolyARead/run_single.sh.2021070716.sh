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
Shift=8
window=201
augmentation="aug$Shift" ####augmentation= [AUG NOAUG]
combination='SC' ####combination = [SCP SC SP CP S C P]
epochs=500
maxPoint=12
penality=1
######Modified distance<38 PAS usage jiaquan
######Check gene RPS8 chr1:44778703 44778755
cell='k562'
spe='hg38'
bestEpoch=0180 #kk562_4 180#bl6 149 69 66 15 4#brain 258 25 12 168 1#thle2 186 37 17 102 12#huh7 182 49 19 41 21#snu398 341 271 91 334 206 #k562 138 111 47 33 10 #hegp2 236 52 105 12 143
round=1
learning_rate=9e-4 #####small learning rate for fine tuning
task='training'   ##tak = [preparation training evaluation statistics]
if [ "$cell" == "hepg2" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="hepg2_control"
	block_num=280
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	trainid="hepg2_control.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
	info="../Split_BL6/${sample}_data/info.txt"

elif [ "$cell" == "brain" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="human_brain"
	block_num=571
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	trainid="${sample}.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
	info="../Split_BL6/${sample}_data/info.txt"

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
	info="../Split_BL6/${sample}_data/info.txt"

elif [ "$cell" == "snu398" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="snu398_control"
	block_num=406
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	trainid="snu398_control.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
	info="../Split_BL6/${sample}_data/info.txt"

elif [ "$cell" == "huh7" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="huh7_control"
	block_num=310
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	trainid="huh7_control.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
	info="../Split_BL6/${sample}_data/info.txt"

elif [ "$cell" == "thle2" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="thle2_control"
	block_num=152
	polyASeqRCThreshold=1
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	trainid="thle2_control.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
	info="../Split_BL6/${sample}_data/info.txt"

elif [ "$cell" == "k562" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="k562_chen"
	block_num=223
	polyASeqRCThreshold=4
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	trainid="${sample}.pAs.single_kermax6"
	dir="../Split_BL6/k562_chen_data"
	DB="../Split_BL6_PolyARead/usage_data/k562_chen.pAs.merge.coverage.txt"
	info="../Split_BL6/k562_chen_data/info.txt"

elif [ "$cell" == "Merge" ]; then
	ENS='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz'
	sample="K562_Merge"
	block_num=192
	polyASeqRCThreshold=4
	RNASeqRCThreshold=9
	usageThreshold=0.05
	maxPoint=12
	penality=1
	trainid="${sample}.pAs.single_kermax6"
	dir="../Split_BL6/K562_Chen_data/Blocks"
	DB="../Split_BL6_PolyARead/usage_data/K562_Chen.pAs.coverage.txt"
	info="../Split_BL6/K562_Chen_data/Blocks/info.txt"

elif [ "$cell" == "bl6" ]; then
	ENS='/home/longy/cnda/ensembl/Mus_musculus.GRCm38.102.gtf.gz'
	sample="bl6_rep1"
	block_num=212
	polyASeqRCThreshold=5
	RNASeqRCThreshold=0.03
	usageThreshold=0.05
	maxPoint=12
	penality=1
	trainid="${sample}.pAs.single_kermax6"
	dir="../Split_BL6/${sample}_data"
	DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
	info="../Split_BL6/${sample}_data/info.txt"

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
PAS="../Split_BL6_PolyARead/usage_data/${sample}.pAs.usage.txt"
#DB="../Split_BL6_PolyARead/usage_data/${sample}.pAs.coverage.txt"
#info="../Split_BL6/${sample}_data/Blocks/info.txt"
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
	sbatch --job-name='Prepare' --array=0-$block_idx --export=dir=$dir,ENS=$ENS,PAS=$PAS,round=$roundName,task='Prepare',augmentation=$augmentation,prob=$prob,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,spe=$spe run_array_blocks.sh


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
	sbatch --job-name='Eva_train' --array=0-$train_idx  --export=dir=$dir,ENS=$ENS,PAS=$PAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='train',task='Evaluation',window=$window run_array_blocks.sh
	sbatch --job-name='Eva_valid' --array=0-$valid_idx  --export=dir=$dir,ENS=$ENS,PAS=$PAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='valid',task='Evaluation',window=$window run_array_blocks.sh
	sbatch --job-name='Eva_test' --array=0-$test_idx --export=dir=$dir,ENS=$ENS,PAS=$PAS,DB=$DB,info=$info,Testid=$Testid,model=$model,round=$roundName,combination=$combination,polyAfile=$polyAfile,polyASeqRCThreshold=$polyASeqRCThreshold,RNASeqRCThreshold=$RNASeqRCThreshold,usageThreshold=$usageThreshold,Shift=$Shift,maxPoint=$maxPoint,penality=$penality,setName='test',task='Evaluation',window=$window run_array_blocks.sh


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
