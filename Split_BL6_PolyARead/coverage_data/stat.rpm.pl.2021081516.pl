#!/usr/bin/perl -w
#
my $thle_file = "THLE2_Control.usage.1.txt";
my $k562_file = "K562_Chen.usage.txt";
my $snu398_file = "SNU398_Control.usage.txt";
my $hepg2_file = "HepG2_Control.usage.txt";
my $thle_file2 = "../usage_data/THLE2_Control.pAs.usage.txt";
my $k562_file2= "../usage_data/K562_Chen.pAs.usage.txt";
my $snu398_file2 = "../usage_data/SNU398_Control.pAs.usage.txt";
my $hepg2_file2 = "../usage_data/HepG2_Control.pAs.usage.txt";
open OUT2,">../Figures/stat.rpm.txt";
print OUT2 "RPM\trecall\ttrue\ttotal\tcell_line\n";
my @thle_thre = qw/0 1 3 4.5 9 18 27 36 44.5 53.5 62.5 71.5 80.5 89/;
my @k562_thre = qw/0 4 10 17 34 67 100 134 167 200 234 265 300 334/;
my @snu398_thre = qw/0 1 2.5 4 8 16 23.5 31.5 39 47 55 62.5 70.5 78/;
my @hepg2_thre = qw/0 1 2 3.5 6.5 12.5 19 25 31 37.5 43.5 50 56 62/;
my @rpm = qw/0 0.1 0.3 0.5 1 2 3 4 5 6 7 8 9 10/;
&statistics($thle_file,$thle_file2,'THLE2',\@thle_thre);
&statistics($k562_file,$k562_file2,'K562',\@k562_thre);
&statistics($snu398_file,$snu398_file2,'SNU398',\@snu398_thre);
&statistics($hepg2_file,$hepg2_file2,'HepG2',\@hepg2_thre);
sub statistics{
	my ($file,$file2,$cell,$thre_ref) = @_;
	my @thre = @$thre_ref;
	my %polyA_total;
	foreach my $i (@thre){
		my $count =  &count_polyAread($file2,$i);
		$polyA_total{$i} = $count;
	}
	my %polyA_correct;
	open FILE,"$file";
	<FILE>;
	my $total = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$is_ground_true,$nearest_pas,$symbol,$pas_type,undef,undef,$usage,$polyA_readcount) = split;
		next if $is_ground_true eq "False";
		$total++;
		my $predict_pos = (split /\:/,$pas_id)[1];
		my $true_pos    = (split /\:/,$nearest_pas)[1];
		my $diff = abs($predict_pos-$true_pos);
		my $nearest_pasid = $nearest_pas;
		if($nearest_pas =~ /\./){
			(undef,$nearest_pasid) = split /\./,$nearest_pas;
		}
		foreach my $i (@thre){
			if($polyA_readcount >=$i){
				$polyA_correct{$i}++;
			}
		}
	}
	for(my $i=0;$i<@thre;$i++){
		my $readcount = $thre[$i];
		my $rpm = $rpm[$i];
		my $total_number = $polyA_total{$readcount};
		my $true_number = $polyA_correct{$readcount};
		my $percent = $true_number/$total_number;
		print OUT2 "$rpm\t$percent\t$true_number\t$total_number\t$cell\n";
	}
}


sub count_polyAread{
	my ($file,$threshold) = @_;
	open FILE,"$file";   
	<FILE>;
	my $count = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		if($usage>=0.05 && $polyA_readcount>=$threshold && $rna_seq>=0.05){
			$count++;
		}
	}
	return $count;
}
