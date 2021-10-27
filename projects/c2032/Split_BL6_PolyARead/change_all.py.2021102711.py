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
        pos,nearest_pasid,_,_,_,gt_pasid,gt_diff= line.split('\t')[0:7]
        gt_diff = float(gt_diff)
        pos = float(pos)
        pos = round(pos)
        #_,nearest_pasid,_,start,end= line.split('\t')[0:5]
        #pos = round((float(start)+float(end))/2)
        #_,gt_pos,_ = nearest_pasid.split(':')
        #gt_pos = float(gt_pos)
        #gt_diff = abs(gt_pos-pos)
        if(abs(gt_diff) >=true_threshold): 
            pas_dict[pos] = 'False_'+nearest_pasid
        else:
            pas_dict[pos] = 'True_'+gt_pasid
            #pas_dict[pos] = 'True_'+nearest_pasid
            
    f.close()
    return pas_dict

                
                
def get_rpm(scan_file):
    
    
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

def output(pas_dict,rpm_dict,out,window,chromosome,strand,max_shift):
    ww = open(out,'w')
    extend  = int(window/2)
    for pos,val in pas_dict.items():
        pas_id = chromosome+':'+str(pos)+':'+strand
        pas_type,true_id = val.split('_')
        ww.write("%s\t%s\t%s\t%d\t%s\t%s"%(pas_id,pas_type,chromosome,pos,strand,true_id))
        for i in range(-extend,extend+1):
            new_pos = pos+i
            if(strand=='-'):
                new_pos = pos-i
            if(new_pos in rpm_dict.keys()):
                ww.write("\t%s"%rpm_dict[new_pos])
            else:
                ww.write("\t0")
        ww.write("\n")
    ww.close()
        
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--std_inp', default=None, help='standard input pos')
    parser.add_argument('--scan_file', default=None, help='scan transcriptom file')
    parser.add_argument('--pre_file', default=None, help='predicted pas file')
    parser.add_argument('--output', default=None, help='output file path')
    parser.add_argument('--window', default=1601,type=int, help='window size')
    parser.add_argument("--max_shift",default=0,type=int,help="shift augmentation")

    argv = parser.parse_args()

    scan_file = argv.scan_file
    pre_file = argv.pre_file
    window   = argv.window
    max_shift = argv.max_shift
    out =argv.output
    std_inp = argv.std_inp
    
    true_threshold = 25
    
    block = scan_file.split('/')[-1]
    chromosome,strand,_ = block.split('_')
                           
    pas_dict = dict()
    if(std_inp == None):
        pas_dict = read_predict(pre_file)
    else:
        pos = int(std_inp)
        pas_dict[pos] = 'a_test'
        
    rpm_dict = get_rpm(scan_file)

    output(pas_dict,rpm_dict,out,window,chromosome,strand, max_shift)


