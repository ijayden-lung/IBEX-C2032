#!/bin/bash
#SBATCH --job-name=mountainClimber
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
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

SAMPLE="K562"
Origin_BAM="/home/longy/project/Split_BL6/STAR/${SAMPLE}_Chen/Aligned.sortedByCoord.out.bam"
BAM="BAM/$SAMPLE.$chr.bam"
Origin_CHROM="/home/longy/cnda/STAR_INDEX/hg38len100/chrNameLength.txt"
CHROM="BAM/$chr.chrom.size"
Origin_GTF="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf"
GTF="BAM/$chr.gtf"
FA="/home/longy/cnda/ensembl/chromsome/hg38.$chr.fa"

PAS="../usage_data/${SAMPLE}_Chen.pAs.usage.txt"
DB="../usage_data/${SAMPLE}_Chen.pAs.merge.coverage.txt"
OUT="../Figures/${SAMPLE}/predicted.mountainClimber.txt"

:<<BL
samtools view -b $Origin_BAM  $chr >$BAM
#perl src/get_chrom_size.pl  $chr $Origin_CHROM $CHROM
#perl src/get_chrom_size.pl  $chr $Origin_GTF $GTF


python ./src/get_junction_counts.py -i $BAM -s fr-firststrand -o ./junctions/$SAMPLE.$chr.bed

bedtools genomecov -strand + -trackline -bg -split -ibam $BAM -g $CHROM > ./bedgraph/$SAMPLE.$chr."+".bedgraph
bedtools genomecov -strand - -trackline -bg -split -ibam $BAM -g $CHROM > ./bedgraph/$SAMPLE.$chr."-".bedgraph

python ./src/mountainClimberTU.py -b ./bedgraph/$SAMPLE.$chr."+".bedgraph -j ./junctions/$SAMPLE.$chr.bed -s 1 -g $CHROM  -o mountainClimberTU/${SAMPLE}.$chr."+"._tu.bed
python ./src/mountainClimberTU.py -b ./bedgraph/$SAMPLE.$chr."-".bedgraph -j ./junctions/$SAMPLE.$chr.bed -s -1 -g $CHROM  -o mountainClimberTU/${SAMPLE}.$chr."-"._tu.bed

python ./src/merge_tus.py -i ./mountainClimberTU/$SAMPLE.$chr.+._tu.bed ./mountainClimberTU/$SAMPLE.$chr.-._tu.bed  --ss 'y' -g $GTF -o tus_merged/$SAMPLE
python ./src/mountainClimberCP.py -i ./bedgraph/$SAMPLE.$chr."+".bedgraph -m ./bedgraph/$SAMPLE.$chr."-".bedgraph -g tus_merged/$SAMPLE.annot.${chr}_singleGenes.bed  -j ./junctions/$SAMPLE.$chr.bed -o mountainClimberCP/$SAMPLE.$chr.bed -x $FA -t 1 

python ./src/mountainClimberRU.py -i mountainClimberCP/$SAMPLE.$chr.bed -o mountainClimberRU/$SAMPLE.$chr.bed
BL
perl postprocess.bidirection.pl $PAS $DB ${SAMPLE}.all.bed $SAMPLE.usage.bed $OUT 3.5 0.05 0.05
