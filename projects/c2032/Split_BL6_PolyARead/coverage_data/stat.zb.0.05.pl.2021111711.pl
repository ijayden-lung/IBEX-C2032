#!/usr/bin/perl -w

my $thle2_file = "THLE2_Control.usage.txt";
my $k562_file = "K562_Chen.usage.txt";
my $snu398_file = "SNU398_Control.usage.txt";
my $hepg2_file = "HepG2_Control.usage.txt";
my %hash_readcount;
&get_polyAread("../usage_data/thle2_control.pAs.usage.txt",'THLE2',1);
&get_polyAread("../usage_data/K562_Chen.pAs.usage.txt",'K562',3.5);
&get_polyAread("../usage_data/snu398_control.pAs.usage.txt",'SNU398',1);
&get_polyAread("../usage_data/HepG2_Control.pAs.usage.txt",'HepG2',1);
open OUT2,">../Figures/stat.dist.usage0.05.txt";
print OUT2 "dist\tprecision\ttrue\ttotal\tcell_line\n";
&statistics($thle2_file,'THLE2',1);
&statistics($k562_file,'K562',3.5);
&statistics($snu398_file,'SNU398',1);
&statistics($hepg2_file,'HepG2',1);
sub statistics{
	my ($file,$cell,$times) = @_;
	open FILE,"$file";
	<FILE>;
	my %polyA_total;
	my %dist_correct;
	my $total = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$is_ground_true,$gt_pas,$nearest_pas,$usage,$polyA_readcount) = split;
		$total++;
		my $predict_pos = (split /\:/,$pas_id)[1];
		#my $true_pos    = (split /\:/,$nearest_pas)[1];
		my $true_pos    = (split /\:/,$gt_pas)[1];
		my $diff = abs($predict_pos-$true_pos);
		my $nearest_pasid = $nearest_pas;
		if($nearest_pas =~ /\./){
			(undef,$nearest_pasid) = split /\./,$nearest_pas;
		}

		for (my $i=100;$i>=5;$i-=5){
			#next if ((!exists $hash_readcount{$cell}->{$nearest_pasid} || $hash_readcount{$cell}->{$nearest_pasid} < $times));
			next if ((!exists $hash_readcount{$cell}->{$gt_pas} || $hash_readcount{$cell}->{$gt_pas} < $times));
			if($diff <$i){
				$dist_correct{$i}++;
			}
			else{
				last;
			}
		}
	}
	for (my $i=1;$i<=20;$i++){
		my $dist = $i*5;
		my $dist_true_number = $dist_correct{$dist};
		my $dist_percent = $dist_true_number/$total;
		print OUT2 "$dist\t$dist_percent\t$dist_true_number\t$total\t$cell\n";
	}
}


sub get_polyAread{
	my ($file,$cell,$threshold) = @_;
	open FILE,"$file";   
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		next if $usage<0.05;
		next if $polyA_readcount < $threshold;
		next if $rna_seq < 0.05;
		$hash_readcount{$cell}->{$pas_id} = $polyA_readcount;
	}
}
