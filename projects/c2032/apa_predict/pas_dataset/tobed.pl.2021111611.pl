#!/usr/bin/perl -w

open FILE,"human.PAS.txt";
<FILE>;
open OUT,">human.PAS.bed";
while(<FILE>){
	chomp;
	my ($pas_id,$chr,$pos,$srd) = split;
	my $str=$pos-1;
	print OUT "$chr\t$str\t$pos\t$pas_id\t.\t$srd\n";
}

