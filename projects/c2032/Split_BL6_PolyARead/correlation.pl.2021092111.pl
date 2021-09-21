#!/usr/bin/perl -w

#open FILE,"/home/longy/project/Split_BL6/STAR/HepG2_Control/count";
open FILE,"/home/longy/project/Split_BL6/STAR/K562_Chen/count";
<FILE>;
<FILE>;

open OUT,">Coor.txt";
print OUT "ENS\tPolyASeq_ReadCount\tRNASeq_ReadCount\tlog10PolyASeq_ReadCount\tlog10RNASeq_ReadCount\n";
my %hash;
while(<FILE>){
	chomp;
	my ($ens,$count) = (split /\t/)[0,-1];
	$hash{$ens} = $count;
}

#open FILE,"/home/longy/project/HepG2/count";
open FILE,"/home/longy/project/Split_BL6/polyA_seq/count";
<FILE>;
<FILE>;
while(<FILE>){
	chomp;
	my ($ens,$count) = (split /\t/)[0,-1];
	if ($hash{$ens}>0  && $count>0){
		my $logp = log($count)/log(10);
		my $logr = log($hash{$ens})/log(10);
		print OUT "$ens\t$count\t$hash{$ens}\t$logp\t$logr\n";
	}
}
