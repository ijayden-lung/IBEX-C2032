#!/usr/bin/env python
# coding: utf-8

import argparse
from Bio.Seq import Seq
import re
import random
import sys
sys.path.append('/home/longy/project/Split_BL6')


def read_predict(pas_file,CHR,SRD,thre,usage_thre):
    f = open(pas_file, 'r')
    pas_dict= dict()
    #f.readline() #skip header
    for line in f.readlines():
        line = line.rstrip('\n')
        pas_id,pas_type,chromosome,pos,strand,symbol,usage,polyARead,_,_,RNASeqRPM = line.split('\t')[0:11]
        if(chromosome == CHR and strand == SRD and float(RNASeqRPM)>=0.05 and float(polyARead)>=thre and float(usage)>=usage_thre):
            pos = int(pos)
            pas_dict[pos] = (pas_id,pas_type,chromosome,pos,strand,symbol,usage,polyARead)
    f.close()
    return pas_dict

def get_rpm(scan_file):
    f = open(scan_file,'r')
    f.readline() #skip header
    rpm_dict = dict()
    for i,line in enumerate(f.readlines()):
        line = line.rstrip('\n')
        pos,rpm = line.split('\t')
        pos = int(pos)
        rpm_dict[pos] = rpm
    f.close()
    return rpm_dict

def output(pas_dict,rpm_dict,out,window,chromosome,strand):
    ww = open(out,'w')
    extend  = int(window/2)
    for pos,val in pas_dict.items():
        pas_id = chromosome+':'+str(pos)+':'+strand
        ww.write("%s\t%s\t%s\t%d\t%s\t%s\t%s\tNone\t%s"%(val[0],val[1],val[2],val[3],val[4],val[5],val[6],val[7]))
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
    parser.add_argument('--chromosome', default=None, help='standard input pos')
    parser.add_argument('--strand', default=None, help='standard input pos')
    parser.add_argument('--scan_file', default=None, help='scan transcriptom file')
    parser.add_argument('--pre_file', default=None, help='predicted pas file')
    parser.add_argument('--output', default=None, help='output file path')
    parser.add_argument('--window', default=1601,type=int, help='window size')
    parser.add_argument('--thre', default=0,type=float, help='window size')
    parser.add_argument('--usage_thre', default=0,type=float, help='window size')

    argv = parser.parse_args()

    scan_file = argv.scan_file
    pre_file = argv.pre_file
    window   = argv.window
    out =argv.output
    chromosome = argv.chromosome
    strand = argv.strand
    thre = argv.thre
    usage_thre = argv.usage_thre
    
                           
    pas_dict = dict()
    pas_dict = read_predict(pre_file,chromosome,strand,thre,usage_thre)
    rpm_dict = get_rpm(scan_file)
    output(pas_dict,rpm_dict,out,window,chromosome,strand)


