#!/bin/bash
#SBATCH --job-name=scanGenome
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --output=log.%J
#SBATCH --error=err.%J
#SBATCH --time=3:00:00
#SBATCH --mem=50G
##SBATCH --gres=gpu:1
#SBATCH -a 0-3
##SBATCH --dependency afterok:6686802_[1-100] 

#samples=(K562-3-seq_R1_001.fastq.gz K562-3-seq_R2_001.fastq.gz K562-mRNA_R1_001.fastq.gz K562-mRNA_R2_001.fastq.gz) 
cd /home/longy/project/Split_BL6/STAR/K562_Chen
samples=(trimmed/K562-3-seq_R1_001.fastq.gz trimmed/K562-3-seq_R2_001.fastq.gz trimmed/K562-3-seq_cutpolyA_R1_001.fastq.gz trimmed/K562-3-seq_cutpolyA_R2_001.fastq.gz) 
sample=${samples[$SLURM_ARRAY_TASK_ID]}
fastqc -t 16 $sample


