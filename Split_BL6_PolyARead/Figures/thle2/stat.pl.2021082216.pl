#!/usr/bin/perl -w

my ($threshold) = @ARGV;
open FILE,"predicted.txt";
<FILE>;
<FILE>;
my $total = 0;
my $true  = 0;
while(<FILE>){
	my (undef,undef,$pas_diff,undef,undef,$score) = split;
	if($score >= $threshold){
		$total += 1;
		if(abs($pas_diff)<=25){
			$true++;
		}
	}
}
my $precision = $true/$total;
print "$precision\n";
my $recall = $true/20258;
print "$recall\n";

