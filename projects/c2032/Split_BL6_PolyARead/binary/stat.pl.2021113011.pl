#!/usr/bin/perl -w
my ($binary,$predict) = @ARGV;

my %hash;
open FILE,"$binary";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type) = split;
	if($pas_type =~ /unknown/){
		$hash{$pas_id} = "False";
	}
	else{
		$hash{$pas_id} = "True";
	}
}

my $tp=0;
my $fp=0;
my $fn=0;
my $tn=0;
open FILE,"$predict";
while(<FILE>){
	chomp;
	my ($pas_id,$score)  = split;
	if($hash{$pas_id} eq "True"){
		if($score>0.5){
			$tp++;
		}
		else{
			$fn++;
		}
	}
	else{
		if($score >0.5){
			$fp++;
		}
		else{
			$tn++;
		}
	}
}

my $tpr = $tp/($tp+$fn);
my $fdr = $fp/($tp+$fp);
my $acc = ($tp+$tn)/($tp+$fp+$fn+$tn);

print "$tp\t$fp\t$fn\t$tn\t$tpr\t$fdr\t$acc\n";
