#!/usr/bin/perl -w

open FILE, '../usage_data/THLE2_Control.pAs.usage.txt';
open OUT,">test";
<FILE>;
while(<FILE>){
	chomp;
	my ($pasid,$pastype,$chr,$pos,$strand,$symbol) = split;
	my $pos1 = $pos-1;
	my $pos2 = $pos;
	if($strand eq "-"){
		$pos1 = $pos;
		$pos2 = $pos+1;
	}
	print OUT "$chr\t$pos1\t$pos2\t$symbol\t$pastype\t$strand\n";
}
