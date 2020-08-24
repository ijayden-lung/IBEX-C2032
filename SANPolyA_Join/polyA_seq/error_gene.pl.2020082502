#!/usr/bin/perl -w

open FILE,"bl6.pAs.tianbin.train.v3.bed.info.cutoff";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$symbol,$new_symbol,$new_pas_type,$extension,$biotype) = (split /\t/)[0,1,5,-4,-3,-2,-1];
	if($symbol ne $new_symbol && $biotype ne "protein_coding" && $pas_type ne "ncRNA" && $symbol ne "na" && $symbol !~ /ENS/){
		print "$pas_id\t$symbol\t$new_symbol\n";
	}
}
