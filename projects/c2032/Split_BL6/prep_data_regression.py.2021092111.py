#!/usr/bin/env python3

import numpy as np
import os
import sys
import argparse
import glob
from sklearn.model_selection import KFold
from collections import defaultdict
from tensorflow.keras.utils import Sequence

def get_data(file_path):
	"""
	Process all files in the input directory to read sequences.
	Sequences are encoded with one-hot.
	label: the label (True or False) for the sequences in the input directory
	"""
	#data1 = dict() # coverage
	#labels= dict() # labels
	data1 = []
	labels = []
	with open(file_path,'r') as f:
		for line in f:
			line=line.rstrip('\n').split('\t')
			if (line[0] !='#pas_id' and line[0] !='pas_id'):
				pas_id = line[0]
				COVERAGE = np.array(line[7:len(line)]).astype(np.float32)
				#data1[pas_id] = COVERAGE.reshape([-1,1])
				#labels[pas_id] = line[6]
				data1.append(COVERAGE)
				labels.append(line[6])
	data1 = np.stack(data1).reshape([-1,len(data1[0]),1])
	labels = np.array(labels).astype(np.float32)
	return data1,labels

def shuffle(dataset1,labels, randomState=None):
	"""
	Shuffle sequences and labels jointly
	"""
	if randomState is None:
		permutation = np.random.permutation(labels.shape[0])
	else:
		permutation = randomState.permutation(labels.shape[0])
	shuffled_data1 = dataset1[permutation,:,:]
	shuffled_labels = labels[permutation]
	return shuffled_data1, shuffled_labels


def prep_data(file_path,NUM_FOLDS,OUT=None):
	data1,labels = get_data(file_path)
	print('Size of dataset: %d'%(len(labels)))

	kf = KFold(n_splits = NUM_FOLDS,random_state=len(labels),shuffle=True)
	folds = list(kf.split(labels))
	train_index,valid_index = folds[0]
	train_data = data1[train_index]
	valid_data = data1[valid_index]
	train_y    = labels[train_index]
	valid_y    = labels[valid_index]

	dataset = dict()
	dataset = {"train_data": train_data,"train_y":train_y,"valid_data":valid_data,"valid_y":valid_y}

	if OUT is not None:
		np.savez(OUT, **dataset)
		print('Finish writing dataset to %s'%OUT)

	#return dataset
	return train_data,train_y,valid_data,valid_y
	
class DataGenerator(Sequence):
	'Generates data for Keras'
	def __init__(self, data, labels, shift, length=2001,batch_size=32, shuffle=True):
		'Initialization'
		self.data = data
		self.labels = labels
		self.shift = shift
		self.length = length
		self.batch_size = batch_size
		self.shuffle = shuffle
		self.n = 0
		self.sizes = len(self.labels)
		self.on_epoch_end()

	def __len__(self):
		'Denotes the number of batches per epoch'
		return int(np.floor(self.sizes / self.batch_size))

	def __getitem__(self, index):
		'Generate one batch of data'
		# Generate indexes of the batch
		indexes = self.indexes[index*self.batch_size:(index+1)*self.batch_size]

		# Find list of IDs
		list_IDs_temp = [k for k in indexes]

		# Generate data
		X, y = self.__data_generation(list_IDs_temp)

		return X, y

	def __next__(self):
		if self.n >= self.__len__():
			self.n = 0
		X,y = self.__getitem__(self.n)
		self.n += 1
		return X,y

	def on_epoch_end(self):
		self.indexes = np.arange(self.sizes)
		if self.shuffle == True:
			np.random.shuffle(self.indexes)

	def __data_generation(self, list_IDs_temp):
		'Generates data containing batch_size samples' 
		# Initialization
		data = np.empty((self.batch_size, self.length, 1),dtype=float)
		y = np.empty((self.batch_size), dtype=float)
		# Generate data
		for i, ID in enumerate(list_IDs_temp):
			# Store sample
			#####Data augmentation
			if self.shift >0:
				random = np.random.randint(2*self.shift)
				offset = 50-self.shift+random
			else:
				offset = 50
			data[i,] = self.data[ID,offset:offset+self.length] 
			# Store class
			y[i] = self.labels[ID]
		X  = data
		return X,y	

if __name__ == "__main__":
	### Argument Parser
	parser = argparse.ArgumentParser()
	parser.add_argument('--file_path', help='coverage file to predict expression level of PAS')
	parser.add_argument('--out', help='Save the processed dataset to')
	parser.add_argument('--nfolds', default=5, type=int, help='Seperate the data into how many folds')
	opts = parser.parse_args()

	############Global Parameters ############
	NUM_FOLDS = opts.nfolds
	FILE_PATH  = opts.file_path
	OUT	   = opts.out
	############Global  Parameters ############
	prep_data(FILE_PATH,OUT)
