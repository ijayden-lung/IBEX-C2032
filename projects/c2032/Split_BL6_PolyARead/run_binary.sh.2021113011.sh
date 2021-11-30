#!/bin/bash

data='binary/k562.binary.txt'
predict='binary/k562.predict.txt'
combination='C'
model='Model/K562_Chen.pAs.single_kermax6.K562_Chen_aug12_C_p3.5r0.05u0.05_0-0479.ckpt'
RNASeqRCThreshold=0
window=201

python3 evaluate.py --model=$model --data=$data --out=$predict --cov=$RNASeqRCThreshold --combination $combination --window $window
perl binary/stat.pl $data $predict
