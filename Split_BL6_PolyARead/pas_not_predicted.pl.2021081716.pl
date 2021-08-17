#!/usr/bin/perl -w

open FILE,"Figures/THLE2/predicted.txt";
<FILE>;
<FILE>;
my %hash;
while(<FILE>){
	chomp;
	my (undef,$gt_pasid) = split;
	$hash{$gt_pasid} = '';
}

open FILE,"usage_data/THLE2_Control.pAs.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my @data = split;
	if($data[6]>=0.05 && $data[7]>=1 && $data[10]>=0.05){
		if(!exists $hash{$data[0]}){
			print "$_\n";
		}
	}
}


