#!/usr/bin/perl -w
#

my $output = "stackTHLE2_1.bed";
open FILE,"modTHLE2_1.bed";

open OUT,">$output.tmp";
#print OUT "position\treadCount\n";

my %hash;

while(<FILE>){
	chomp;
	my ($chr,undef,$pos,undef,undef,$strand) = split;
	next if $chr =~ /KI|GL|Y|MT/;
	if($strand eq "+"){
		$strand = "-";
	}
	else{
		$strand = "+";
	}
	$hash{"$chr:$pos:$strand"}++;
}

foreach my $key (keys %hash){
	my ($chr,$pos,$strand) = split /\:/,$key;
	my $pos0 = $pos-1;
	print OUT "$chr\t$pos0\t$pos\t$hash{$key}\t255\t$strand\n";
}

system("sort -k1,1 -k6,6 -k2,2n -S 30G $output.tmp -o $output");
