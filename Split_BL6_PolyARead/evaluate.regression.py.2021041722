from RegressionModel import *
import re
import os, sys, copy, getopt, re, argparse
import random
import pandas as pd 
import numpy as np
from prep_data_regression import prep_data,DataGenerator



def trimmedMean(UpCoverage):
	total = 0
	count=0
	for cov in UpCoverage:
		if(cov>0):
			total += cov
			count += 1
	trimMean = 0
	if count >20:
		trimMean = total/count;
	return trimMean


def main():
	parser = argparse.ArgumentParser(description="predict the exrepsssion level of PAS")
	parser.add_argument("--model", help="the model weights file", required=True)
	parser.add_argument("--file_path", help="input  sequence and coverage", required=True)
	parser.add_argument("--out", help="prediction files", required=True)
	parser.add_argument('--nfolds', default=5, type=int, help='Seperate the data into how many folds')
	args = parser.parse_args()

	length = 1001
	MODEL_PATH = args.model
	FILE_PATH = args.file_path
	out  = args.out
	NUM_FOLDS = args.nfolds

	OUT=open(out,'w')
	OUT.write("predict\tpolyA_read\n")
	train_data,train_labels,valid_data,valid_labels = prep_data(FILE_PATH,NUM_FOLDS)
	train_data = np.log(train_data+1)
	train_labels = np.log(train_labels)
	valid_data  = np.log(valid_data+1)
	valid_labels = np.log(valid_labels)
	#train_data = np.log((train_data+1)/12.61)
	#train_labels = np.log(train_labels/17.25)
	#valid_data  = np.log((valid_data+1)/12.61)
	#valid_labels = np.log(valid_labels/17.25)

	training_generator =  DataGenerator(train_data,train_labels,0)
	model = Regression_CNN(length);
	model.load_weights(MODEL_PATH)
	pred = model.predict(training_generator)

	for i in range(len(pred)):
		OUT.write('%s\t%s\n'%(pred[i][0],train_labels[i]))
	
if __name__ == "__main__":
	main()
