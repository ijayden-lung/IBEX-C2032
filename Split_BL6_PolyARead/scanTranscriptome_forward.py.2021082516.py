#!/usr/bin/env python -w
#
#
#Update 2021/04/28 Check peak

import argparse


def maxSum(file,threshold,penality,out):

    OUT=open(out,'w')
    OUT.write('pas_id\tmaxPoint\tmaxPos\tstart\tend\n')
    predict = dict()
    coor2pas = dict()
    with open(file,'r') as f:
        for line in f:
            pas_id,score =line.rstrip('\n').split('\t')
            score = float(score)
            chromosome,coor,strand = pas_id.split(':')
            coor = int(coor)
            predict[coor] = score
            coor2pas[coor] = pas_id
    
    predict[100000000000] = 1
    coor2pas[100000000000] = 'chr'
    coor_list = list(coor2pas.keys())
    coor_list.sort()
    sum=0
    maxPos=0   ## position of peak
    maxPoint=0 ## score of peak
    start=0       ## peak start
    end = 0    ## peak end
    peak = 0 ## peak coor
    peak_score = 0  ##peak score
    for coor in coor_list:
        score = predict[coor]
        if(coor-end>1):
            if(maxPoint>threshold and sum>0):
                #newpas_id = chromosome+":"+str(maxPos)+":"+strand
                newpas_id = coor2pas[maxPos]
                #start += 1
                #OUT.write('%s\t%d\t%d\t%d\t%.3f\t%.3f\n'%(newpas_id,start,end,length,maxPoint,area))
                OUT.write('%s\t%.3f\t%d\t%d\t%d\t%d\n'%(newpas_id,maxPoint,maxPos,start,end,peak))

            start = coor
            end   = coor
            if(score>0.5):
                maxPos = coor
                maxPoint = score
                peak_score = score
                sum = score
            else:
                maxPos = coor
                maxPoint = 0
                peak_score = 0
                sum  = 0

        elif(score < 0.5):
            sum -= penality
            if(sum <= 0):
                if(maxPoint > threshold):
                    #newpas_id = chromosome+":"+str(maxPos)+":"+strand
                    #OUT.write('%s\t%d\t%d\t%d\t%.3f\t%.3f\n'%(newpas_id,start,end,length,maxPoint,area))
                    newpas_id = coor2pas[maxPos]
                    OUT.write('%s\t%.3f\t%d\t%d\t%d\t%d\n'%(newpas_id,maxPoint,maxPos,start,end,peak))
                start = coor
                sum=0
                maxPoint = 0
                peak_score = 0
            end = coor
        else:
            sum += score
            if(peak_score < score):
                peak_score = score
                peak = coor
            if(maxPoint < sum):
                maxPoint = sum
                maxPos   = coor
            if(sum<1):
                start = coor
                maxPoint = sum
                maxPos   = coor
            end=coor

    OUT.close()

if __name__ == "__main__":
    ### Argument Parser
    parser = argparse.ArgumentParser()
    parser.add_argument('--testid', help='test id ')
    parser.add_argument('--baseName', help='baseName')
    parser.add_argument('--threshold', type=int,help='peak length lower than threshold will be fiter out')
    parser.add_argument('--penality', type=int,help='peak length lower than threshold will be fiter out')
    args = parser.parse_args()

    testid = args.testid
    baseName = args.baseName
    threshold = args.threshold
    penality = args.penality

    predict='predict/'+testid+'.'+baseName+'.txt'
    print(predict)
    print(threshold,baseName)
    #out='scan/'+testid+'.'+baseName+'.peak'+str(threshold)+'.txt'
    out="maxSum/%s.%s.forward.%d.%d.txt"%(testid,baseName,threshold,penality)
    #predict="predict/K562_Merge.pAs.single_kermax6.K562_Merge_aug8_SC_p4r9u0.05_4-0101.chr10_+_0.txt"
    #threshold=12
    #out = 'K562_Merge.pAs.single_kermax6.K562_Merge_aug8_SC_p4r9u0.05_4-0101.chr10_+_0.txt.peak'+str(threshold)+'.txt'
    maxSum(predict,threshold,penality,out)
