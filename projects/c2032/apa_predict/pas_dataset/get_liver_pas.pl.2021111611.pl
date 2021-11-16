#!/usr/bin/perl -w

my %liver;
open FILE,"bl6.pasusage.tianbin.liver.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($id) = split;
	$liver{$id} = '';
}

open FILE,"bl6.pAs.tianbin.txt";
<FILE>;
open OUT,">bl6.pAs.tianbin.liver.txt";
print OUT "pas_id\tpas_type\tchr\tpostion\tstrand\tsymbol\tusage\n";
while(<FILE>){
	chomp;
	my ($id) =split;
	if(exists $liver{$id}){
		print OUT "$_\n";
	}
}

