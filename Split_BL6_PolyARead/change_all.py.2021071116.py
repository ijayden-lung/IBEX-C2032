#!/usr/bin/env python
# coding: utf-8

import argparse
from Bio.Seq import Seq
import re
import random
import sys
sys.path.append('/home/longy/project/Split_BL6')



def read_predict(pas_file):
    f = open(pas_file, 'r')
    pas_dict= dict()
    f.readline() #skip header
    for line in f.readlines():
        line = line.rstrip('\n')
        pos,_,_,_,_,_,gt_diff= line.split('\t')[0:7]
        gt_diff = float(gt_diff)
        pos = float(pos)
        pos = round(pos)
        if(abs(gt_diff) >true_threshold): 
            pas_dict[pos] = 'False'
        else:
            pas_dict[pos] = 'True'
            
    f.close()
    return pas_dict

                
                
def get_rmp():
    
    
    f = open(scan_file,'r')
    lines = f.readlines()
    rpm_dict = dict()

    for i,line in enumerate(lines):
        line = line.rstrip('\n')
        pas_id,rpm,_ = line.split('\t')
        chromosome,pos,strand = pas_id.split(':')
        pos = int(pos)
        rpm_dict[pos] = rpm
    f.close()
    
    return rpm_dict

    


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--scan_file', default=None, help='scan transcriptom file')
    parser.add_argument('--pre_file', default=None, help='predicted pas file')
    parser.add_argument('--output', default=None, help='output file path')
    parser.add_argument('--window', default=1001,type=int, help='window size')
    parser.add_argument('--species', default='hg38', help='pas file')
    parser.add_argument("--max_shift",default=0,type=int,help="shift augmentation")

    argv = parser.parse_args()

    scan_file = argv.scan_file
    pre_file = argv.pre_file
    window   = argv.window
    max_shift = argv.max_shift
    out =argv.output
    
    true_threshold = 25
    

    pas_dict = read_predict(pre_file)
    rpm_dict = get_rpm(scan_file)

    output(pas_dict,scan_file,out,window,max_shift,species)


