#!/bin/bash
#SBATCH --job-name=LIFTOVER
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=24:00:00
#SBATCH --mem=50G
#SBATCH --output=log.%J
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=END
#SBATCH --gres=gpu:1

#####Modify parameter
threads=16




liftOver human_liver.hg37.rep1.bed /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human_liver.hg38.rep1.bed unMapped1

#liftOver human_brain.hg37.rep1.bed /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human_brain.hg38.rep1.bed unMapped1
#liftOver human_brain.hg37.rep2.bed /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human_brain.hg38.rep2.bed unMapped2

#liftOver mouse.PAS.bed /ibex/scratch/longy/cnda/ucsc/mm9ToMm10.over.chain mouse.PAS.mm10.bed unMapped
#liftOver human.pAs.brain.bed /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human.pAs.brain.hg38.bed unMapped
#liftOver human.pAs.brain.union.bed /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human.pAs.brain.hg38.union.bed unMapped
#liftOver human.PAS.bed /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human.PAS.hg38.bed human_unMapped
#liftOver GSM747473_human_maqc-brain1.sites.clustered.hg19.bed  /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human_brain.hg38.rep1.bed human1_unMapped
#liftOver GSM747474_human_maqc-brain2.sites.clustered.hg19.bed  /ibex/scratch/longy/cnda/ucsc/hg19ToHg38.over.chain human_brain.hg38.rep2.bed  human2_unMapped
