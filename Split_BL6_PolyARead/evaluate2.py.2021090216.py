from PolyAModel import *
import re
import os, sys, copy, getopt, re, argparse
import random
import pandas as pd 
import numpy as np
from Bio.Seq import Seq
import sys
sys.path.append('/home/longy/project/python_lib')
sys.path.append('/home/longy/project/Split_BL6')
from TrimmedMean import TrimmedMean
from extract_coverage_from_scanGenome import check


def collpase(pas_id,array,rst=0):
    
    sequence = ''
    coverage = []
    contain_N = False
    for line in array:
        line = line.rstrip('\n')
        _,rpm,base = line.split('\t')
        base = base.upper()
        if(base=='N'):
            contain_N = True
            break
        sequence += base
        coverage.append(rpm)
    
    if(not contain_N):
        chromosome,pos,strand = pas_id.split(':')
        if(strand == "-"):
            sequence = Seq(sequence)
            sequence = sequence.reverse_complement()
            coverage.reverse()
        trimMean = TrimmedMean([float(coverage[i]) for i in range(int(len(coverage)/2))])
        if(trimMean>=rst):
            return sequence,coverage
        else:
            return 0,0
    else:
        print("Discard pas containig N")
        return 0,0
    


def dataProcessing(scan_file,window,rst):
    
    extend  = int(window/2)
    data1 = []
    data2 = []
    PASID = []
    alphabet = np.array(['A', 'T', 'C', 'G'])
    
    f = open(scan_file,'r')
    lines = f.readlines()
    
    #n_pos = 0 #position containing N
    for i,line in enumerate(lines):
        line = line.rstrip('\n')
        pas_id,_,base = line.split('\t')
        
        if(base=='N'):
            continue
        start = i-extend
        end   = i+extend
        if(start>0 and end+1<len(lines)):
            if(not check(lines[start],lines[end],window)):
                continue
            sequence,coverage = collpase(pas_id,lines[start:end+1],rst)
            if(sequence!=0):
                chromosome,pos,strand = pas_id.split(':')
                sequence = list(sequence)
                seq = np.array(sequence, dtype = '|U1').reshape(-1,1)
                seq_data = (seq == alphabet).astype(np.float32)
                data1.append(seq_data)
                coverage = np.array(coverage).astype(np.float32)
                data2.append(coverage)
                PASID.append(pas_id)
    data1 = np.stack(data1).reshape([-1, window, 4])
    data2 = np.stack(data2).reshape([-1, window, 1])
    PASID = np.array(PASID)
    
    f.close()
    return data1 , data2,  PASID 
            
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="identification of pAs cleavage site")
    parser.add_argument("--model", help="the model weights file", required=True)
    parser.add_argument("--data", help="input  sequence and coverage", required=True)
    parser.add_argument("--out", help="prediction files", required=True)
    parser.add_argument("--RNASeqRCThreshold",type=float,help="RNA-Seq Coverage Threshold", required=True)
    parser.add_argument('--combination', default='SC',type=str, help='Seperate the data into how many folds')
    parser.add_argument('--window', default=201, type=int, help='input length')
    args = parser.parse_args()

    Path = args.model
    data = args.data
    out  = args.out
    combination = args.combination
    rst = args.RNASeqRCThreshold
    window=args.window

    print("Start Evaluating %s"%data)
    seq_data,cov_data,pas_id = dataProcessing(data,window,rst)

    keras_Model = PolyA_CNN(combination,window,6,12)
    keras_Model.load_weights(Path)
    pred = keras_Model.predict({"seq_input": seq_data, "cov_input": cov_data})

    OUT=open(out,'w')
    for i in range(len(pas_id)):
        OUT.write('%s\t%s\n'%(str(pas_id[i]),str(pred[i][0])))
    OUT.close()
    print("End Evaluation")
