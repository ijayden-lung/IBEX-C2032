#!/usr/bin/perl -w

open FILE,"THLE2_Control.usage.txt";
<FILE>;
my %thle2_hash;
while(<FILE>){
	chomp;
	my ($pas_id,undef,$gt,$symbol,undef,undef,undef,$usage) = split;
	$thle2_hash{$symbol}->{$gt} = $usage;
}

open FILE,"SNU398_Control.usage.txt";
<FILE>;
my %snu398_hash;
while(<FILE>){
	chomp;
	my ($pas_id,undef,$gt,$symbol,undef,undef,undef,$usage) = split;
	$snu398_hash{$symbol}->{$gt} = $usage;
}

while (my ($key,$val) = each %thle2_hash){
	my %val = %$val;
	my @keys = keys %val;
	if (@keys>1){
		my $id = pop(@keys);
		my $usage1 = $val->{$id};
		if (exists $snu398_hash{$key}->{$id}){
			my $val2 = $snu398_hash{$key};
			my @keys2 = keys %$val2;
			my $usage2 = $snu398_hash{$key}->{$id};
			if(@keys2>1 && abs($usage1-$usage2)>0.5){
				print "$key\t$id\n";
			}
		}
	}
}
