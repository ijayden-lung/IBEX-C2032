#!/usr/bin/perl -w

open FILE,"awk '(\$7>=0.05 && \$8>=4 && \$11>=0.05)' K562_Chen.pAs.usage.txt |";
my %hash;
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	$hash{$pas_id} = '';
}

my $num = keys %hash;
print "$num\n";

open COV,"K562_Chen.pAs.coverage.txt";
open OUT,">../Figures/K562/K562_Chen.pAs.coverage.txt";
while(<COV>){
	chomp;
	my ($pas_id) = split;
	if(exists $hash{$pas_id}){
		delete $hash{$pas_id};
		print OUT "$_\n";
	}
}

open COV,"K562_Chen.pAs.gen.coverage.txt";
while(<COV>){
	chomp;
	my ($pas_id) = split;
	if(exists $hash{$pas_id}){
		print OUT "$_\n";
	}
}

