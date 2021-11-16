#!/usr/bin/perl -w

open FILE,"/home/longy/project/Split_BL6_PolyARead/Figures/SNU398/predicted.txt";

<FILE>;
<FILE>;
open OUT,">test.txt";
print OUT "#chromosme\tstart\tend\tpasid\tscore\tstrand\n";
while(<FILE>){
	chomp;
	my ($pas_id,$score) = (split)[0,-1];
	if($score>=12){
		my ($chr,$pos,$strand)  = split /\:/,$pas_id;
		my $start = $pos-1;
		print OUT "$chr\t$start\t$pos\t$pas_id\t$score\t$strand\n";
	}
}
