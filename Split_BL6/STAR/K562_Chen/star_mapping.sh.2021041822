#!/bin/bash
#SBATCH --job-name=STAR
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=2:00:00
#SBATCH --output=log.%J
#SBATCH --error=err.%J
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --mem=200G
#SBATCH -a 0




echo 'starting mapping with STAR'



cd /home/longy/project/Split_BL6/STAR/K562_Chen/
genomeIndex="/ibex/scratch/longy/cnda/STAR_INDEX/hg38len149"
fq1="/home/longy/project/Split_BL6/STAR/K562_Chen/K562-mRNA_R1_001.fastq.gz"
fq2="/home/longy/project/Split_BL6/STAR/K562_Chen/K562-mRNA_R2_001.fastq.gz"
STAR  --twopassMode Basic --runThreadN 32 --genomeDir $genomeIndex  --readFilesIn $fq1 $fq2 --outSAMtype BAM SortedByCoordinate --outSAMattrIHstart 0  --outFilterMultimapScoreRange 0  --alignEndsType Local  --readFilesCommand zcat  --outSAMstrandField intronMotif --outFilterType BySJout --outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000
