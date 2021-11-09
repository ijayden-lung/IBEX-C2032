#!/usr/bin/perl -w


sub Get_GT_Usage{
	my ($file) = @_;
	open FILE,"$file";
	<FILE>;
	my %hash;
	while(<FILE>){
		chomp;
		my ($pas_id,$pas_type,$symbol,$usage) = (split)[0,1,5,6];
		next if $pas_type ne "Extend";
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
		my ($pas_id,$pas_type,$symbol,$usage,$gt_pasid,$score) = (split)[0,1,5,6,-3,-1];
		next if $score < 12;
		next if $pas_type ne "Extend";
		$hash{$symbol}->{$gt_pasid} = $pas_id;
	}
	return \%hash;
}
my $thle2_ref = &Get_GT_Usage("../usage_data/THLE2_Control.pAs.usage.txt");
my $snu398_ref = &Get_GT_Usage("../usage_data/SNU398_Control.pAs.usage.txt");
my %thle2_hash = %$thle2_ref;
my %snu398_hash = %$snu398_ref;

my $thle2_pre_ref = &Get_Predict_Usage("../Figures/THLE2/new_pastype.predicted.txt");
my $snu398_pre_ref = &Get_Predict_Usage("../Figures/SNU398/new_pastype.predicted.txt");
my %thle2_pre = %$thle2_pre_ref;
my %snu398_pre = %$snu398_pre_ref;



while (my ($key,$val) = each %snu398_pre){
	foreach my $id (keys %$val){
		my $predict_id = $val->{$id};
		if(exists $snu398_hash{$key}->{$id}){
			if((!exists $thle2_hash{$key}->{$id}) && $snu398_hash{$key}->{$id}>0.3){
				print "$key\t$id\t$predict_id\n";
			}

		}
	}
}
