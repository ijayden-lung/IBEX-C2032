#!/usr/bin/perl -w
use List::Util qw(first max maxstr min minstr reduce shuffle sum shuffle) ;

open FILE,"BL6_REP1.pAs.predict.coverage.txt";
my $polyA= 0;
my $rna = 0;
while(<FILE>){
	chomp;
	my @data = split;
	$polyA+= $data[6];
	my $ave = sum(@data[57..1057])/1000;
	$rna+=$ave;
}

print "$polyA\n$rna\n";


