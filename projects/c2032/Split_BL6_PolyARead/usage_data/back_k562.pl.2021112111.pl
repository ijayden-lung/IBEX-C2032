#!/usr/bin/perl -w

my %hash;
open FILE,"../Figures/K562/K562_Chen.pAs.coverage.txt";
while(<FILE>){
	chomp;
	my ($pasid) = split;
	$hash{$pasid} = '';
}

open FILE,"K562_Chen.pAs.usage.txt";
while(<FILE>){
	chomp;
	my ($pasid) = split;
	if(exists $hash{$pasid}){
		print "$_\n";
	}
}
