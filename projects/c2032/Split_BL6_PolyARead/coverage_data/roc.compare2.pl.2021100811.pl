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
#&statistics($aptardi_file,'aptardi',0.5);
#&statistics($dapars2_file,'dapars2',100);
#&statistics($san_file,'SANPolyA',12);
sub statistics{
	my ($file,$cell,$threshold) = @_;
	open FILE,"$file";
	<FILE>;
	<FILE>;
	my %total;
	my %correct;
	my %false;
	while(<FILE>){
		chomp;
		#my ($gt_diff,$score) = (split /\t/)[2,5];
		my ($diff,$score) = (split /\t/)[2,5];
		for(my $i=0;$i<=20;$i+=1){
			if($score>=$i){
				$total{$i} += 1;
				if(abs($diff)<=25){
					$correct{$i} += 1;
				}
				else{
					$false{$i} += 1;
				}
			}
		}
	}
	for( my $i=0;$i<=20;$i+=1){
		my $fdr = $false{$i}/$total{$i};
		my $tpr = $correct{$i}/$ground_truth;
		print OUT2 "$fdr\t$tpr\t$cell\n";
	}
}

