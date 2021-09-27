#!/bin/bash
#SBATCH --job-name=aptardi
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=50:00:00
##SBATCH -a 0-22
#SBATCH --mem=30G
##SBATCH --gres=gpu:1
##SBATCH --dependency afterok:6686802_[1-100] 

#source activate ML

echo "This is job #${SLURM_ARRAY_JOB_ID}, task id ${SLURM_ARRAY_TASK_ID}"
chrs=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18"  "19" "20" "21" "22" "X")  

chr=${chrs[$SLURM_ARRAY_TASK_ID]}

SAMPLE="THLE2"
BAM="/home/longy/project/Split_BL6/STAR/${SAMPLE}_Control/Aligned.sortedByCoord.out.bam"
GTF="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf"
FA="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.dna.primary_assembly.fa"

PAS="../usage_data/${SAMPLE}_Control.pAs.usage.txt"
DB="../usage_data/${SAMPLE}_Control.pAs.coverage.txt"
OUT="../Figures/${SAMPLE}/predicted.mountainClimber.txt"

#stringtie $BAM -p 16 --fr -o output_dir/${SAMPLE}_stringtie.gtf -G $GTF
#perl Tobed2.pl $PAS output_dir/${SAMPLE}_polya_sites.bed

python src/aptardi/scripts/aptardi --b $BAM --f $FA --r output_dir/${SAMPLE}_stringtie.gtf --g ${SAMPLE}_aptardi.gtf --m --e ${SAMPLE}_model.hdf5 --k ${SAMPLE}_scale.pk --s output_dir/${SAMPLE}_polya_sites.bed --l 0,4,1 --o output_dir
#python src/aptardi/scripts/aptardi --b demo/sorted.bam --f demo/hg38.fa --r demo/stringtie.gtf --g name_aptardi.gtf --n output_dir/name_model.hdf5 --t output_dir/name_scale.pk  --o output_dir

