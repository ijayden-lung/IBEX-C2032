#!/usr/bin/perl -w

my ($inp,$output,$cell) = @ARGV;

open FILE,"$inp";
open OUT,">$output.tmp";
open OUT2,">$cell.pAs.coverage.txt";
while(<FILE>){
	next if $_ =~ /^Gene/;
	my ($info,$fit_value,$pos,$distal,$snu398,$thle2,$k562,$hepg2) = split;
	my $usage = 0;
	if($cell eq "THLE2"){
		$usage = $thle2;
	}
	elsif($cell eq "SNU398"){
		$usage = $snu398;
	}
	elsif($cell eq "K562"){
		$usage = $k562;
	}
	elsif($cell eq "hepg2"){
		$usage = $hepg2;
	}
	next if $usage eq "NA";
	my ($gene_id,$symbol,$chr,$strand) = split /\|/,$info;
	my $pre  = $pos-24;
	my $end =  $pos+24; ###12 for end could not extend
	my $pas_id = "$chr:$pos:$strand";
	my $pas_type = "3'UTR";
	if($usage<1){
		print OUT "$chr\t$pre\t$end\t$pas_id\t$pos\t$strand\n";
		my $pdui = 1-$usage;
		print OUT2 "$pas_id\t$fit_value\t$pas_type\t$chr\t$pos\t$strand\t$symbol\t$pdui\n";
	}

	my (undef,$pos1,$pos2) = split /\:|\-/,$distal;
	if($strand eq "+"){
		$pre = $pos2-24;
		$end = $pos2+24;
		$pas_id = "$chr:$pos2:$strand";
		$pas_type = "Terminal";
		print OUT "$chr\t$pre\t$end\t$pas_id\t$pos2\t$strand\n";
		print OUT2 "$pas_id\t$fit_value\t$pas_type\t$chr\t$pos2\t$strand\t$symbol\t$usage\n";
	}
	else{
		$pre = $pos1-24;
		$end = $pos1+24;
		$pas_id = "$chr:$pos2:$strand";
		$pas_type = "Terminal";
		print OUT "$chr\t$pre\t$end\t$pas_id\t$pos1\t$strand\n";
		print OUT2 "$pas_id\t$fit_value\t$pas_type\t$chr\t$pos1\t$strand\t$symbol\t$usage\n";
	}
}

system("sort -k1,1 -k2,2n -S 30G $output.tmp -o $output");
system("rm $output.tmp");
