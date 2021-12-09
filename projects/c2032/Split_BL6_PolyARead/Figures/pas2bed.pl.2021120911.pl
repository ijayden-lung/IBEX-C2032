#!/usr/bin/perl -w

open OUT,">test";
open FILE, 'TCGA.LIHC.cut2sam.final.refind.cluster.pastype';
while(<FILE>){
	chomp;
	my @data = split;
	my ($chr,undef,undef,$pasid,undef,$strand,$pos1,$pos2,$symbol,$pastype) = split;
	if($strand eq "-"){
		$pos1++;
		$pos2++;
	}
	print OUT "$chr\t$pos1\t$pos2\t$symbol\t$pastype\t$strand\n";
}

=pod
open FILE,"THLE2/new_pastype.groundtruth.txt";
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
=cut
