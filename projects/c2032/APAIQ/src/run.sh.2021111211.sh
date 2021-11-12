#!/bin/bash

python APAIQ.v.1.0.py --input_file='../demo/fwd.norm.bedGraph'  --name='sample_name'  --model='../model/snu398_model.ckpt' --fa_file='/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.dna.primary_assembly.fa' --depth=1 --threshold=12
