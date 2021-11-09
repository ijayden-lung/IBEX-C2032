#!/usr/bin/perl -w

open FILE,"../Figures/SNU398/predicted.txt";
<FILE>;
<FILE>;
open OUT,">Dist.txt";
print OUT "pas_id\tgt_diff\tstrand\n";
while(<FILE>){
	chomp;
	my ($pas_id,undef,$gt_diff,undef,undef,$score) = split;
	if($score >=12){
		my ($chr,$pos,$srd) = split /\:/,$pas_id;
		#if($srd eq "+"){
		#	$gt_diff -= 0.5;
		#}
		#if($srd eq "-"){
		#	$gt_diff += 0.5;
		#}
		print OUT "$pas_id\t$gt_diff\t$srd\n";
	}
}
