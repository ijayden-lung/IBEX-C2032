#!/usr/bin/perl -w

my %hash;
open FILE,"test";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	$hash{$pas_id} = '';
}

open FILE,"THLE2_Control.pAs.usage.txt";
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	if(!exists $hash{$pas_id}){
		print "$pas_id\n";
	}
}
