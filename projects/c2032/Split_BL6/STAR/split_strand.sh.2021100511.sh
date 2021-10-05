#!/bin/bash
samtools view -q 255 -b SNU398_Control/Aligned.sortedByCoord.out.bam 22 -o chr22.unique.bam
samtools index chr22.unique.bam
samtools view -b -f 128 -F 16 chr22.unique.bam > a.fwd1.bam
samtools view -b -f 80 chr22.unique.bam > a.fwd2.bam
samtools merge -f fwd.bam a.fwd1.bam a.fwd2.bam
samtools index fwd.bam
bedtools genomecov -ibam fwd.bam -split -bg >fwd1.bedGraph
rm a.fwd*.bam


samtools view -b -f 144 chr22.unique.bam > a.rev1.bam
samtools view -b -f 64 -F 16 chr22.unique.bam > a.rev2.bam
samtools merge -f rev.bam a.rev1.bam a.rev2.bam
samtools index rev.bam
bedtools genomecov -ibam rev.bam -split -bg >rev1.bedGraph
rm a.rev*.bam


