#!/usr/bin/env python3
from get_files import get_files
import argparse
import re
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('--root_dir', help='Directory of scanTranscriptome files')
parser.add_argument('--round',help='Round of training')
parser.add_argument('--maxPoint', default=12, type=int, help='Threshold of maxPoint')
parser.add_argument('--penality', default=1, type=int, help='penelity score of predicted negative ')
parser.add_argument('--trainid', default=None, help='Training id')
parser.add_argument('--sets',choices=('train','valid','test','all'),help='Determine which sets from trian,valid and test')
opts = parser.parse_args()


ROOT_DIR  = opts.root_dir
ROUNDNAME  = opts.round
Round = int(ROUNDNAME[-1])
maxPoint = opts.maxPoint
penality = opts.penality
trainid  = opts.trainid
SET = opts.sets

print('Report of '+SET+'set')

train_sets,valid_sets,test_sets = get_files(ROOT_DIR,Round)
if(SET  == 'train'):
	sets = train_sets

elif(SET == 'valid'):
	sets = valid_sets

elif(SET == 'test'):
	sets = test_sets
else:
	sets = np.concatenate((train_sets,valid_sets,test_sets))


realNum   = 0
ground_truth=0
#ground_truth=20119
predict=0



for filepath in sets:
	baseName = filepath.split('/')[-1]
	statpath = 'Stat/'+trainid+'.'+baseName+'.peak'+str(maxPoint)+'.txt'
	#statpath = 'map/'+trainid+'.'+baseName+'.peak'+str(maxPoint)+'.txt'


	f= open(statpath,'r')
	#f.readline() #skip header
	for i, line in enumerate(f):
		line = line.rstrip('\n')
		_,real,tp25,tp50,tp100,total,pre = line.split('\t')
		#pas_id,gt_pasid,_,start,end,_,_,_,_ = line.split('\t')
		#start = float(start)
		#end   = float(end)
		#pos = (start+end)/2
		#_,pos,_ = pas_id.split(':')
		#pos = float(pos)
		#_,gt_pos,_ = gt_pasid.split(':')
		#gt_pos = float(gt_pos)
		#if(abs(pos-gt_pos)<=25):
		#	realNum += 1
		#predict += 1
		realNum += int(real)
		#RealNum25+= int(tp25)
		#RealNum50+= int(tp50)
		#RealNum100+= int(tp100)
		ground_truth += int(total)
		predict += int(pre)

	f.close()


recall = realNum/ground_truth
precision = realNum/predict

print("%d\t%d\t%d\t%.3f\t%.3f"%(ground_truth,predict,realNum,recall,precision))
