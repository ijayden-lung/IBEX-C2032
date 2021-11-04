#!/usr/bin/perl -w


sub Get_GT_Usage{
	my ($file) = @_;
	open FILE,"$file";
	<FILE>;
	my %hash;
	while(<FILE>){
		chomp;
		my ($pas_id,$pas_type,$symbol,$usage) = (split)[0,1,5,6];
		$hash{$symbol}->{$pas_id} = $usage;
	}
	return \%hash;
}
sub Get_Predict_Usage{
	my ($file) = @_;
	open FILE,"$file";
	<FILE>;
	my %hash;
	while(<FILE>){
		chomp;
		my ($pas_id,undef,$gt,$symbol,undef,undef,undef,$usage) = split;
		if ($gt =~ /DB/){
			$gt = (split /\./,$gt)[1];
		}
		$hash{$symbol}->{$gt} = $usage;
	}
	return \%hash;
}
my $thle2_ref = &Get_GT_Usage("../Figures/THLE2/new_pastype.groundtruth.txt");
my $snu398_ref = &Get_GT_Usage("../Figures/SNU398/new_pastype.groundtruth.txt");
my %thle2_hash = %$thle2_ref;
my %snu398_hash = %$snu398_ref;

my $thle2_pre_ref = &Get_Predict_Usage("../Figures/THLE2/new_pastype.predicted.txt");
my $snu398_pre_ref = &Get_Predict_Usage("../Figures/SNU398/new_pastype.predicted.txt");
my %thle2_pre = %$thle2_pre_ref;
my %snu398_pre = %$snu398_pre_ref;


while (my ($key,$val) = each %thle2_hash){
	my %val = %$val;
	my @keys = keys %val;
	if (@keys>1){
		my $id = pop(@keys);
		my $usage1 = $val->{$id};
		my $usage2 = 0;
		if(!exists $snu398_hash{$key}){
			next;
		}
		if(!exists $snu398_pre{$key}){
			next;
		}
		if(!exists $thle2_pre{$key}){
			next;
		}

		if(exists $snu398_hash{$key}->{$id}){
			$usage2 = $snu398_hash{$key}->{$id};
		}
		my $pre_usage1 = 0;
		my $pre_usage2 = 0;
		if(exists $thle2_pre{$key}->{$id}){
			$pre_usage1 = $thle2_pre{$key}->{$id};
		}
		if(exists $snu398_pre{$key}->{$id}){
			$pre_usage2 = $snu398_pre{$key}->{$id};
		}

		if(abs($usage1-$usage2)>0.5 && abs($pre_usage1-$pre_usage2)>0.5){
			print "$key\t$id\n";
		}
		#if (exists $snu398_hash{$key}->{$id}){
		#	my $val2 = $snu398_hash{$key};
		#	my @keys2 = keys %$val2;
		#	my $usage2 = $snu398_hash{$key}->{$id};
		#	if(@keys2>1 && abs($usage1-$usage2)>0.5){
		#		print "$key\t$id\n";
		#	}
		#}
	}
}
