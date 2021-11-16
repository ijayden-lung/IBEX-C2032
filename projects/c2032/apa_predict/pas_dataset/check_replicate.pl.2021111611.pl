#!/usr/bin/perl -w

my %hash;
open FILE,"bl6.sequence.zhangbin.fibroblast.txt";
while(<FILE>){
	chomp;
	$hash{$_}++;
}

while(my($key,$val) = each %hash){
	if($val>4){
		print "$key\n";
	}
}
