#!/usr/bin/env python
# coding: utf-8

import os
import glob
from collections import OrderedDict,defaultdict
import pipes
import pprint
import tempfile
import re
import argparse



def binary_locate(array,ele,start,end):
    middle = (end+start)//2
    if(end-start>1):
        if(array[middle]<ele):
            return binary_locate(array,ele,middle,end)
        elif(array[middle+1]>ele):
            return binary_locate(array,ele,start,middle)
        else:
            return middle,middle+1
    else:
        return middle,middle+1
    
def write_file(info,dict_line,chromosome,strand,save_block,start,pre_pos,count,reference,window):
    ww = open(root_dir+'/%s_%s_%d'%(chromosome,strand,save_block),'w')
    print('writing file '+root_dir+'/%s_%s_%d_%d-%d'%(chromosome,strand,save_block,start,pre_pos))
    info.write('%s_%s_%d\t%d\t%d\t%d\t%d\n'%(chromosome,strand,save_block,start,pre_pos,pre_pos-start,count))
    pre_pos = 0
    pos_array = list(dict_line.keys())
    #for pos,val in dict_line.items():
    for i,pos in enumerate(pos_array):
        val = dict_line[pos]
    
        if(pos-pre_pos>=window):
            pre_pos = pos-window+1
        while(pos-pre_pos>=1):
            if pre_pos not in dict_line.keys():
                ww.write('%s:%d:%s\t%d\t%s\n'%(chromosome,pre_pos,strand,0,reference[pre_pos-1]))
            pre_pos += 1
            
        ww.write('%s:%d:%s\t%s\n'%(chromosome,pos,strand,val))
        pre_pos = pos
        
        if(i < len(pos_array)-1):
            post_pos = pos_array[i+1]
            if(post_pos-pos>=window):
                post_pos = pos+window-1
        else:
            post_pos = pos+window-1
        while(post_pos - pre_pos>=1):
            if pre_pos not in dict_line.keys():
                ww.write('%s:%d:%s\t%d\t%s\n'%(chromosome,pre_pos,strand,0,reference[pre_pos-1]))
            pre_pos += 1
            
    dict_line.clear()
    ww.close()
    

def split(root_dir,Fixed_length,input_file,ens_file,reference):
    strand,chromosome = input_file.split('.')[-4:-1:2]
    if(strand=="str2"):
        strand="+"
    elif(strand=="str1"):
        strand="-"
    else:
        print("warnings: please check the input file name "+input_file+" is correct")
        
        
    Gene_Loc = get_gene_location(ens_file)
    gene_position_array = Gene_Loc[chromosome+strand]
    print("Finished getting gene location from "+ens_file)
    
    
    wig_file = open(input_file, "r")
    lines = wig_file.readlines()
    wig_file.close()
     
    num_lines = len(lines)
    num_blocks = round(num_lines/Fixed_length)
    len_blocks = num_lines/num_blocks
    
    pre_pos = 0
    dict_line = OrderedDict()
    count = 0
    separate_num=0
    save_block = 0
    start = 0
    info = open(root_dir+'/info.txt','a')
    
    for i, line in enumerate(lines):
        line = line.rstrip('\n')
        if(i==0):
            continue ###Skip header
        pos,rpm = line.split('\t')
        pos = int(pos)
        base = reference[pos-1]
        #rpm = float(rpm)
        count += 1
        if(i==1):
            start=pos
        if(count>len_blocks and pos-pre_pos>1000 and save_block<num_blocks-1):
            index1,index2 = binary_locate(gene_position_array,pre_pos,0,len(gene_position_array)-1)
            if(index1%2==1 and index2%2==0):
                write_file(info,dict_line,chromosome,strand,save_block,start,pre_pos,count,reference)
                count = 0
                save_block += 1
                start  = pos
            
        
        dict_line[pos] = "%s\t%s"%(rpm,base)
        pre_pos = pos
        
    write_file(info,dict_line,chromosome,strand,save_block,start,pre_pos,count,reference)

    info.close()
    
    
def get_gene_location(ens_file):
    p = pipes.Template()
    p.append("zcat", '--')
    Gene_Loc = defaultdict(list)

    f = p.open(ens_file, 'r')
    for line in f.readlines():
        if re.match('^#',line):
            continue
        line = line.rstrip('\n')
        data = line.split('\t')
        if(data[2] == 'gene'):
            Gene_Loc['chr'+data[0]+data[6]].append(int(data[3]))
            Gene_Loc['chr'+data[0]+data[6]].append(int(data[4]))
    return Gene_Loc

def get_genome_sequence(fa_file):
    f = open(fa_file,"r")
    line = f.readline()
    line = line.rstrip('\n')
    return line

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--root_dir', default=None, help='root dir')
    parser.add_argument('--ens_file', default=None, help='ensembl file')
    parser.add_argument('--input_file', default=None, help='ensembl file')
    parser.add_argument('--fa_file',default=None,help='path to one line fa file')
  
    argv = parser.parse_args()

    root_dir = argv.root_dir
    Fixed_length = 2e6
    ens_file = argv.ens_file
    input_file = argv.input_file
    fa_file = argv.fa_file
    window = 201
    
    
    reference = get_genome_sequence(fa_file)
    print("Finished getting reference sequence from "+fa_file)
    
    
    split(root_dir,Fixed_length,input_file,ens_file,reference)
