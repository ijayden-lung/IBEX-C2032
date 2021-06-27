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
    

def split(root_dir,Fixed_length,input_file,gene_position_array):
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
    #info = open(root_dir+'/Blocks/info.txt','a')
    
    for i, line in enumerate(lines):
        line = line.rstrip('\n')
        if(i==0):
            continue ###Skip header
        pos,rpm = line.split('\t')
        pos = int(pos)
        rpm = float(rpm)
        break
        """
        count += 1
        if(i==1):
            start=pos
        if(count>len_blocks and pos-pre_pos>1000 and save_block<num_blocks-1):
            index1,index2 = binary_locate(gene_position_array,pre_pos,0,len(gene_position_array)-1)
            if(index1%2==1 and index2%2==0):
                ww = open(root_dir+'/Blocks/%s_%s_%d'%(chromosome,strand,save_block),'w')
                print('writing file '+root_dir+'/Blocks/%s_%s_%d_%d-%d'%(chromosome,strand,save_block,start,pre_pos))
                info.write('%s_%s_%d\t%d\t%d\t%d\t%d\n'%(chromosome,strand,save_block,start,pre_pos,pre_pos-start,count))
                #print('%s_%s_%d\t%d\t%d\t%d\t%d\n'%(chromosome,strand,save_block,start,pre_pos,pre_pos-start,count))
                for key,val in dict_line.items():
                    ww.write('%s\n'%val)
                ww.close()
                dict_line.clear()
                count = 0
                save_block += 1
                start  = pos
            
        
        dict_line[pos] = line
        pre_pos = pos
        
    out = open(root_dir+'/Blocks/%s_%s_%d'%(chromosome,strand,save_block),'w')
    print('writing file '+root_dir+'/Blocks/%s_%s_%d_%d-%d'%(chromosome,strand,save_block,start,pre_pos))
    info.write('%s_%s_%d\t%d\t%d\t%d\t%d\n'%(chromosome,strand,save_block,start,pre_pos,pre_pos-start,count))
    for key,val in dict_line.items():
        out.write('%s\n'%(val))
    out.close()

    info.close()
    """
    
    
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
    Fixed_length = 1.5e6
    ens_file = argv.ens_file
    input_file = argv.input_file
    fa_file = argv.fa_file
    
    strand,chromosome = input_file.split('.')[-4:-1:2]
    if(strand=="str2"):
        strand="+"
    elif(strand=="str1"):
        strand="-"
    else:
        print("warnings: please check the input file name "+input_file+" is correct")
    
    reference = get_genome_sequence(fa_file)
    print("Finished getting reference sequence from "+fa_file)
    
    Gene_Loc = get_gene_location(ens_file)
    gene_position_array = Gene_Loc[chromosome+strand]
    print("Finished getting gene location from "+ens_file)
    
    split(root_dir,Fixed_length,input_file,gene_position_array)
