#!/usr/bin/perl -w
#

open FILE,"THLE2/quant.sf";
open GT,"../Figures/THLE2/Regression.THLE2ToTHLE2.gt.txt";
open OUT,">../Figures/THLE2/Regression.qapa.THLE2.txt";
<FILE>;
<GT>;
my %qapa_rpm;
my @pasid;
while(<FILE>){
	chomp;
	my ($name,$length,$elength,$tpm,$numReads) = split;
	my ($chr,$start,$end,$strand) = (split /\_/,$name)[-7..-4];
	my $pasid =  "$chr:$end:$strand";
	if($strand eq "-"){
		$pasid =  "$chr:$start:$strand";
	}
	$qapa_rpm{$pasid} = $tpm;
	push @pasid,$pasid;
}

my %qapa_total;
my %gt_rpm;
my %gt_total;
my %symbol_hash;
while(<GT>){
	chomp;
	my ($pas_id,$symbol,undef,$rpm) = split;
	if(exists $qapa_rpm{$pas_id}){
		$qapa_total{$symbol} += $qapa_rpm{$pas_id};
		$gt_rpm{$pas_id} = $rpm;
		$gt_total{$symbol} += $rpm;
		$symbol_hash{$pas_id} = $symbol;
	}
}

print OUT "pas_id\tsymbol\tqapa_rpm\tpolya_rpm\tqapa_usage\tpolya_usage\n";
foreach my $pas_id (@pasid){
	my $symbol = $symbol_hash{$pas_id};
	my $gt_rpm = $gt_rpm{$pas_id};
	my $qapa_rpm = $qapa_rpm{$pas_id};
	my $gt_usage = $gt_rpm/$gt_total{$symbol};
	my $qapa_usage;
	if($qapa_total{$symbol} == 0){
		$qapa_usage = 0;
	}
	else{
		$qapa_usage = $qapa_rpm/$qapa_total{$symbol};
	}
	print OUT "$pas_id\t$symbol\t$qapa_rpm\t$gt_rpm\t$qapa_usage\t$gt_usage\n";
}


