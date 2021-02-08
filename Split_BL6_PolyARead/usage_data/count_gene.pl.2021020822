#!/usr/bin/perl -w


my %hash;
open FILE,"K562_ZRANB2.pAs.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my @data = split;
	$hash{$data[0]} = [$data[5],$data[7],$data[10]];
}

open OUT,">K562_ZRANB2.pAs.volcano.txt";
for(my$i=0;$i<=20;$i++){
	for(my$j=0;$j<=30;$j++){
		my %count;
		while(my ($key,$val) = each %hash){
			my $symbol = $val->[0];
			my $polyARC = $val->[1]*2;
			my $RNARC = $val->[2];
			next if $polyARC <= $i;
			next if $RNARC <= $j;
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
		print OUT "$per\t";
	}
	print OUT "\n";
}
