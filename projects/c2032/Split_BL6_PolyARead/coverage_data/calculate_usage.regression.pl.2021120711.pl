#!/usr/bin/perl -w

my %hash;
open FILE,"K562.gt.gt.txt" ;
open OUT,">Regression.HepG2ToK562.gt.txt";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage) = split;
	$hash{$pas_id} = [$symbol,$usage];
}

open FILE,"../test";
<FILE>;
my %total;
my %truth_total;
while(<FILE>){
	chomp;
	my ($pas_id,undef,undef,$predict,$polya) =split;
	my $symbol = $hash{$pas_id}->[0];
	$total{$symbol} += $predict;
	$truth_total{$symbol} += $polya;
}
	
open FILE,"../test";
<FILE>;
print OUT "pas_id\tsymbol\tpredicted_rpm\tpolya_rpm\tpredicted_usage\tpolya_usage\n";
while(<FILE>){
	chomp;
	my ($pas_id,undef,undef,$predict,$polya) =split;
	my $symbol = $hash{$pas_id}->[0];
	my $usage = $predict/$total{$symbol};
	my $truth_usage = $polya/$truth_total{$symbol};
	print OUT "$pas_id\t$symbol\t$predict\t$polya\t$usage\t$truth_usage\n";
}
	
