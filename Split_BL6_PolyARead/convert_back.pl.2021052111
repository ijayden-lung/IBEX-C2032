#!/usr/bin/perl -w


open FILE,"usage_data/HepG2_Control.pAs.predict.coverage.txt";
my %pas2symbol;
my %symbol2pas;
while(<FILE>){
	chomp;
	my ($pas_id,$symbol) = (split)[0,5];
	$pas2symbol{$pas_id} = $symbol;
	push @{$symbol2pas{$symbol}},$pas_id;
}

my %pas_num;
my %predict_gene;
my %polyA_gene;
my %predict_pas;
my %polyA_pas;
open FILE,"train.hepg2.mle.linear";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$predict,$polyA,$predict_readCount,$polyA_readCount) = split;
	my $symbol = $pas2symbol{$pas_id};
	$pas_num{$symbol}++;
	$predict_gene{$symbol} += $predict_readCount;
	$predict_pas{$pas_id}  = $predict_readCount;
	$polyA_gene{$symbol}  += $polyA_readCount;
	$polyA_pas{$pas_id}   =  $polyA_readCount;
}

open FILE,"valid.hepg2.mle.linear";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$predict,$polyA,$predict_readCount,$polyA_readCount) = split;
	my $symbol = $pas2symbol{$pas_id};
	$pas_num{$symbol}++;
	$predict_gene{$symbol} += $predict_readCount;
	$predict_pas{$pas_id}  = $predict_readCount;
	$polyA_gene{$symbol}  += $polyA_readCount;
	$polyA_pas{$pas_id}   =  $polyA_readCount;
}

open OUT,">all.hepg2.mle.linear";
print OUT "pas_id\tsymbol\tpas_num\tpredict_readCount\tpredict_usage\tpolyA_readCount\tpolyA_usage\n";
while(my ($symbol,$val) = each %symbol2pas){
	foreach my $pas_id (@$val){
		my $polyA_usage = $polyA_pas{$pas_id}/$polyA_gene{$symbol};
		my $predict_usage = $predict_pas{$pas_id}/$predict_gene{$symbol};
		print OUT "$pas_id\t$symbol\t$pas_num{$symbol}\t$predict_pas{$pas_id}\t$predict_usage\t$polyA_pas{$pas_id}\t$polyA_usage\n";
	}
}
