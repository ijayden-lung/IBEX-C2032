#!/usr/bin/perl -w

#####我filter掉了一些，这是不玩美的，到时候改善。
open FILE,"bl6.pAs.predicted.usage.txt";
<FILE>;
my %count;
while(<FILE>){
	chomp;
	my @data = split;
	my $symbol = $data[5];
	$count{$symbol}++;
}

my $total = 0;
my $multi_pas = 0;
while(my ($key,$val) = each %count){
	if($val>1){
		$multi_pas++;
	}
	$total++;
}
my $per = $multi_pas/$total;
print "$per\t$multi_pas\t$total\n";

