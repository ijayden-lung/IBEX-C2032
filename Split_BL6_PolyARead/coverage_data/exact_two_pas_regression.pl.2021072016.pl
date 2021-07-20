#!/usr/bin/perl -w


open FILE,"allpredict.thle2_control.usage.txt";
#open FILE,"../DaPar2/pAs.usage.txt";
<FILE>;
my %pas_count;
my %pas_usage;
my %predict_total;
my %predict_count;
while(<FILE>){
	chomp;
	my ($pas_id,$symbol,$usage,$observed,$predict)  = (split)[0,3,7,8,9];
	next if $predict ==0;;
	$pas_count{$symbol}++;
	$pas_usage{$symbol}->{$pas_id} = $usage;
	$predict_total{$symbol} += $predict;
	$predict_count{$symbol} += $predict;
}


my %first_time;
open FILE,"allpredict.thle2_control.usage.txt";
#open FILE,"../DaPar2/pAs.usage.txt";
<FILE>;
<FILE>;
open OUT,">two_pas.txt";
print OUT "pas_id\tobserved_usage\tpredict_usage\n";
while(<FILE>){
	chomp;
	my ($pas_id,$symbol,$usage,$observed,$predict)  = (split)[0,3,7,8,9];
	next if $predict ==0;;
	if($pas_count{$symbol} >=2 &&  !exists $first_time{$symbol}){
		my $predict_usage = $predict/$predict_total{$symbol};
		print OUT "$pas_id\t$usage\t$predict_usage\n";
		$first_time{$symbol} = '';
	}
}

