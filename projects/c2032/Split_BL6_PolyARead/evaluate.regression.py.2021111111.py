from RegressionModel import *
import re
import os, sys, copy, getopt, re, argparse
import random
import pandas as pd 
import numpy as np
from prep_data_regression import prep_data,DataGenerator

def main():
	parser = argparse.ArgumentParser(description="predict the exrepsssion level of PAS")
	parser.add_argument("--model", help="the model weights file", required=True)
	parser.add_argument("--file_path", help="input  sequence and coverage", required=True)
	parser.add_argument("--out", help="prediction files", required=True)
	parser.add_argument('--nfolds', default=5, type=int, help='Seperate the data into how many folds')
	parser.add_argument('--depth', default=10, type=float, help='polyA-seq depth')
	args = parser.parse_args()

	length = 1001
	MODEL_PATH = args.model
	FILE_PATH = args.file_path
	out  = args.out
	NUM_FOLDS = args.nfolds
	depth = args.depth

	OUT=open(out,'w')
	OUT.write("predict\tpolyA_read\n")
	train_data,train_labels,train_pasid,valid_data,valid_labels,valid_pasid = prep_data(FILE_PATH,NUM_FOLDS,depth)
	train_data = np.log(train_data+0.03)
	train_labels = np.log(train_labels+0.5)
	valid_data  = np.log(valid_data+0.03)
	valid_labels = np.log(valid_labels+0.5)

	training_generator =  DataGenerator(train_data,train_labels,train_pasid,0)
	model = Regression_CNN(length);
	model.load_weights(MODEL_PATH)
	pred = model.predict(training_generator)

	for i in range(len(pred)):
		OUT.write('%s\t%s\n'%(pred[i][0],train_labels[i]))
	
if __name__ == "__main__":
	main()
