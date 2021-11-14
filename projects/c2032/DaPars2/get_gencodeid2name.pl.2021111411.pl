#!/usr/bin/perl -w

open ENS,"/home/longy/cnda/gencode/gencode.v38.annotation.gtf ";
open OUT,">gencode2name.txt";
while(<ENS>){
	chomp;
	next if $_ =~ /^\#/;
	my ($chr,$source,$type,$start,$end,$srd,$info) = (split  /\t/)[0,1,2,3,4,6,8];
	next if $type ne "transcript";
	my %gene_info;
	for $item (split /\;\ /,$info){
		my ($key,$val) = split /\ /,$item;
		$val =~ s/\"|\;//g;
	}
