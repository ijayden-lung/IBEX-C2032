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

def read_usage(usage_file,pst,rst):
    f = open(usage_file, 'r')
    pas_array = []
    f.readline() #skip header
    for line in f.readlines():
        line = line.rstrip('\n')
        pas_id,column2,_,pos,_,_,_,polyA_readcount,_,_,RNA_readcount = line.split('\t')[0:11]
        if(float(polyA_readcount)>=pst and float(RNA_readcount)>=rst):
            pos = int(pos)
            pas_array.append(pos)
    f.close()
    return pas_array

def read_predict(pas_file):
    f = open(pas_file, 'r')
    pas_array = []
    f.readline() #skip header
    for line in f.readlines():
        line = line.rstrip('\n')
        pos,_,_,_,_,_,gt_diff= line.split('\t')[0:7]
        gt_diff = float(gt_diff)
		#pas_id,gt_pasid,_,start,end,_,_,_,_ = line.split('\t')
		#pos = (float(start)+float(end))/2
		#_,gt_pos,_ = gt_pasid.split(':')
		#gt_pos = float(gt_pos)
		#gt_diff = gt_pos-pos
        #print(gt_diff,true_threshold)
        if(abs(gt_diff) >true_threshold):
            pos = float(pos)
            pos = round(pos)
            pas_array.append(pos)
    f.close()
    return pas_array

def delete_fp_array(fp_array,usage_array):
    for pos1 in usage_array:
        for pos2 in fp_array:
            if(abs(int(pos1)-int(pos2))<=true_threshold):
                fp_array.remove(pos2)
                print('remove pos'+str(pos1)+'\t'+str(pos2))
    return fp_array

def get_negative_candidate(pas_array,scan_file,out,window,prob,rst):
    
    extend  = int(window/2)
    
    f = open(scan_file,'r')
    lines = f.readlines()
    
    ww = open(out,'w')
    pre_pos = 0
    negative_candidate = []
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
                negative_candidate.append(pos)
    return negative_candidate
                
                
def output(pas_dict,scan_file,out,window,max_shift,species):
    
    extend  = int(window/2)
    
    f = open(scan_file,'r')
    lines = f.readlines()
    
    ww = open(out,'w')

    for i,line in enumerate(lines):
        line = line.rstrip('\n')
        pas_id,rpm,base = line.split('\t')
        chromosome,pos,strand = pas_id.split(':')
        pos = int(pos)
        if pos in pas_dict.keys():
            pas_type = pas_dict[pos]
            symbol   = 'unknown'
            if(i-extend>0 and i+extend+1<len(lines)):
                for j in range(-max_shift,max_shift+1):
                    k = i+j
                    start = k-extend
                    end   = k+extend
                    if(start>0 and end+1<len(lines)):
                        if(check(lines[start],lines[end],window)):
                            collpase(pas_id,pas_type,symbol,lines[start:end+1],ww,species,j)
    f.close()



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
    parser.add_argument("--polyASeqRCThreshold",type=float,help="RNA-Seq Coverage Threshold")
    parser.add_argument("--max_shift",default=0,type=int,help="shift augmentation")
    parser.add_argument("--prob",default=0.001,type=float,help="probability of senecting neagtive")
    parser.add_argument("--usage_file",default=None,help="usage file")

    argv = parser.parse_args()

    scan_file = argv.scan_file
    pos_file = argv.pos_file
    neg_file = argv.neg_file
    pre_file = argv.pre_file
    window   = argv.window
    species = argv.species
    rst = argv.RNASeqRCThreshold
    pst = argv.polyASeqRCThreshold
    max_shift = argv.max_shift
    out =argv.output
    prob = argv.prob
    usage_file = argv.usage_file
    
    Threshold = 49
    true_threshold = 25
    keep_prob  = 0.5
    
    pos_array = read_pas(pos_file)
    neg_array = read_pas(neg_file)
    fp_array = read_predict(pre_file)
    
    num_neg = len(neg_array)
    num_fp  = len(fp_array)
    print("number of negative: %d\nnumber of false positive %d"%(num_neg,num_fp))
    
    if(usage_file != None):
        usage_array = read_usage(usage_file,pst,rst)
        fp_array = delete_fp_array(fp_array,usage_array)
    

    
    
    num_neg = len(neg_array)
    num_fp  = len(fp_array)
    
    random.shuffle(neg_array)
    random.shuffle(fp_array)
    
    
    print("number of negative: %d\nnumber of false positive %d"%(num_neg,num_fp))
    
    neg_keep_index = round(num_neg*keep_prob)

    
    pas_dict = {neg_array[i]:'keep' for i in range(neg_keep_index)}

    keep_number = neg_keep_index
    fp_number = 0
    random_number = 0
    for fp_pos in fp_array:
        if fp_pos not in pas_dict:
            pas_dict[fp_pos] = 'fp'
            neg_keep_index += 1
            fp_number += 1
        if (neg_keep_index>=num_neg):
            break

#    if(neg_keep_index<num_neg):
#        pas_array = pos_array+list(pas_dict.keys())
#        neg_candidate = get_negative_candidate(pas_array,scan_file,out,window,prob,rst)
#        random.shuffle(neg_candidate)
#        for pos in neg_candidate:
#            pas_dict[pos] = 'random'
#            neg_keep_index += 1
#            random_number += 1
#            if (neg_keep_index>=num_neg):
#                break
 
    for i in range(neg_keep_index,num_neg):
        pas_dict[neg_array[i]] = 'keep'
        keep_number += 1
    
    print("write number of origin negative: "+ str(keep_number))
    print("write number of false positive negative: "+ str(fp_number))
    print("write number of random negative: "+ str(random_number))
    output(pas_dict,scan_file,out,window,max_shift,species)


