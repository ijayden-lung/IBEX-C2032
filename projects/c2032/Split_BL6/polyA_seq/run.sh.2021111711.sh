#! /bin/bash
#SBATCH --job-name=Bed
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=LOG/log.%J
#SBATCH --error=LOG/err.%J
#SBATCH --time=4:00:00
#SBATCH --mem=100G
##SBATCH -a 0
##SBATCH --gres=gpu:1

:<<BL
sample="bl6_rep1"
ENS="/home/longy/cnda/ensembl/Mus_musculus.GRCm38.102.gtf.gz";
coverage="../../Split_BL6_PolyARead/usage_data/${sample}.pAs.merge.coverage.txt"
#data="../../Split_BL6_PolyARead/usage_data/BL6_REP1.pAs.predict.aug8_SC_p5r10u0.05_4-0026.12.2.txt"
#testid='predict.aug8_SC_p5r10u0.05_4-0026.12.2'
#target="BL6.REP1.pAs.${testid}.bed"
#new="BL6_REP1.pAs.${testid}.usage.txt"
target="${sample}.pAs.bed"
new="${sample}.pAs.usage.txt"
mod1="modMSX_021.bed"
mod2="modMSX_022.bed"
BL
#:<<BL
#ENS="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz"
ENS="/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz";
coverage="../../Split_BL6_PolyARead/usage_data/K562_Chen.pAs.merge.coverage.txt"
target="K562_Chen.pAs.bed"
new="K562_Chen.pAs.merge.usage.txt"

bam1="K562_ChenAligned.out.bam"
bam2="K562_ChenAligned.out.bam"
mod1="modK562_1.bed"
mod2="modK562_2.bed"
#BL
:<<BL
ENS="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz"
coverage="../../Split_BL6_PolyARead/usage_data/human_liver.pAs.merge.coverage.txt"
target="human_liver.pAs.bed"
BL

:<<BL
#samtools view -q 255 -f 2 -@ 16 $bam1 -b -o tem1.bam 
#samtools view -q 255 -f 2 -@ 16 $bam2 -b -o tem2.bam 
samtools view -q 255 -@ 16 $bam1 -b -o tem1.bam 
samtools view -q 255 -@ 16 $bam2 -b -o tem2.bam 
echo "Fnished get unique mapped reads"
samtools sort tem1.bam -@ 16 -o unique1.bam
samtools sort tem2.bam -@ 16 -o unique2.bam
echo "Fnished sorting bam"
rm tem1.bam
rm tem2.bam
echo "remove temoporary bam file"
bedtools bamtobed -i unique1.bam> unique1.bed
bedtools bamtobed -i unique2.bam> unique2.bed
echo "Finished transfer bam to bed"
rm unique1.bam unique2.bam
echo "remove unique bam files"
perl change_postion.pl unique1.bed $mod1 "pair"
perl change_postion.pl unique2.bed $mod2 "pair"
echo "Fnished change position"
BL
perl generate_bed.pl $coverage $target
bedtools coverage -a $target -b $mod1 -S -sorted -counts > $target.021.counts
bedtools coverage -a $target -b $mod2 -S -sorted -counts > $target.022.counts
perl merge_rep.pl $target.021.counts $target.022.counts $target.info

perl calculate_usage.tianbin.pl $coverage $target.info $target.info.cutoff $ENS


perl process_error_name.pl $ENS $target.info.cutoff  $new
#rm $target $target.021.counts $target.022.counts $target.info # $target.info.cutoff
