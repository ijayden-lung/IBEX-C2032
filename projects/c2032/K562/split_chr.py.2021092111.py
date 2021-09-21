#!/usr/bin/env python
# coding: utf-8

import os
import glob
from collections import OrderedDict

root_dir = 'scanGenome_data'

####Fixed length 5e5 = 200 blocks. 



total = 0
files = glob.glob(root_dir+"/*.txt")
info = open('scanGenome_data/Blocks/info.txt','w')
info.write('ID\tstart\tend\tlength\tsites_num\n')
for file in files:
    num_lines = sum(1 for line in open(file))
    num_blocks = round(num_lines/5e5)
    len_blocks = num_lines/num_blocks
    
    f= open(file,'r')
    pre_pos = 0
    dict_line = OrderedDict()
    #dict_line = dict()
    count = 0
    separate_num=0
    save_block = 0
    start = 0
    
    for i, line in enumerate(f):
        line = line.rstrip('\n')
        if(i==0):
            continue ###Skip header
        chromosome,pos,strand = line.split('\t')[0].split(':')
        pos = int(pos)
        count += 1
        if(i==1):
            start=pos
        if(count>len_blocks and pos-pre_pos>1000 and save_block<num_blocks-1):
            
            ww = open('scanGenome_data/Blocks/%s_%s_%d'%(chromosome,strand,save_block),'w')
            print('writing file scanGenome_data/Blocks/%s_%s_%d_%d-%d'%(chromosome,strand,save_block,start,pre_pos))
            info.write('%s_%s_%d\t%d\t%d\t%d\t%d\n'%(chromosome,strand,save_block,start,pre_pos,pre_pos-start,count))
            #print('%s_%s_%d\t%d\t%d\t%d\t%d\n'%(chromosome,strand,save_block,start,pre_pos,pre_pos-start,count))
            for key,val in dict_line.items():
                ww.write('%s\n'%val)
            dict_line.clear()
            count = 0
            save_block += 1
            start  = pos
            
        
        dict_line[pos] = line
        pre_pos = pos
        
    out = open('scanGenome_data/Blocks/%s_%s_%d'%(chromosome,strand,save_block),'w')
    print('writing file scanGenome_data/Blocks/%s_%s_%d_%d-%d'%(chromosome,strand,save_block,start,pre_pos))
    info.write('%s_%s_%d\t%d\t%d\t%d\t%d\n'%(chromosome,strand,save_block,start,pre_pos,pre_pos-start,count))
    for key,val in dict_line.items():
        out.write('%s\n'%(val))
    
