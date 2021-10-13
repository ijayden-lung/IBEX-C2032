#!/usr/bin/perl -w

#open FILE,"THLE2_Control.usage.txt";

sub Get_GT_Usage{
	my ($file) = @_;
	open FILE,"$file";
	<FILE>;
	my %hash;
	while(<FILE>){
		chomp;
		my ($pas_id,$pas_type,$symbol,$usage) = (split)[0,1,5,6];
		my ($chr,$pos,$strand) = split /\:/,$pas_id;
		$hash{"$chr:$strand"}->{$pos} = $pas_type;
	}
	return \%hash;
}

sub Get_Predict_Usage{
	my ($file,$type) = @_;
	open FILE,"$file";
	<FILE>;
	<FILE>;
	my %hash;
	my %pas2gene;
	my %symbolTrue;
	while(<FILE>){
		chomp;
		if($type eq "apaiq"){
			my ($pas_id,$is_true,$near_pas,$symbol,$pas_type) = split /\t/;
			if($near_pas =~ /DB/ || $near_pas =~ /GT/){
				$near_pas = substr($near_pas,3);
			}
			my (undef,$near_pos) = split /\:/,$near_pas;
			my (undef,$pos) = split /\:/,$pas_id;
			my $diff = abs($near_pos-$pos);
			#if($diff < 100){
			#	$is_true = "True";
			#}
			my $gt_id = $near_pas;
			$pas2gene{$gt_id} = $symbol;
			if(!exists $symbolTrue{$symbol} || $is_true eq "False"){
				$symbolTrue{$symbol} = $is_true;
			}
		}
		else{
			my ($pas_id,$gt_id,$gt_diff,$db_id,$db_diff,$score) = split;
			if(abs($gt_diff)<200){
				$hash{$gt_id} = $score;
			}
			if(abs($db_diff)<200){
				$hash{$db_id} = $score;
			}
		}
	}
	if($type eq "apaiq"){
		while(my ($gt_id,$symbol) = each %pas2gene){
			$hash{$gt_id} = $symbolTrue{$symbol};
		}
	}
	return \%hash;
}


#my $usage_ref = &Get_GT_Usage("../usage_data/SNU398_Control.pAs.coverage.txt");
#my %usage_hash = %$usage_ref;

my $dna_pre_ref = &Get_Predict_Usage("../Figures/SNU398/predicted.sequence.txt","dna");
my $rna_pre_ref = &Get_Predict_Usage("../Figures/SNU398/predicted.RNASeq.txt","rna");
my $combine_pre_ref = &Get_Predict_Usage("SNU398_Control.usage.txt","apaiq");

#print "$rna_pre_ref->{'chr19:35904271:+'}\n";

while (my ($key,$val) = each %$combine_pre_ref){
	next if $val eq "False";
	if(!exists $dna_pre_ref->{$key} && !exists $rna_pre_ref->{$key}){
		print "$key\n";
	}
}
