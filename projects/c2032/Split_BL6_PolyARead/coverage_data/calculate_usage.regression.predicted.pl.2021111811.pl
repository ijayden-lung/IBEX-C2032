#!/usr/bin/perl -w

my %hash;
open OUT,">Regression.K562ToK562.predicted.txt";

open FILE,"K562.predicted.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$gt_id,$symbol) = (split)[0,5,6];
	$hash{$pas_id} = [$symbol,$gt_id];
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
