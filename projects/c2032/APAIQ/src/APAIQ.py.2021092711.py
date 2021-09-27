#!/usr/bin/python

import sys
import argparse


def args():
	parser = argparse.ArgumentParser()
	parser.add_argument('--out_dir', default=None, help='out dir')
	parser.add_argument('--input_file', default=None, help='unstranded wig file')
	parser.add_argument('--input_plus', default=None, help='plus strand wig file')
	parser.add_argument('--input_minus', default=None, help='minus strand wig file')
	parser.add_argument('--fa_file',default=None,help='path to one line fa file')
	parser.add_argument('--keep_temp',default=None,help='if you want to keep temporary file, set to "yes"')
	parser.add_argument('--window', default=201, type=int, help='input length')
  
	argv = parser.parse_args()

	root_dir = argv.out_dir
	input_file = argv.input_file
	input_plus = argv.input_plus
	input_minus = argv.input_minus
	fa_file = argv.fa_file
	keep_temp =  argv.keep_temp
	window   = argv.window
	return root_dir,input_file,input_plus,input_minus,fa_file,keep_temp,window

if __name__ == '__main__':
	root_dir,input_file,input_plus,input_minus,fa_file,keep_temp,window = args()
	print(root_dir,input_file,input_plus,input_minus,fa_file,keep_temp,window)


