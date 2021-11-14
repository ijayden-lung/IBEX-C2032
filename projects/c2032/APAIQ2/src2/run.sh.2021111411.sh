#!/bin/bash

model='../model/snu398_regression.ckpt'
factor_path='../model/normalize_factor'
pas_file='test21.txt'
input_plus="../demo/fwd.norm.bedGraph"
input_minus="../demo/rev.norm.bedGraph"
out='out.txt'

python evaluateRegression.py --model=$model --factor_path=$factor_path --pas_file=$pas_file --input_plus=$input_plus --input_minus=$input_minus --out=$out
