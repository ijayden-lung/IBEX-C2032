#!/usr/bin/perl -w
for(my$i=0;$i<10;$i++){
	my $upper_limit = 3214482;
	my $lower_limit = 3216021;
	my $random = int(rand($upper_limit-$lower_limit)) + $lower_limit;
	print "$random\n"
}
