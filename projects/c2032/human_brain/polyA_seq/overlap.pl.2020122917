#!/usr/bin/perl -w

open FILE,"hg38.pAs.tianbin.Control_REP1.info.cutoff";
my $header = <FILE>;
my %hash;
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	$hash{$pas_id} = $_;
}


open FILE,"hg38.pAs.tianbin.Control_REP1.info.cutoff";
<FILE>;
open OUT,">hg38.pAs.tianbin.Control.usage.txt";
print OUT "$header";
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	if(exists $hash{$pas_id}){
		print OUT "$_\n";
	}
}
