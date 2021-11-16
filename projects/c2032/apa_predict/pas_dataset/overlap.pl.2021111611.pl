#!/usr/bin/perl -w

my %hash;
open FILE,"bl6.pAs.zhangbin.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$position,$srd) = split;
	$hash{"$chr\t$position\t$srd"} = "$pas_id\t$pas_type";
}


open FILE,"bl6.pAs.tianbin.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$position,$srd) = split;
	my $key = "$chr\t$position\t$srd";
	if(exists $hash{"$chr\t$position\t$srd"}){
		print "$pas_id\t$pas_type\t$hash{$key}\n";
	}
}

	
