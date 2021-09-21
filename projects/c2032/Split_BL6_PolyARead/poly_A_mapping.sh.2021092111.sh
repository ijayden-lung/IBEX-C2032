#!/bin/bash
#PBS -N human_pAs
#PBS -l nodes=1:ppn=12
#PBS -l walltime=10:00:00
#PBS -q ser
#PBS -j oe
#PBS -V

cd /home/bio-liys/qionghua/data/
re=HepG2_Vorinostat4uM_2
mkdir -p ${re}
cd /home/bio-liys/qionghua/data/${re}

fq_1=/home/bio-huangn/data/zhu_191115/1.rawdata/0922-HepG2-Vorinostat-4uM_FKDL192536270-1a-AK1177_1.fq.gz
fq_2=/home/bio-huangn/data/zhu_191115/1.rawdata/0922-HepG2-Vorinostat-4uM_FKDL192536270-1a-AK1177_2.fq.gz

cutadapt --cores=12 -u 2 -a N{12}AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -m 15 -o out.1.fq.gz -p out.2.fq.gz ${fq_1} ${fq_2}
cutadapt --cores=12 -u 12 -a N{2}AAAAAAAAAAAAAAAAAAAGATCGGAAGAGCGTCGTGTAGGG -m 15 -o ${re}.2.fq.gz -p ${re}.1.fq.gz out.2.fq.gz out.1.fq.gz
rm out.2.fq.gz out.1.fq.gz
hisat2 --no-softclip -p 12 --no-discordant -x /home/bio-ligp/reference/hisat2/hg38_v92 -1 ${re}.1.fq.gz -2 ${re}.2.fq.gz -S ${re}.sam 

grep -v "ZS:i:" ${re}.sam | samtools view -b -f 0x2 >${re}.bam
rm ${re}.sam
bedtools bamtobed -i ${re}.bam > ${re}.bed
python3 /home/bio-liys/zm/Hek293/line.py ${re}
rm ${re}.bed
sort -k1,1 -k2,2n mod${re}.bed >${re}.bed.sorted
mv ${re}.bed.sorted mod${re}.bed

bedtools coverage -a /home/bio-liys/human_pAs/human_PAS_hg38.all.bed -b mod${re}.bed -S -sorted -counts > ${re}.bed.all.counts

awk '$6 == "-"' mod${re}.bed |sort -k1,1 >${re}_5.minus
awk '$6 == "+"' mod${re}.bed |sort -k1,1 >${re}_5.plus
bedtools genomecov -i ${re}_5.minus -g /home/bio-ligp/reference/hisat2/hg38.chrom.sizes -bg >total_${re}_5.minus.bedgraph
/home/bio-ligp/.local/bin/bedGraphToBigWig total_${re}_5.minus.bedgraph /home/bio-ligp/reference/hisat2/hg38.chrom.sizes total_${re}_5.minus.bw
bedtools genomecov -i ${re}_5.plus -g /home/bio-ligp/reference/hisat2/hg38.chrom.sizes -bg >total_${re}_5.plus.bedgraph
/home/bio-ligp/.local/bin/bedGraphToBigWig total_${re}_5.plus.bedgraph /home/bio-ligp/reference/hisat2/hg38.chrom.sizes total_${re}_5.plus.bw