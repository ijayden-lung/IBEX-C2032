#!/usr/bin/perl -w

open ENS,"/home/longy/cnda/gencode/gencode.v38.annotation.gtf ";
open OUT,">gencode2name.txt";
print OUT "#name\tname2\n";
while(<ENS>){
	chomp;
	next if $_ =~ /^\#/;
	my ($chr,$source,$type,$start,$end,$srd,$info) = (split  /\t/)[0,1,2,3,4,6,8];
	if($chr =~ /MT/ || $chr =~ /Y/ || length($chr)>5){
		next;
	}
	next if $type ne "transcript";
	my %gene_info;
	for $item (split /\;\ /,$info){
		my ($key,$val) = split /\ /,$item;
		$val =~ s/\"|\;//g;
		$gene_info{$key} = $val;
	}
	print OUT "$gene_info{'transcript_id'}\t$gene_info{'gene_name'}\n";
}
