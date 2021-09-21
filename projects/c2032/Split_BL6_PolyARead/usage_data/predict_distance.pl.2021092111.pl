#!/usr/bin/perl -w

open FILE,"BL6_REP1.pAs.predict.aug8_SC_p5r10u0.05_4-0042.12.1.txt";
open OUT,">diff.txt";
print OUT "strand\tdiff\n";
while(<FILE>){
	chomp;
	my ($strand,$info)  = (split)[4,6];
	my ($gt_id,$gt_diff) = split /,/,$info;
	print OUT  "$strand\t$gt_diff\n";
}
