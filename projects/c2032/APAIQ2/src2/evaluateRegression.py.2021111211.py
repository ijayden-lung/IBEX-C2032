from RegressionModel import *
import os, sys, copy, re, argparse
import random
import pandas as pd 
import numpy as np
from collections import defaultdict


def normalize(data,pseudo_count,data_mean,data_std):
    data = np.log(data+pseudo_count)
    data = (data-data_mean)/data_std
    return data

def read_bg(bg_file,depth):
    bg_dict = defaultdict(dict)
    with open(bg_file,'r') as bg:
        for line in bg.readlines():
            chromosome,start,end,rpm = line.split('\t')
            if ('chr' not in chromosome):
                chromosome = 'chr'+chromosome
            if(len(chromosome)>5 or 'Y' in chromosome or 'M' in chromosome):
                continue
            rpm = float(rpm)/depth
            start = int(start)+1
            end = int(end)+1
            for i in range(start,end):
                bg_dict[chromosome][i] = rpm
    return bg_dict



# block is the output from bedgraph_to_block
def dataProcessing(input_file,window,bg_dict_plus,bg_dict_minus,threshold):
    data1 = []
    PASID = []
    with open(input_file,'r') as inp:
        for line in inp.readlines():
            if (line.startswith('#')):
                continue
            line = line.rstrip('\n')
            chromosome,start,end,score,pasid,strand = line.split('\t')[0:6]
            pos = int(end)
            score = float(score)
            if(score >=threshold):
                coverage = np.zeros(window)
                extend  = int(window/2)
                for i in range(window):
                    if(strand == '+'):
                        new_pos = pos+i-extend
                        pos_dict_plus = bg_dict_plus[chromosome]
                        print(new_pos)
                        if(new_pos in pos_dict_plus):
                            coverage[i] = pos_dict_plus[new_pos]
                    elif(strand == '-'):
                        new_pos = pos-i+extend
                        pos_dict_minus = bg_dict_minus[chromosome]
                        if(new_pos in pos_dict_minus):
                            coverage[i] = pos_dict_minus[new_pos]
                coverage = np.array(coverage).astype(np.float32)
                data1.append(coverage)
                PASID.append(pasid)
    if PASID != []:
        data1 = np.stack(data1).reshape([-1, window, 1])
        PASID = np.array(PASID)
        return data1,PASID
    else:
        return
        
def args():
    parser = argparse.ArgumentParser(description="Evaluate each locus with RNAseq coverage exceed threshold and return prediction score")
    parser.add_argument("--model", help="the model weights file", required=True)
    parser.add_argument('--window', default=1001, type=int, help='input length')
    args = parser.parse_args()
    
    model = args.model
    window=args.window

def Evaluate(cov_data,pasid,out,window,model,pseudo_count,data_mean,data_std):
    print('### Evaluation data processing')
    cov_data = normalize(cov_data,pseudo_count,data_mean,data_std)
    print("### Start Evaluating")
    keras_Model = Regression_CNN(window)
    keras_Model.load_weights(model)
    pred = keras_Model.predict({"cov_input":cov_data})    
    OUT=open(out,'w')
    OUT.write("pas_id\tpredict_readCount\n")
    label_mean = 2.39
    label_std  = 1.65
    for i in range(len(pred)):
        predict = pred[i][0]
        predict_readCount = np.exp(predict*label_std+label_mean)         
        OUT.write('%s\t%s\n'%(pasid[i],predict_readCount))
    OUT.close()
            
if __name__ == "__main__":
    model  = '../model/thle2.mse.linear-1000.ckpt'
    input_file = 'test.txt'
    #bg_plus = "../demo/fwd.norm.bedGraph"
    #bg_minus = "../demo/rev.norm.bedGraph"
    bg_plus = "../../Split_BL6/STAR/fwd1.bedGraph"
    bg_minus = "../../Split_BL6/STAR/rev1.bedGraph"
    out = 'out.txt'
    window = 1001
    threshold = 12
    data_mean = -1.09
    data_std  = 1.79
    pseudo_count = 0.05
    depth = 129
    bg_dict_plus = read_bg(bg_plus,depth)
    bg_dict_minus = read_bg(bg_minus,depth)
    data,pasid  = dataProcessing(input_file,window,bg_dict_plus,bg_dict_minus,threshold)
    Evaluate(data,pasid,out,window,model,pseudo_count,data_mean,data_std)

