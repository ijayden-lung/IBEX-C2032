#!/usr/bin/perl -w
#
my $ground_truth = 20258;
my $apaiq_file = "../Figures/SNU398/predicted.txt";
my $aptardi_file = "../Figures/SNU398/predicted.aptardi.txt";
my $dapars2_file = "../Figures/SNU398/predicted.Dapar2.txt";
my $san_file = "../Figures/SNU398/predicted.SANPolyA.txt";
my %hash_readcount;
open OUT2,">ROC.compare.txt";
print OUT2 "dist\tprecision\tcell_line\n";
&statistics($apaiq_file,'APAIQ',12);
&statistics($aptardi_file,'aptardi',0.5);
&statistics($dapars2_file,'dapars2',100);
&statistics($san_file,'SANPolyA',12);
sub statistics{
	my ($file,$cell,$threshold) = @_;
	open FILE,"$file";
	<FILE>;
	<FILE>;
	my $total;
	my %dist;
	while(<FILE>){
		chomp;
		#my ($gt_diff,$score) = (split /\t/)[2,5];
		my ($diff,$score) = (split /\t/)[4,5];
		if($score < $threshold){
			next;
		}
		$total += 1;
		for(my $i=5;$i<=100;$i+=5){
			if(abs($diff)<=$i){
				$dist{$i} += 1;
			}
		}
	}
	for( my $i=5;$i<=100;$i+=5){
		my $precison = $dist{$i}/$total;
		print OUT2 "$i\t$precison\t$cell\n";
	}
}

