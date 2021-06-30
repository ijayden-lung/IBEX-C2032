#!/bin/bash
#SBATCH --job-name=fastq-dump
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=16:00:00
#SBATCH --output=log.%J
#SBATCH --error=err.%J
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --dependency=afterok:8186700
#SBATCH --mem=300G
#SBATCH -a 0
fastq-dump -I --split-files --gzip SRR8040781
fastq-dump -I --split-files --gzip SRR8040782
fastq-dump -I --split-files --gzip SRR8040783
fastq-dump -I --split-files --gzip SRR8040784
fastq-dump -I --split-files --gzip SRR8040785
fastq-dump -I --split-files --gzip SRR8040786
fastq-dump -I --split-files --gzip SRR8040787
fastq-dump -I --split-files --gzip SRR8040788
fastq-dump -I --split-files --gzip SRR8040789
fastq-dump -I --split-files --gzip SRR8040790
fastq-dump -I --split-files --gzip SRR8040791
