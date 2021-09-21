#!/bin/bash
#SBATCH --job-name=mountainClimber
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --time=50:00:00
#SBATCH --mem=140G

####SBATCH --gres=gpu:1
######SBATCH -a 0-39
##SBATCH --dependency afterok:6686802_[1-100] 


SAMPLE="BL6_REP1"
CHROM="BAM/chr1.chrom.size"
GTF="BAM/chr1.gtf"
FA="/home/longy/cnda/ensembl/chromsome/mm10.1.fa"
BAM="BAM/chr1.bam"

#SAMPLE="BL6_REP1.NORM"
#BAM="BL6_REP1.bam"
#CHROM="/home/longy/cnda/STAR_INDEX/mm10len100/chrNameLength.txt"
#GTF="/home/longy/cnda/ensembl/Mus_musculus.GRCm38.95.gtf"
#FA="/home/longy/cnda/ensembl/Mus_musculus.GRCm38.dna.primary_assembly.fa"
:<<BL
python ./src/get_junction_counts.py -i $BAM -s fr-unstrand -o ./junctions/$SAMPLE.bed

bedtools genomecov -trackline -bg -split -ibam $BAM -g $CHROM > ./bedgraph/$SAMPLE.bedgraph

python ./src/mountainClimberTU.py -b ./bedgraph/$SAMPLE.bedgraph -j ./junctions/$SAMPLE.bed -s 0 -g $CHROM  -o mountainClimberTU/${SAMPLE}_tu.bed


python ./src/merge_tus.py -i ./mountainClimberTU/${SAMPLE}_tu.bed --ss n -g $GTF  -o tus_merged/tus_merged
BL

#python ./src/mountainClimberCP.py -i ./bedgraph/$SAMPLE.bedgraph -g tus_merged/tus_merged.annot.chr1_singleGenes.bed  -j ./junctions/$SAMPLE.bed -o mountainClimberCP/$SAMPLE.bed -x $FA
python ./src/mountainClimberRU.py -i mountainClimberCP/$SAMPLE.bed -o mountainClimberRU/$SAMPLE.bed


#rsem-prepare-reference -p 16 --gtf tus_merged/tus_merged.annot.gencode.vM25.primary_assembly.annotation.gtf --star --star  $FA  rsem_ref/rsem_ref

fq1="/home/longy/workspace/apa_predict/fastq/BL6_REP1_1.fastq.gz"
fq2="/home/longy/workspace/apa_predict/fastq/BL6_REP1_2.fastq.gz"

#STAR --readFilesIn $fq1 $fq2 --readFilesCommand zcat --genomeDir rsem_ref --outFilterType BySJout --outSAMattributes NH HI AS NM MD --outFilterMultimapNmax 200 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --sjdbScore 1 --runThreadN 16 --genomeLoad NoSharedMemory --outSAMtype BAM Unsorted --quantMode TranscriptomeSAM --outSAMheaderHD @HD VN:1.4 SO:unsorted




SAMPLE="BL6_REP1.NORM"
BAM="/home/longy/workspace/polyA_predict/STAR/BL6_REP1/Aligned.sortedByCoord.out.bam"
CHROM="mm10.chrom.sizes"
#GTF="/home/longy/cnda/gencode/gencode.vM25.primary_assembly.annotation.gtf"
GTF="/home/longy/cnda/ensembl/Mus_musculus.GRCm38.95.gtf"
FA="/home/longy/cnda/gencode/GRCm38.primary_assembly.genome.fa"


#samtools view -q 255 -b -@ 32 $BAM >BL6_REP1.bam
#BAM="BL6_REP1.bam"

#python ./src/get_junction_counts.py -i $BAM -s fr-firststrand -o ./junctions/$SAMPLE.bed

#bedtools genomecov -trackline -bg -split -ibam $BAM -g $CHROM -strand +  > ./bedgraph/$SAMPLE.+.bedgraph
#bedtools genomecov -trackline -bg -split -ibam $BAM -g $CHROM -strand -  > ./bedgraph/$SAMPLE.-.bedgraph

#python ./src/mountainClimberTU.py -b ./bedgraph/$SAMPLE.+.bedgraph -j ./junctions/$SAMPLE.bed -s 1 -g $CHROM  -o mountainClimberTU/${SAMPLE}_tu.+.bed

#python ./src/mountainClimberTU.py -b ./bedgraph/$SAMPLE.-.bedgraph -j ./junctions/$SAMPLE.bed -s -1 -g $CHROM  -o mountainClimberTU/${SAMPLE}_tu.-.bed

#python ./src/merge_tus.py -i ./mountainClimberTU/${SAMPLE}_tu.*.bed --ss y -g $GTF  -o tus_merged/tus_merged

#python ./src/mountainClimberCP.py -i ./bedgraph/$SAMPLE.bedgraph -g tus_merged/tus_merged.annot.chr1_singleGenes.bed  -j ./junctions/test.bed -o mountainClimberCP/$SAMPLE.bed -x $FA


#rsem-prepare-reference -p 16 --gtf tus_merged/tus_merged.annot.gencode.vM25.primary_assembly.annotation.gtf --star --star  $FA  rsem_ref/rsem_ref

fq1="/home/longy/workspace/apa_predict/fastq/BL6_REP1_1.fastq.gz"
fq2="/home/longy/workspace/apa_predict/fastq/BL6_REP1_2.fastq.gz"

#STAR --readFilesIn $fq1 $fq2 --readFilesCommand zcat --genomeDir rsem_ref --outFilterType BySJout --outSAMattributes NH HI AS NM MD --outFilterMultimapNmax 200 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --sjdbScore 1 --runThreadN 16 --genomeLoad NoSharedMemory --outSAMtype BAM Unsorted --quantMode TranscriptomeSAM --outSAMheaderHD @HD VN:1.4 SO:unsorted

#rsem-calculate-expression -p 32 --paired-end --append-names --seed 0 --estimate-rspd --sampling-for-bam --output-genome-bam --alignments Aligned.toTranscriptome.out.bam rsem_ref/rsem_ref BL6_REP1_rsem



BAM="BL6_REP1_rsem.transcript.bam"
#SAMPLE="BL6.REP1.trans"
#samtools view -q 100 -b -@ 32 BL6_REP1_rsem.transcript.bam | samtools sort -O bam -@ 32 |  bedtools genomecov -trackline -bg -split -ibam stdin -g $CHROM -strand +  > ./bedgraph/$SAMPLE.+.bedgraph
#samtools view -q 100 -b -@ 32 BL6_REP1_rsem.transcript.bam | samtools sort -O bam -@ 32 |  bedtools genomecov -trackline -bg -split -ibam stdin -g $CHROM -strand -  > ./bedgraph/$SAMPLE.-.bedgraph


#python ./src/mountainClimberCP.py -i ./bedgraph/$SAMPLE.+.bedgraph -g tus_merged/tus_merged.annot.gencode.vM25.primary_assembly.annotation_singleGenes.bed  -j ./junctions/BL6_REP1.NORM.bed -o mountainClimberCP/$SAMPLE.+.bed -x $CHROM
#python ./src/mountainClimberCP.py -m ./bedgraph/$SAMPLE.-.bedgraph -g tus_merged/tus_merged.annot.gencode.vM25.primary_assembly.annotation_singleGenes.bed  -j ./junctions/BL6_REP1.NORM.bed -o mountainClimberCP/$SAMPLE.-.bed -x $CHROM

