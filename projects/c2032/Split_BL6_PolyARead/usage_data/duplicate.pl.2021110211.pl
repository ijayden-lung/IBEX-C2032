#!/usr/bin/perl -w

#open FILE,"BL6_REP1.pAs.predict.aug8_SC_p5r10u0.05_4-0042.12.8.txt";
#open FILE,"awk '(\$7>0.05 && \$8>5 && \$11>10)' BL6_REP1.pAs.usage.txt | ";
#open FILE,"thle2_control.pAs.usage.txt";
open FILE,"THLE2_Control.pAs.usage.txt";
<FILE>;
my $pre_pos = 0;
my $pre_line = '';
while(<FILE>){
	chomp;
	my ($pos) = (split /\t/)[3];
	if(abs($pos-$pre_pos)<50){
		print "$pre_line\n$_\n";
	}
	$pre_pos = $pos;
	$pre_line = $_;
}
