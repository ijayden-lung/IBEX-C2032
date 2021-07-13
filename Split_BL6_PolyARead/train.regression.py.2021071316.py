from RegressionModel import *
import os, sys, copy, getopt, re, argparse
import random
from datetime import datetime
import pandas as pd 
import numpy as np
from tensorflow.keras.callbacks import TensorBoard
from tensorflow.keras.callbacks import ModelCheckpoint
from prep_data_regression import prep_data,DataGenerator,EvaDataGenerator,get_data


class GroupNormalization(Layer):
	def __init__(self,groups=32,axis=-1,epsilon=1e-5,center=True,scale=True,beta_initializer='zeros',gamma_initializer='ones',beta_regularizer=None,
				 gamma_regularizer=None,beta_constraint=None,gamma_constraint=None,**kwargs):
		super(GroupNormalization, self).__init__(**kwargs)
		self.supports_masking = True
		self.groups = groups
		self.axis = axis
		self.epsilon = epsilon
		self.center = center
		self.scale = scale
		self.beta_initializer = initializers.get(beta_initializer)
		self.gamma_initializer = initializers.get(gamma_initializer)
		self.beta_regularizer = regularizers.get(beta_regularizer)
		self.gamma_regularizer = regularizers.get(gamma_regularizer)
		self.beta_constraint = constraints.get(beta_constraint)
		self.gamma_constraint = constraints.get(gamma_constraint)

	def build(self, input_shape):
		dim = input_shape[self.axis]

		if dim is None:
			raise ValueError('Axis '+str(self.axis)+' of input tensor should have a defined dimension but the layer received an input with shape '+str(input_shape)+'.')

		if dim < self.groups:
			raise ValueError('Number of groups ('+str(self.groups)+') cannot be more than the number of channels ('+str(dim)+').')

		if dim % self.groups != 0:
			raise ValueError('Number of groups ('+str(self.groups)+') must be a multiple of the number of channels ('+str(dim)+').')

		self.input_spec = InputSpec(ndim=len(input_shape),axes={self.axis: dim})
		shape = (dim,)

		if self.scale:
			self.gamma = self.add_weight(shape=shape,name='gamma',initializer=self.gamma_initializer,regularizer=self.gamma_regularizer,constraint=self.gamma_constraint)
		else:
			self.gamma = None

		if self.center:
			self.beta = self.add_weight(shape=shape,name='beta',initializer=self.beta_initializer,regularizer=self.beta_regularizer,constraint=self.beta_constraint)
		else:
			self.beta = None

		self.built = True

	def call(self, inputs, **kwargs):
		input_shape = K.int_shape(inputs)
		tensor_input_shape = K.shape(inputs)

		# Prepare broadcasting shape.
		reduction_axes = list(range(len(input_shape)))
		del reduction_axes[self.axis]
		broadcast_shape = [1] * len(input_shape)
		broadcast_shape[self.axis] = input_shape[self.axis] // self.groups
		broadcast_shape.insert(1, self.groups)

		reshape_group_shape = K.shape(inputs)
		group_axes = [reshape_group_shape[i] for i in range(len(input_shape))]
		group_axes[self.axis] = input_shape[self.axis] // self.groups
		group_axes.insert(1, self.groups)

		# reshape inputs to new group shape
		group_shape = [group_axes[0], self.groups] + group_axes[2:]
		group_shape = K.stack(group_shape)
		inputs = K.reshape(inputs, group_shape)

		group_reduction_axes = list(range(len(group_axes)))
		group_reduction_axes = group_reduction_axes[2:]

		mean = K.mean(inputs, axis=group_reduction_axes, keepdims=True)
		variance = K.var(inputs, axis=group_reduction_axes, keepdims=True)
		inputs = (inputs - mean) / (K.sqrt(variance + self.epsilon))

		# prepare broadcast shape
		inputs = K.reshape(inputs, group_shape)
		outputs = inputs

		# In this case we must explicitly broadcast all parameters.
		if self.scale:
			broadcast_gamma = K.reshape(self.gamma, broadcast_shape)
			outputs = outputs * broadcast_gamma

		if self.center:
			broadcast_beta = K.reshape(self.beta, broadcast_shape)
			outputs = outputs + broadcast_beta

		outputs = K.reshape(outputs, tensor_input_shape)

		return outputs
	

def CNN(inputs):
	x = Conv1D(filters= 16, kernel_size= 12, padding = 'valid', kernel_regularizer = regularizers.l2(1e-4), bias_regularizer = regularizers.l2(1e-4))(inputs)
	#x = GroupNormalization(groups = 4, axis = -1)(x) 
	x = Activation('relu')(x)
	x = MaxPooling1D(pool_size = 12)(x)
	x = Dropout(0.5)(x)
	#x = Conv1D(filters= 32, kernel_size= 12, padding = 'valid', kernel_regularizer = regularizers.l2(1e-4), bias_regularizer = regularizers.l2(1e-4))(x)
	#x = Activation('relu')(x)
	#x = MaxPooling1D(pool_size = 12)(x)
	#x = Dropout(0.5)(x)
	x = Flatten()(x)
	x = Dense(32,kernel_regularizer = regularizers.l2(1e-4),bias_regularizer = regularizers.l2(1e-4))(x)
	x = Activation('relu')(x)
	x = Dropout(0.5)(x)
	return x

def Regression_CNN(length):

	input_shape1 = (length,1)
	cov_input = Input(shape = input_shape1,name="cov_input")
	input_layers = cov_input

	x = CNN(cov_input)
	outLayer= Dense(1, activation='linear')(x)

	model = Model(inputs=input_layers, outputs=outLayer)

	return model

def evaluate(x,y,pasid,trainid,dataset,length,bestEpoch):
	test_generator = EvaDataGenerator(x)
	model = Regression_CNN(length);
	MODEL_PATH = 'Model/'+trainid+'-'+bestEpoch+'.ckpt'
	model.load_weights(MODEL_PATH)
	print('load weight success')
	pred = model.predict_generator(test_generator)
	OUT=open(dataset+'.'+trainid,'w')
	OUT.write("pas_id\tpredict\tpolyA_read\n")
	for i in range(len(pred)):
		predict = pred[i][0]
		truth = y[i]
		OUT.write('%s\t%s\t%s\n'%(pasid[i],predict,truth))
	OUT.close()

def normalization(train_data,train_labels,valid_data,valid_labels):
    train_data = np.log(train_data+0.03)
    train_labels = np.log(train_labels)
    valid_data = np.log(valid_data+0.03)
    valid_labels = np.log(valid_labels)
    data_mean = np.mean(train_data)
    data_std  = np.std(train_data)
    label_mean = np.mean(train_labels)
    label_std  = np.std(train_labels)
    
    data_max = np.max(train_data)
    
    train_data = (train_data-data_mean)/data_std
    #train_data = train_data/data_max
    #train_data  = train_data/300
    train_labels = (train_labels-label_mean)/label_std
    
    valid_data  = (valid_data-data_mean)/data_std
    #valid_data    = valid_data/data_max
    #valid_data  = valid_data/300
    valid_labels = (valid_labels-label_mean)/label_std
    
    
    return data_mean,data_std,data_max,label_mean,label_std,train_data,train_labels,valid_data,valid_labels



if __name__ == "__main__":
	print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))
	print("Num CPUs Available: ", len(tf.config.experimental.list_physical_devices('CPU')))

	parser = argparse.ArgumentParser()
	parser.add_argument('--trainid', default=None, help='Save model weights to (.npz file)')
	parser.add_argument('--model', default=None, help='Resume from previous model')
	parser.add_argument('--file_path', help='Directory of files containing positive and negative files')
	parser.add_argument('--nfolds', default=5, type=int, help='Seperate the data into how many folds')
	parser.add_argument('--learning_rate', default=1e-4, type=float, help='learning rate')
	parser.add_argument('--epochs', default=100, type=int, help='number of epochs')
	parser.add_argument('--shift', default=0, type=int, help='shift augmentation')
	parser.add_argument('--length', default=1001, type=int, help='window length')
	args = parser.parse_args()
	trainid=args.trainid
	Path= args.model
	NUM_FOLDS = args.nfolds
	FILE_PATH = args.file_path
	epochs =  args.epochs
	learning_rate = args.learning_rate
	shift = args.shift
	length= args.length

	print('trainid is '+trainid) 
	#train_data,train_labels,valid_data,valid_labels = prep_data(FILE_PATH,NUM_FOLDS)
	train_data,train_labels,train_pasid,valid_data,valid_labels,valid_pasid = prep_data(FILE_PATH,NUM_FOLDS)

	data_mean,data_std,data_max,label_mean,label_std, train_x,train_y,valid_x,valid_y = normalization(train_data,train_labels,valid_data,valid_labels)
	
	

	training_generator =  DataGenerator(train_x,train_y,train_pasid,shift,length)
	validation_generator = DataGenerator(valid_x,valid_y,valid_pasid,shift,length)

	checkpoint_path = "Regression_Model/"+trainid+"-{epoch:04d}.ckpt"
	# Create a callback that saves the model's weights
	cp_callback = ModelCheckpoint(filepath=checkpoint_path,save_weights_only=True,verbose=1,period=10)


	model = Regression_CNN(length)

	log_dir = "TensorBoard/Regression/" + trainid + "_" + datetime.now().strftime("%Y%m%d-%H%M%S")
	tensorboard_cbk = TensorBoard(log_dir=log_dir)

	lr_schedule = schedules.ExponentialDecay(learning_rate,decay_steps=5000,decay_rate=0.96)
	#model.compile(loss='mean_squared_error', optimizer= SGD(momentum = 0.98, learning_rate = lr_schedule), metrics=['mse'])
	model.compile(loss='mean_absolute_error', optimizer= SGD(momentum = 0.98, learning_rate = lr_schedule), metrics=['mse'])

	#plot_model(model, to_file=combination+'model_plot.png', show_shapes=True, show_layer_names=True)
	#print(model.summary())

	model.fit(training_generator,epochs=epochs,validation_data=validation_generator,callbacks=[tensorboard_cbk,cp_callback])
	
	#valuate(train_x,train_y,train_pasid,trainid,'train',length,990)
	#valuate(valid_x,valid_y,valid_pasid,trainid,'valid',length,990)
