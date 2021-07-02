#!/usr/bin/env python
# coding: utf-8

import argparse
from Bio.Seq import Seq
import re
import sys
sys.path.append('/home/longy/project/Split_BL6')
sys.path.append('/home/longy/project/python_lib')
from TrimmedMean import TrimmedMean
from extract_coverage_from_scanGenome import get_motif,check

def read_pas(pas_file,rst,pst,ust):
    f = open(pas_file, 'r')
    pas_dict = dict()
    f.readline() ##skip header
    for line in f.readlines():
        line = line.rstrip('\n')
        pas_id,pas_type,chromosome,pos,strand,symbol,usage,polyAseq,_,_,rnaSeq = line.split('\t')[0:11]
        if(float(usage)>=ust and float(polyAseq)>=pst and float(rnaSeq)>=rst):
            pas_dict[pas_id] = [pas_type,symbol]
    f.close()
    return pas_dict

def collpase(pas_id,pas_type,symbol,array,ww,species,shift,rst=0):
    
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
        if(shift!=0):
            augmentation = 'shift:'+str(shift)
        else:
            augmentation = 'Origin'
        
        new_pos = str(int(pos)+shift)
        new_pas_id = chromosome+':'+str(new_pos)+':'+strand
        if(strand == "-"):
            sequence = Seq(sequence)
            sequence = sequence.reverse_complement()
            coverage.reverse()
        trimMean = TrimmedMean([float(coverage[i]) for i in range(int(len(coverage)/2))])
        if(trimMean>=rst):
            motif = get_motif(sequence,species)
            column2 = motif+'_'+pas_type+'_'+symbol
        
            ww.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n"
                 %(new_pas_id,column2,chromosome,new_pos,
                   strand,augmentation,pas_id,sequence,'\t'.join(coverage)))
            return 1
        else:
            return 0
        
    else:
        print("Discard pas containig N")
        return 0


def output(pas_dict,scan_file,out,window,max_shift,species):
    
    extend  = int(window/2)
    
    f = open(scan_file,'r')
    lines = f.readlines()
    
    
    ww = open(out,'w')


    for i,line in enumerate(lines):
        line = line.rstrip('\n')
        pas_id,rpm,base = line.split('\t')
        if pas_id in pas_dict.keys():
            pas_type,symbol = pas_dict[pas_id]
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
    parser.add_argument('--pas_file', default=None, help='pas usage file')
    parser.add_argument('--output', default=None, help='output file path')
    parser.add_argument('--window', default=201,type=int, help='window size')
    parser.add_argument('--species', default='hg38', help='pas file')
    parser.add_argument("--RNASeqRCThreshold",type=float,help="RNA-Seq Coverage Threshold", required=True)
    parser.add_argument("--polyASeqRCThreshold",type=float,help="PolyA-Seq Read Count Threshold", required=True)
    parser.add_argument("--usageThreshold",type=float,help="usage Threshold", required=True)
    parser.add_argument("--max_shift",default=0,type=int,help="shift augmentation")

    argv = parser.parse_args()

    scan_file = argv.scan_file
    pas_file = argv.pas_file
    window   = argv.window
    species = argv.species
    rst = argv.RNASeqRCThreshold
    pst = argv.polyASeqRCThreshold
    ust = argv.usageThreshold
    max_shift = argv.max_shift
    out =argv.output
    
    pas_dict = read_pas(pas_file,rst,pst,ust)
    print("%s %d %s"%("processing",len(pas_dict),"pas"))
    output(pas_dict,scan_file,out,window,max_shift,species)
