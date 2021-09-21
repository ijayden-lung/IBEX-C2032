#!/usr/bin/perl -w

open FILE,"Figures/THLE2/predicted.txt";
my $header = <FILE>;
chomp $header;
my $gt_num = (split /\s+/,$header)[-1];
<FILE>;
my %true;
my %predicted;
while(<FILE>){
	chomp;
	my (undef,undef,$gt_diff,undef,undef,$score) = split;
	for (my$i=0;$i<20;$i++){
		if($score>=$i){
			$predicted{$i}++;
			if(abs($gt_diff)<25){
				$true{$i}++;
			}
		}
	}
}

my $max_f1 = 0;
my $max_threshold = 0;
while(my ($key,$val) = each %true){
	my $total = $predicted{$key};
	my $precision = $val/$total;
	my $recall = $val/$gt_num;
	my $f1score = 2*$precision*$recall/($precision+$recall);
	if($f1score >$max_f1){
		$max_f1 = $f1score;
		$max_threshold = $key;
	}
}
print "$max_threshold\t$max_f1\n";
my $true_num = $true{$max_threshold};
my $total = $predicted{$max_threshold};
print "$true_num,$total\n";
