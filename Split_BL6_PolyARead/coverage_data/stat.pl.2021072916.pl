#!/usr/bin/perl -w
#

#my $hepg2_file = "all.hepg2_control.usage.txt";
#my $thle2_file = "all.thle2_control.usage.txt";
#my $snu398_file = "all.snu398_control.usage.txt";
#my $k562_file = "all.k562_chen.usage.txt";
#my $hepg2_file = "newall.hepg2_control.usage.txt";
my $thle2_file = "THLE2_Control.usage.txt";
my $thle22_file = "THLE2_Control.2usage.txt";
my $thle2s_file = "THLE2_Control.usage.12.txt";
my $thle25_file = "THLE2_Control.usage.0.01.txt";
#my $snu398_file = "newall.snu398_control.usage.txt";
#my $k562_file = "newall.k562_chen.usage.txt";


my %hash_readcount;
#&get_polyAread("../usage_data/hepg2_control.pAs.usage.txt",'hepg2');
#&get_polyAread("../usage_data/thle2_control.pAs.usage.txt",'thle2');
#&get_polyAread("../usage_data/snu398_control.pAs.usage.txt",'snu398');
#&get_polyAread("../usage_data/k562_chen.pAs.usage.txt",'k562');

my %hash_pas_type;
&get_pastype("/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt");

open OUT,">stat.polyArpm.txt";
print OUT "RPM\tprecision\ttrue\ttotal\tcell_line\n";
open OUT2,">stat.dist.txt";
print OUT2 "dist\tprecision\ttrue\ttotal\tcell_line\n";
my %near_no_polyA;
my %total_predict_true;
my @cells = ('snu398','k562','thle2','hepg2');
#&statistics($snu398_file,'snu398',0.78);
#&statistics($k562_file,'k562',3.33);
&statistics($thle2_file,'thle2',0.89);
&statistics($thle22_file,'thle22',0.89);
&statistics($thle2s_file,'thle2s',0.89);
&statistics($thle25_file,'thle25',0.89);
#&statistics($hepg2_file,'hepg2',0.62);

=pod
my $num = keys %total_predict_true;
while(my ($key,$val) =each %total_predict_true){
	print "$key";
	foreach my $cell (@cells){
		if(exists $val->{$cell}){
			print "\t$val->{$cell}";
		}
		else{
			print "\tNone";
		}
	}
	print "\n";
}
=cut



sub show_polyA_seq_could_not_detect{
	while(my ($key,$val) = each %near_no_polyA){
		my @data = @$val;
		my $num_less = 0;
		my $num_great = 0;
		foreach my $item (@data){
			my (undef,$polyA_readcount) = split /\t/,$item;
			if($polyA_readcount<1){
				$num_less++;
			}
			elsif($polyA_readcount>5){
				$num_great++;
			}
		}
		if($num_great>0 && $num_less>0){
			print join("\n",@data),"\n";
			print "---------break-----------\n";
		}
	}
}

sub statistics{
	my ($file,$cell,$times) = @_;
	open FILE,"$file";
	<FILE>;
	my %polyA_correct;
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
		if($diff <= 25){
			if($polyA_readcount/$times>=1){
				$total_predict_true{$symbol}->{$nearest_pasid}->{$cell} = $polyA_readcount;
			}
			if(exists $hash_pas_type{$nearest_pasid}){
				push @{$near_no_polyA{$nearest_pas}},"$cell\t$polyA_readcount\t$pas_id\t$nearest_pas\t$pas_type\t$hash_pas_type{$nearest_pasid}";
			}
			else{
				push @{$near_no_polyA{$nearest_pas}},"$cell\t$polyA_readcount\t$pas_id\t$nearest_pas\t$pas_type\n";
			}
		}
		for (my $i=100;$i>=5;$i-=5){
			#next if ((!exists $hash_readcount{$cell}->{$nearest_pasid} || $hash_readcount{$cell}->{$nearest_pasid}/$times<1) && $polyA_readcount/$times < 1);
			if($diff <=$i){
				$dist_correct{$i}++;
			}
			else{
				last;
			}

		}
		for (my $i=1;$i<=10;$i++){
			if($polyA_readcount/$times>=$i){
				$polyA_correct{$i}++;
			}
			else{
				last;
			}
		}
	}
	for (my $i=1;$i<=10;$i++){
		my $true_number = $polyA_correct{$i};
		my $percent = $true_number/$total;
		my $rpm = $i/10;
		print OUT "$rpm\t$percent\t$true_number\t$total\t$cell\n";
	}
	for (my $i=1;$i<=20;$i++){
		my $dist = $i*5;
		my $dist_true_number = $dist_correct{$dist};
		my $dist_percent = $dist_true_number/$total;
		print OUT2 "$dist\t$dist_percent\t$dist_true_number\t$total\t$cell\n";
	}
}

sub get_pastype{
	my ($file) = @_;
	open FILE,"$file";   
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$pas_type) = split;
		$hash_pas_type{$pas_id} = $pas_type;
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
