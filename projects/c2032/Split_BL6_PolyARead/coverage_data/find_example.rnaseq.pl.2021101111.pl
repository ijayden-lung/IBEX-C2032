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
			my ($chr,$pos,$strand) = split /\:/,$pas_id;
			$hash{"$chr:$strand"}->{$pos} = abs($gt_diff);
		}
		else{
			if($score>12 && abs($db_diff)>50){
				my ($chr,$pos,$strand) = split /\:/,$pas_id;
				$hash{"$chr:$strand"}->{$pos} = abs($gt_diff);
			}
		}
	}
	return \%hash;
}


my $usage_ref = &Get_GT_Usage("../usage_data/SNU398_Control.pAs.usage.txt");
my %usage_hash = %$usage_ref;

my $dna_pre_ref = &Get_Predict_Usage("../Figures/SNU398/predicted.RNASeq.txt","dna");
my %dna_pre = %$dna_pre_ref;
my $combine_pre_ref = &Get_Predict_Usage("../Figures/SNU398/predicted.txt","apaiq");
my %combine_pre = %$combine_pre_ref;

while (my ($key,$val) = each %dna_pre){
	foreach my $pos (keys  %$val){
		my $val2 = $combine_pre{$key};
		my $near = 1000;
		foreach my $pos2 (keys %$val2){
			if(abs($pos-$pos2)<$near){
				$near = abs($pos-$pos2);
			}
		}
		if($near > 50){
			print "$key:$pos\n";
		}
	}

}
