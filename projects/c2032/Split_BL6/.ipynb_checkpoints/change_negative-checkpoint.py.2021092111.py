#!/usr/bin/env python
# coding: utf-8

import argparse
from Bio.Seq import Seq
import re
import random
import sys
sys.path.append('/home/longy/project/Split_BL6')
from extract_coverage_from_scanGenome import get_motif,check
from select_positive_from_transcriptome import collpase

def read_pas(pas_file):
    f = open(pas_file, 'r')
    pas_array = []
    for line in f.readlines():
        line = line.rstrip('\n')
        pas_id,column2,_,pos,_,augmentation = line.split('\t')[0:6]
        if(augmentation == 'Origin'):
            pos = int(pos)
            pas_array.append(pos)
    f.close()
    return pas_array

def read_predict(pas_file):
    f = open(pas_file, 'r')
    pas_array = []
    for line in f.readlines():
        line = line.rstrip('\n')
        pos,_,_,_,_,_,gt_diff= line.split('\t')[0:7]
        if(abs(gt_diff) >true_threshold):
            pos = float(pos)
            pos = round(pos)
            pas_array.append(pos)
    f.close()
    return pas_array

def get_negative_candidate(pas_array,scan_file,out,window,max_shift,species,prob,number_pas,rst):
    
    extend  = int(window/2)
    
    f = open(scan_file,'r')
    lines = f.readlines()
    
    
    ww = open(out,'w')

    pre_pos = 0
    negative_candidate = dict()
    for i,line in enumerate(lines):
        line = line.rstrip('\n')
        pas_id,rpm,base = line.split('\t')
        chromosome,pos,strand = pas_id.split(':')
        pos = int(pos)
        if(i-extend>0 and i+extend+1<len(lines)):
            if(random.random()<prob):
                accept = 1
                if (abs(pos-pre_pos)<Threshold):
                    continue
                for true_pos in pas_array:
                    if(abs(pos-true_pos)<Threshold):
                        accept = 0
                if(accept==0):
                    continue 
                        
                pre_pos = pos
                negative_candidate[pas_id] = i


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--scan_file', default=None, help='scan transcriptom file')
    parser.add_argument('--pos_file', default=None, help='positive pas file')
    parser.add_argument('--neg_file', default=None, help='negative pas file')
    parser.add_argument('--pre_file', default=None, help='predicted pas file')
    parser.add_argument('--output', default=None, help='output file path')
    parser.add_argument('--window', default=201,type=int, help='window size')
    parser.add_argument('--species', default='hg38', help='pas file')
    parser.add_argument("--RNASeqRCThreshold",type=float,help="RNA-Seq Coverage Threshold", required=True)
    parser.add_argument("--max_shift",default=0,type=int,help="shift augmentation")
    parser.add_argument("--prob",default=0.001,type=float,help="probability of senecting neagtive")

    argv = parser.parse_args()

    scan_file = argv.scan_file
    pos_file = argv.pos_file
    neg_file = argv.neg_file
    pre_file = argv.pre_file
    window   = argv.window
    species = argv.species
    rst = argv.RNASeqRCThreshold
    max_shift = argv.max_shift
    out =argv.output
    prob = argv.prob
    
    Threshold = 49
    true_threshold = 25
    
    pos_array = read_pas(pos_file)
    neg_array = read_pas(neg_file)
    fp_array = read_pas(pre_file)
    
    
    
    num_neg = len(neg_array)
    num_fp  = leng(fp_array)
    
    neg_array = random.shuffle(neg_array)
    fp_array  = random.shuffle(neg_array)
    
    
    if(num_fp < num_neg/2):
        print()
    
    output(pas_array,scan_file,out,window,max_shift,species,prob,number_pas,rst)


