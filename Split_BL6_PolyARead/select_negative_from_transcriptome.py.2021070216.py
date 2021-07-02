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


def output(pas_array,scan_file,out,window,max_shift,species,prob,number_pas,rst):
    
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
    count = 0
    items = list(negative_candidate.items())
    random.shuffle(items)
    for pas_id,i in items:
        start = i-extend
        end   = i+extend
        if(not check(lines[start-max_shift],lines[end+max_shift],window+2*max_shift)):
            continue
        success = collpase(pas_id,'unknown','unknown',lines[start:end+1],ww,species,0,rst)
        count += success
        if(success==0):
            continue
        for j in range(-max_shift,max_shift+1):
            if(j==0):
                continue
            k = i+j
            start = k-extend
            end   = k+extend
            if(start>0 and end+1<len(lines)):
                if(check(lines[start],lines[end],window)):
                    collpase(pas_id,'unknown','unknown',lines[start:end+1],ww,species,j,rst)
        if(count>=number_pas):
            break
    if(count<number_pas):
        raise Warning("not engough negative candidates, please incerase the probability for selecting!")
    else:
        print("successfully randomly get same number of negative pas as ground truth")
    f.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--scan_file', default=None, help='scan transcriptom file')
    parser.add_argument('--pas_file', default=None, help='pas usage file')
    parser.add_argument('--output', default=None, help='output file path')
    parser.add_argument('--window', default=201,type=int, help='window size')
    parser.add_argument('--species', default='hg38', help='pas file')
    parser.add_argument("--RNASeqRCThreshold",type=float,help="RNA-Seq Coverage Threshold", required=True)
    parser.add_argument("--max_shift",default=0,type=int,help="shift augmentation")
    parser.add_argument("--prob",default=0,type=float,help="probability of senecting neagtive")

    argv = parser.parse_args()

    scan_file = argv.scan_file
    pas_file = argv.pas_file
    window   = argv.window
    species = argv.species
    rst = argv.RNASeqRCThreshold
    max_shift = argv.max_shift
    out =argv.output
    prob = argv.prob
    
    Threshold = 49
    
    pas_array = read_pas(pas_file)
    number_pas = len(pas_array)
    print("%s %d %s"%("processing",number_pas,"pas"))
    
    output(pas_array,scan_file,out,window,max_shift,species,prob,number_pas,rst)
