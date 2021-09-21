#!/usr/bin/perl -w

my ($chr,$file,$out) = @ARGV;
open FILE,"$file";
open OUT,">$out";
while(<FILE>){
	chomp;
	my ($chromosome) = split;
	if($chr eq $chromosome){
		print OUT "$_\n";
	}
}

