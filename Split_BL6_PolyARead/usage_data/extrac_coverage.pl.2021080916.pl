#!/usr/bin/perl -w

open FILE,"awk '(\$7>=0.05 && \$8>=1 && \$11>=0.05)' THLE2_Control.pAs.usage.txt |";
my %hash;
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	$hash{$pas_id} = '';
}

my $num = keys %hash;
print "$num\n";

open COV,"THLE2_Control.pAs.coverage.txt";
open OUT,">../Figures/THLE2_Control.pAs.coverage.txt";
while(<COV>){
	chomp;
	my ($pas_id) = split;
	if(exists $hash{$pas_id}){
		delete $hash{$pas_id};
		print OUT "$_\n";
	}
}

open COV,"THLE2_Control.pAs.gen.coverage.txt";
while(<COV>){
	chomp;
	my ($pas_id) = split;
	if(exists $hash{$pas_id}){
		print OUT "$_\n";
	}
}

