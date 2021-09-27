#!/usr/bin/perl -w
#
#
#
my ($PAS,$OUT) = @ARGV;

open FILE,"$PAS";
<FILE>;
open OUT,">$OUT";
while(<FILE>){
	chomp;
	my @data = split;
	my ($pas_id,$chr,$pos,$strand) = @data[0,2,3,4];
	my $pos0 = $pos-1;
	print OUT "$chr\t$pos0\t$pos\t$pas_id\t$strand\n";
}

