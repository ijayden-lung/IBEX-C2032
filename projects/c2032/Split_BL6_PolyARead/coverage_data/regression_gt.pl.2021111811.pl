#!/usr/bin/perl -w

my %hash;
open FILE,"../usage_data/K562_Chen.pAs.usage.txt" ;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$read) = split;
	$hash{$pas_id} = [$read,$symbol];
}

open FILE,"K562_Chen.pAs.coverage.txt";
open OUT,">K562.predicted.txt";
print OUT "pas_id\n";
while(<FILE>){
	chomp;
	my @data = split;
	if($data[1] eq "True"){
		my $read = $hash{$data[5]}->[0];
		my $symbol = $hash{$data[5]}->[1];
		my @cov = @data[6..$#data];
		print OUT "$data[0]\t$data[1]\t$data[2]\t$data[3]\t$data[4]\t$data[5]\t$symbol\t.\t$read\t";
		print OUT join("\t",@cov),"\n";
	}
}

