#!/usr/bin/perl -w
open FILE,"Figures/K562/predicted.txt";
my $pre_pos = 0;
while(<FILE>){
	chomp;
	my ($pas_id,$score) = (split)[0,-1];
	if($score>=12){
		my ($chr,$pos,$strand) = split /\:/,$pas_id;
		my $diff = abs($pre_pos -$pos);
		if($diff<50){
			print "$_\n";
		}
		$pre_pos  = $pos;
	}
}
