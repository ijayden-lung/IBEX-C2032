#!/usr/bin/perl -w
use AddPas;
my $thle2_file = "THLE2_Control.usage.txt";
my $k562_file = "K562_Chen.usage.txt";
my $snu398_file = "SNU398_Control.usage.txt";
my $hepg2_file = "HepG2_Control.usage.txt";
my $thle2_file2 = "../usage_data/thle2_control.pAs.usage.txt";
my $k562_file2= "../usage_data/K562_Chen.pAs.usage.txt";
my $snu398_file2 = "../usage_data/snu398_control.pAs.usage.txt";
my $hepg2_file2 = "../usage_data/HepG2_Control.pAs.usage.txt";
open OUT2,">../Figures/stat.dist.usage0.05.txt";
#open OUT2,">../Figures/stat.dist.txt";
print OUT2 "dist\tprecision\ttrue\ttotal\tcell_line\n";
&statistics($thle2_file,$thle2_file2,'THLE2',1);
&statistics($k562_file,$k562_file2,'K562',3.5);
&statistics($snu398_file,$snu398_file2,'SNU398',1);
&statistics($hepg2_file,$hepg2_file2,'HepG2',1);
sub statistics{
	my ($file,$file2,$cell,$times) = @_;
	open FILE,"$file";
	<FILE>;
	my %polyA_total;
	my %dist_correct;
	my $total = 0;
	my $all_pas_ref = &add_pas($file2);
	my $hash_readcount_ref = &count_polyAread($file2,$times,$all_pas_ref);
	my %hash_readcount = %$hash_readcount_ref;
	#my $hash_readcount = &get_polyAread("../../Split_BL6/polyA_seq/thle2_control.pAs.usage.txt");
	while(<FILE>){
		chomp;
		my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$is_ground_true,$gt_pas,$nearest_pas,$usage,$polyA_readcount) = split;
		$total++;
		my $predict_pos = (split /\:/,$pas_id)[1];
		my $true_pos    = (split /\:/,$nearest_pas)[1];
		my $diff = abs($predict_pos-$true_pos);
		my $nearest_pasid = $nearest_pas;
		if($nearest_pas =~ /\./){
			(undef,$nearest_pasid) = split /\./,$nearest_pas;
		}

		for (my $i=100;$i>=5;$i-=5){
			next if ((!exists $hash_readcount{$nearest_pasid} || $hash_readcount{$nearest_pasid} < $times));
			if($diff <$i){
				print "$nearest_pasid\n";
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
		my ($pas_id,$usage,$polyA_readcount) = (split)[0,6,7];
		next if $polyA_readcount <=0;
		#$hash_readcount{$cell}->{$pas_id} = $polyA_readcount;
	}

}
sub count_polyAread{
	my %gt_readcount;
	my ($file,$threshold,$all_pas_ref) = @_;
	open FILE,"$file";   
	<FILE>;
	my $count = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		if($polyA_readcount>=$threshold){
			$count++;
			$gt_readcount{$pas_id} = $polyA_readcount;
			my $close_pas_ref = $all_pas_ref->{$pas_id};
			foreach my $pas_id2 (keys %$close_pas_ref){
				$gt_readcount{$pas_id2} = $polyA_readcount;
			}
		}
	}
	return \%gt_readcount;
}


sub add_pas2{
	my ($file,$file2) = @_;
	my %db;
	my %hash;
	
	print "$file2\n";
	open FILE,"$file2";
	while(<FILE>){
		chomp;
		my ($id,undef,$chr,$pos,$strand) = split;
		$db{"$chr:$strand"}->{$pos} = '';
	}

	open FILE,"$file";   
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		if($rna_seq>=0.05){
			my ($chr,$pos,$strand) = split /\:/,$pas_id;
			my $db_ref = $db{"$chr:$strand"};
			foreach my $key (keys %$db_ref){
				if(abs($key-$pos)<49){
					my $new_pasid = "$chr:$key:$strand";
					$hash{$pas_id}->{$new_pasid} = $polyA_readcount;
				}
			}
		}
	}
	return \%hash;
}
