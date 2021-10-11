#!/usr/bin/perl -w

#open FILE,"THLE2_Control.usage.txt";

sub Get_GT_Usage{
	my ($file) = @_;
	open FILE,"$file";
	<FILE>;
	my %hash;
	while(<FILE>){
		chomp;
		my ($pas_id,$symbol,$usage) = (split)[0,5,6];
		$hash{$pas_id} = $usage;
	}
	return \%hash;
}

sub Get_Predict_Usage{
	my ($file,$type) = @_;
	open FILE,"$file";
	<FILE>;
	<FILE>;
	my %hash;
	while(<FILE>){
		chomp;
		my ($pas_id,$gt_id,$gt_diff,$db_id,$db_diff,$score) = split;
		if($type eq "apaiq"){
			if(abs($db_diff)<25){
				$hash{$db_id} = abs($gt_diff);
			}
		}
		else{
			if($score>12 && abs($gt_diff)>50 && abs($db_diff)<25){
				$hash{$db_id} = abs($db_diff);
			}
		}
	}
	return \%hash;
}


my $usage_ref = &Get_GT_Usage("../usage_data/SNU398_Control.pAs.usage.txt");
my %usage_hash = %$usage_ref;

my $dna_pre_ref = &Get_Predict_Usage("../Figures/SNU398/predicted.sequence.txt","dna");
my %dna_pre = %$dna_pre_ref;
my $combine_pre_ref = &Get_Predict_Usage("../Figures/SNU398/predicted.txt","apaiq");
my %combine_pre = %$combine_pre_ref;

while (my ($key,$val) = each %dna_pre){
	#if(!exists $usage_hash{$key} && !exists $combine_pre{$key}){
	if(!exists $usage_hash{$key} && !exists $combine_pre{$key}){
		print "$key\n";
	}
}
