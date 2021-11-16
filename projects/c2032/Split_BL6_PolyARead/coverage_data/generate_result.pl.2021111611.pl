#!/usr/bin/perl -w

my ($inp,$output) = @ARGV;

open OUT,">$output.tmp";
open FILE,"$inp";
<FILE>;
<FILE>;
while(<FILE>){
	next if $_ =~ /^pas_id/;
	my ($pas_id,undef,$gt_diff,$db_pasid,$db_diff,$score) = split;
	next if $score < 12;
	my ($chr,$pos,$strand) = split /\:/,$pas_id;
	my $is_true = "False";
	if(abs($gt_diff)<25){
		$is_true = "True";
	}
	print OUT "$pas_id\t$chr\t$pos\t$strand\t$is_true\t$db_pasid\n";
}

system("sort -k2,2 -k3,3n -S 30G $output.tmp -o $output");
system("rm $output.tmp");
