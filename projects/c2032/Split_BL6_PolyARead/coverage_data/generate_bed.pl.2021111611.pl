#!/usr/bin/perl -w

my ($inp,$output) = @ARGV;

open OUT,">$output.tmp";
open FILE,"$inp";
<FILE>;
<FILE>;
while(<FILE>){
	next if $_ =~ /^pas_id/;
	my ($pas_id,$score) = (split)[0,-1];
	next if $score < 12;
	my ($chr,$pos,$strand) = split /\:/,$pas_id;
	my $pre  = $pos-24;
	my $end =  $pos+24; ###12 for end could not extend
	print OUT "$chr\t$pre\t$end\t$pas_id\t$pos\t$strand\n";
}

system("sort -k1,1 -k2,2n -S 30G $output.tmp -o $output");
system("rm $output.tmp");
