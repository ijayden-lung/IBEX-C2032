#!/usr/bin/perl -w

open FILE,"aug0_round3.right.txt";
open OUT,">MaxPoint.thround5.txt";
print OUT "Type\tmaxPoint\n";
while(<FILE>){
	next if $_ =~ /predict/;
	chomp;
	my ($pos,$id,$diff,$chr,$strand,$gt_id,$gt_diff,$db_id,$db_diff,$maxPoint) = split;
	#my ($pas_id, $maxPoint,$maxPos,$start,$end) = split;
	if(abs($gt_diff) < 25){
		print OUT "TP\t$maxPoint\n";
	}
	else{
		print OUT "FP\t$maxPoint\n";
	}
}
