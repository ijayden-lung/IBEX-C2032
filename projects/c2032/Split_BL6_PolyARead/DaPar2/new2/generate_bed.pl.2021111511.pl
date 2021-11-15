#!/usr/bin/perl -w

my ($inp,$output,$cell) = @ARGV;

open FILE,"$inp";
open OUT,">$output.tmp";
open OUT2,">$cell.pAs.coverage.txt.tmp";
my %utr_hash;
my %utr_info;
my %utr_ter;
while(<FILE>){
	next if $_ =~ /^Gene/;
	my ($info,$fit_value,$pos,$distal,$snu398,$thle2,$k562,$hepg2) = split;
	my $pdui = 0;
	if($cell eq "THLE2"){
		$pdui = $thle2;
	}
	elsif($cell eq "SNU398"){
		$pdui = $snu398;
	}
	elsif($cell eq "K562"){
		$pdui = $k562;
	}
	elsif($cell eq "hepg2"){
		$pdui = $hepg2;
	}
	next if $pdui eq "NA";
	my ($gene_id,$symbol,$chr,$strand) = split /\|/,$info;
	my $pre  = $pos-24;
	my $end =  $pos+24; ###12 for end could not extend
	my $pas_id = "$chr:$pos:$strand";
	my (undef,$pos1,$pos2) = split /\:|\-/,$distal;
	my $pas_id2 = "$chr:$pos2:$strand";
	if($strand eq "-"){
		$pas_id2 = "$chr:$pos1:$strand";
	}
	if(!exists $utr_hash{$pas_id} || $utr_hash{$pas_id}<$fit_value){ 
		$utr_hash{$pas_id} = $fit_value;
		$utr_info{$pas_id} = [$symbol,$pdui];
		$utr_ter{$pas_id} = $pas_id2;
	}
}

while(my($pas_id,$fit_value) = each %utr_hash){
	my ($symbol,$pdui) = @{$utr_info{$pas_id}};
	my ($chr,$pos,$strand) = split /\:/,$pas_id;
	my $pre = $pos-24;
	my $end = $pos+24;
	print OUT "$chr\t$pre\t$end\t$pas_id\t$pos\t$strand\n";
	print OUT2 "$pas_id\t$fit_value\t3'UTR\t$chr\t$pos\t$strand\t$symbol\t$pdui\n";
	$pas_id = $utr_ter{$pas_id};
	(undef,$pos,undef) = split /\:/,$pas_id;
	$pre = $pos-24;
	$end = $pos+24;
	my $pdui2 = 1-$pdui;
	next if $pdui2 <=0;
	print OUT "$chr\t$pre\t$end\t$pas_id\t$pos\t$strand\n";
	print OUT2 "$pas_id\t$fit_value\tTerminal\t$chr\t$pos\t$strand\t$symbol\t$pdui2\n";
}

system("sort -k1,1 -k2,2n -S 30G $output.tmp -o $output");
system("sort -k4,4 -k6,6 -k5,5n $cell.pAs.coverage.txt.tmp -o $cell.pAs.coverage.txt");
system("rm *.tmp");
