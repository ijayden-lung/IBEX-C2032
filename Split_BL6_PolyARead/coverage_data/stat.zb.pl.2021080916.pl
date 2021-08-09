#!/usr/bin/perl -w
#
my $thle25_file = "THLE2_Control.usage.1.txt";
my %hash_readcount;
&get_polyAread("../../Split_BL6/polyA_seq/THLE2_Control.pAs.usage.txt",'THLE2');
open OUT2,">../Figures/stat.dist.txt";
print OUT2 "dist\tprecision\ttrue\ttotal\tcell_line\n";
my %near_no_polyA;
&statistics($thle25_file,'THLE2',8.9);
sub statistics{
	my ($file,$cell,$times) = @_;
	open FILE,"$file";
	<FILE>;
	my %polyA_total;
	my %dist_correct;
	my $total = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$is_ground_true,$nearest_pas,$symbol,$pas_type,undef,undef,$usage,$polyA_readcount) = split;
		$total++;
		my $predict_pos = (split /\:/,$pas_id)[1];
		my $true_pos    = (split /\:/,$nearest_pas)[1];
		my $diff = abs($predict_pos-$true_pos);
		my $nearest_pasid = $nearest_pas;
		if($nearest_pas =~ /\./){
			(undef,$nearest_pasid) = split /\./,$nearest_pas;
		}

		for (my $i=100;$i>=5;$i-=5){
			next if ((!exists $hash_readcount{$cell}->{$nearest_pasid} || $hash_readcount{$cell}->{$nearest_pasid}/$times<0.1) && $polyA_readcount/$times < 0.1);
			if($diff <=$i){
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
	my ($file,$cell) = @_;
	open FILE,"$file";   
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$polyA_readcount) = (split)[0,7];
		$hash_readcount{$cell}->{$pas_id} = $polyA_readcount;
	}
}
