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
	while(<FILE>){
		chomp;
		my ($pas_id,$is_true,$near_pas,$symbol,$pas_type) = split /\t/;
		next if $pas_type ne "LE";
		if($near_pas =~ /DB/){
			$near_pas = substr($near_pas,3);
		}
		my (undef,$near_pos) = split /\:/,$near_pas;
		my (undef,$pos) = split /\:/,$pas_id;
		my $diff = abs($near_pos-$pos);
		if($diff < 100){
			$is_true = "True";
		}
		if($type eq "apaiq"){
			if(!exists $hash{$symbol}){
				$hash{$symbol} = $is_true;
			}
			elsif($is_true eq "False"){
				$hash{$symbol} = $is_true;
			}
		}
		else{
			if($is_true eq "False"){
				$hash{$symbol} = $pas_id;
			}
		}
	}
	return \%hash;
}


#my $usage_ref = &Get_GT_Usage("../usage_data/SNU398_Control.pAs.coverage.txt");
#my %usage_hash = %$usage_ref;

my $dna_pre_ref = &Get_Predict_Usage("SNU398_Control.usage.RNASeq.txt","dna");
my %dna_pre = %$dna_pre_ref;
my $combine_pre_ref = &Get_Predict_Usage("SNU398_Control.usage.txt","apaiq");
my %combine_pre = %$combine_pre_ref;

while (my ($key,$val) = each %dna_pre){
	if(exists $combine_pre{$key} && $combine_pre{$key} eq "True"){
		print "$key\t$val\n";
	}
}
