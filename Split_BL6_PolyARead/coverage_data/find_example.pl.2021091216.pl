#!/usr/bin/perl -w

#open FILE,"THLE2_Control.usage.txt";
open FILE,"../usage_data/THLE2_Control.pAs.usage.txt";
<FILE>;
my %thle2_hash;
while(<FILE>){
	chomp;
	#my ($pas_id,undef,$gt,$symbol,undef,undef,undef,$usage) = split;
	#$thle2_hash{$symbol}->{$gt} = $usage;
	my ($pas_id,$symbol,$usage) = (split)[0,5,6];
	$thle2_hash{$symbol}->{$pas_id} = $usage;

}

#open FILE,"SNU398_Control.usage.txt";
open FILE,"../usage_data/SNU398_Control.pAs.usage.txt";
<FILE>;
my %snu398_hash;
while(<FILE>){
	chomp;
	#my ($pas_id,undef,$gt,$symbol,undef,undef,undef,$usage) = split;
	#$snu398_hash{$symbol}->{$gt} = $usage;
	my ($pas_id,$symbol,$usage) = (split)[0,5,6];
	$snu398_hash{$symbol}->{$pas_id} = $usage;
}

while (my ($key,$val) = each %thle2_hash){
	my %val = %$val;
	my @keys = keys %val;
	if (@keys>1){
		my $id = pop(@keys);
		my $usage1 = $val->{$id};
		if($usage1>0.8 && !exists $snu398_hash{$key}->{$id}){
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
