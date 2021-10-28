#!/usr/bin/perl -w

open FILE,"../Figures/THLE2/predicted.SC.txt";
<FILE>;
<FILE>;
my %hash;
while(<FILE>){
	chomp;
	my ($pas_id,undef,$gt_diff,undef,undef,$score) = split;
	if($score>=12 && abs($gt_diff)<25){
		$hash{$pas_id} = '';
	}
}


open USAGE,"THLE2_Control.usage.txt";
while(<USAGE>){
	chomp;
	my ($pas_id,$true) = split;
	if($true eq "True" && !exists $hash{$pas_id}){
		print "$_\n";
	}
}

