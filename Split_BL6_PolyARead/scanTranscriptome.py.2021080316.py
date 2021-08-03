#!/usr/bin/env python -w
#
#
#Update 2021/04/28 Check peak

import argparse


def maxSum(predict,threshold,penality,out):
	maxPos=0   ## position of peak
	maxPoint=0 ## score of peak
	start=0	   ## peak start
	end = 0    ## peak end
	length = 0 ## peak length
	area = 0  ##peak area
	OUT=open(out,'w')
	OUT.write('pas_id\tstart\tend\tlength\tmax_score\tarea\n')
	skip = 0
	with open(predict,'r') as f:
		for line in f:
			pas_id,score =line.rstrip('\n').split('\t')
			score = float(score)
			chromosome,coor,strand = pas_id.split(':')
			coor = int(coor)
			if(coor-end>1):
				skip=0
				if(length>threshold):
					newpas_id = chromosome+":"+str(maxPos)+":"+strand
					start += 1
					OUT.write('%s\t%d\t%d\t%d\t%.3f\t%.3f\n'%(newpas_id,start,end,length,maxPoint,area))
				
				if(score>0.5):
					start = coor-1
					end   = coor
					length = 1
					maxPos = coor
					maxPoint = score
					area = score
				else:
					maxPoint = 0
					start = coor
					length=0
					area = 0

			elif(score <= 0.5):
				skip += 1 ##add skip
				if(skip <= penality): #just skip one pos <0.5
					continue
				if(length>threshold):
					newpas_id = chromosome+":"+str(maxPos)+":"+strand
					start += 1
					OUT.write('%s\t%d\t%d\t%d\t%.3f\t%.3f\n'%(newpas_id,start,end,length,maxPoint,area))
				skip=0
				start = coor
				length = 0
				area = 0
			else:
				skip=0
				end=coor
				length = end-start
				area += score
				if(maxPoint < score):
					maxPos   = coor
					maxPoint = score
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
	out="scan/%s.%s.peak.%d.%d.txt"%(testid,baseName,threshold,penality)
	#predict="predict/K562_Merge.pAs.single_kermax6.K562_Merge_aug8_SC_p4r9u0.05_4-0101.chr10_+_0.txt"
	#threshold=12
	#out = 'K562_Merge.pAs.single_kermax6.K562_Merge_aug8_SC_p4r9u0.05_4-0101.chr10_+_0.txt.peak'+str(threshold)+'.txt'
	maxSum(predict,threshold,penality,out)
