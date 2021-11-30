#!/usr/bin/perl -w

my %hash;
open FILE,"thle2.predict.txt";
while(<FILE>){
	chomp;
	my ($pas_id)  = split;
	$hash{$pas_id} = '';
}

open FILE,"thle2.binary.txt";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type) = split;
	if(!exists $hash{$pas_id}){
		print "$pas_id\t$pas_type\n";
	}
}
