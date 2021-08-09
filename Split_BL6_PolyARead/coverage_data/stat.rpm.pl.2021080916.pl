#!/usr/bin/perl -w
#
my $thle_file = "THLE2_Control.usage.1.txt";
open OUT2,">../Figures/stat.rpm.txt";
print OUT2 "RPM\trecall\ttrue\ttotal\tcell_line\n";
my @thre = qw/1 3 5 9 18 27 36 45 54 63 72 81 90/;
my @rpm = qw/0.1 0.3 0.5 1 2 3 4 5 6 7 8 9 10/;
&statistics($thle_file,'THLE2',8.9);
sub statistics{
	my ($file,$cell,$times) = @_;
	my %polyA_total;
	foreach my $i (@thre){
		my $count =  &count_polyAread("../usage_data/THLE2_Control.pAs.usage.txt",$i);
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
