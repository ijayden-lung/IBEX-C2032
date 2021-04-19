#!/usr/bin/perl -w


open FILE,"../Split_BL6/polyA_seq/HepG2_Control.pAs.usage.txt";
<FILE>;
open OUT,">Coor2.txt";
print OUT "pas_id\told_readCount\tnew_readCount\tlog10old_readCount\tlog10new_readCount\n";
my %hash;
while(<FILE>){
	chomp;
	my ($pas_id,$count) = (split /\t/)[0,7];
	$count *= 2;
	$hash{$pas_id} = $count;
}

open FILE,"../Split_BL6/polyA_seq/K562_Chen.pAs.usage.txt";
my $header = <FILE>;
open OUT2,>"../Split_BL6/polyA_seq/K562_Merge.pAs.usage.txt";
while(<FILE>){
	chomp;
	my ($pas_id,$count) = (split /\t/)[0,7];
	if (exists $hash{$pas_id}){
		my $logn = log($count)/log(10);
		my $logo = log($hash{$pas_id})/log(10);
		print OUT "$pas_id\t$hash{$pas_id}\t$count\t$logo\t$logn\n";
	}
}
