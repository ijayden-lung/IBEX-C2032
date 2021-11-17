#!/bin/bash
#SBATCH -N 1
#SBATCH --partition=batch
#SBATCH --array=1-10
#SBATCH -J My
#SBATCH -o My.%J.out
#SBATCH -e My.%J.err
#SBATCH --mail-user=yongkang.long@kaust.edu.sa
#SBATCH --mail-type=ALL
#SBATCH --time=01:30:00
#SBATCH --mem=100M
#SBATCH --gres=gpu:1
#SBATCH --constraint=[gpu]


echo $array
