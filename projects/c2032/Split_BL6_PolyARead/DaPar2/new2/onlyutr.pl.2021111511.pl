#!/usr/bin/perl -w

my %hash;
open FILE,"SNU398.pAs.coverage.txt";
while(<FILE>){
	my ($pas_id,undef,$pas_type) = split;
	if($pas_type =~ /UTR/){
		$hash{$pas_id} = '';
	}
}

open FILE,"predicted.Dapar2.txt";
<FILE>;
my $total = 0;
my $truth = 0;
while(<FILE>){
	chomp;
	my ($pas_id,undef,$gt_diff) = split;
	if(exists $hash{$pas_id}){
		$total++;
		if(abs($gt_diff)<25){
			$truth++;
		}
	}
}

print "$truth\t$total\n";
	

	
