#!/usr/bin/perl -w
my %hash;
open FILE,"maxSum/THLE2_Control.pAs.single_kermax6.THLE2_Control_aug12_SC_p1r0.05u0.05_0-0423.chr7_+_0.txt.right.0.1.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	$hash{$pas_id} = '';
}


open FILE,"scan/THLE2_Control.pAs.single_kermax6.THLE2_Control_aug12_SC_p1r0.05u0.05_0-0423.chr7_+_0.reverse.0.1.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	if(!exists $hash{$pas_id}){
		print "$pas_id\n";
	}
}
