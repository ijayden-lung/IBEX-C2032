#!/usr/bin/perl -w

open FILE,"examples/hg38/output_utrs.bed";
my %hash;
while(<FILE>){
	chomp;
	my ($chr,$start,$end,$id,undef,$strand) = split;
	if($strand eq "+"){
		$hash{"$chr:$end:$strand"} = '';
	}
	else{
		$hash{"$chr:$start:$strand"} = '';
	}
}


open FILE,"../usage_data/SNU398_Control.pAs.usage.txt";
while(<FILE>){
	chomp;
	my ($pasid) = split;
	if(!exists $hash{$pasid}){
		print "$_\n";
	}
}
