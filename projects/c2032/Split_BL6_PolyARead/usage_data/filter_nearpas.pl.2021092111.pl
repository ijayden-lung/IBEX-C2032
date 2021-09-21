#!/usr/bin/perl -w

open FILE,"test";
#open FILE,"HepG2.text";
<FILE>;
my %reduce_symbol;
my $pre_pos = 0;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$symbol,$pr,$rr,$pu,$ru) = split;
	next if $pu eq 1;
	my ($chr,$pos,$srd) = split /\:/,$pas_id;
	if(abs($pre_pos-$pos)<900){
		$reduce_symbol{$symbol} = '';
	}
	#if($pas_type eq "ncRNA"){
	#	$reduce_symbol{$symbol} = '';
	#}
	$pre_pos = $pos;
}

#open FILE,'HepG2.text';
open FILE,'test';
my $header  = <FILE>;
open OUT,">test2";
print OUT "$header";
open OUT2,">test3";
print OUT2 "$header";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$symbol,$pr,$rr,$pu,$ru) = split;
	next if $pu eq 1;
	if(!exists $reduce_symbol{$symbol}){
		print OUT "$_\n";
	}
	else{
		print OUT2 "$_\n";
	}
}

