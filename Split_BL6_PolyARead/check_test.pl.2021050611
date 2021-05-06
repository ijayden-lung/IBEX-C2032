#!/usr/bin/perl -w

open FILE,'test';
<FILE>;
my %hash;
while(<FILE>){
	chomp;
	my ($predict,$polyA) = split;
	$hash{$polyA}++;
}
while(my($key,$val)  = each %hash){
	if($val>28){
		print"$key\t$val\n";
	}
	#if($key<0.004){
	#	print"$key,$val\n";
	#}
}

