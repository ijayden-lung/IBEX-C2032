#!/usr/bin/perl -w
#
use Statistics::Descriptive;
#2021/01/24 Fixed bugs. usage files should be sorted.
my $dist_threshold = 49;
my $length = 201;

=pod
my $usage = "../../Split_BL6/polyA_seq/bl6_rep1.pAs.usage.txt";
my $out = "bl6_rep1.pAs.usage.txt";
my $db = "/home/longy/workspace/apa_predict/pas_dataset/bl6.pAs.tianbin.txt";
my $COV = "bl6_rep1.pAs.merge.coverage.txt";
=cut
#=pod
my $COV = "K562_Chen.pAs.coverage.txt";
my $COV2 = "K562_Chen.pAs.gen.coverage.txt";
#my $usage = "/home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.usage.txt";
#my $out = "K562_Chen.pAs.usage.txt";
my $usage = "K562_Chen.pAs.usage.txt";
my $out  = "test";
my $db = "/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt";
#=cut

open DB,$db;
<DB>;
my %ConserveOf;
while(<DB>){
	chomp;
	my ($pas_id,$conserve) = (split /\t/)[0,-1];
	$ConserveOf{$pas_id} = $conserve;
}

my %hasArich;
my %coverage1;
my %coverage2;
&Arich($COV);
&Arich($COV2);
#&Arich($COV3);

sub Arich{
	my ($COV) = @_;
	open FILE,$COV;
	while(<FILE>){
		chomp;
		my ($pas_id,$sequence) = (split)[0,7];
		my $seq = substr($sequence,int(length($sequence)/2),25);
		if($seq =~ /AAAAAAAAAA/){
			$hasArich{$pas_id} = "Arich";
		}
		else{
			my $count = 0;
			for(my$i=0;$i<length($seq);$i++){
				if(substr($seq,$i,1) eq "A"){
					$count++;
				}
			}
			if($count > 20){
				$hasArich{$pas_id} = "Yes";
			}
			else{
				$hasArich{$pas_id} = "No";
			}
		}
		my @data = split;
		my $half = int($length/2);
		my @data1 = @data[8..8+$half];
		my @data2 = @data[9+$half..$#data];
		$coverage1{$pas_id} = \@data1;
		$coverage2{$pas_id} = \@data2;
	}
}

sub mse{
	my ($data1_ref,$data2_ref) = @_;
	my @data1 = @$data1_ref;
	my @data2 = @$data2_ref;
	my $stat1 = Statistics::Descriptive::Full->new();
	my $stat2 = Statistics::Descriptive::Full->new();
	my $stat = Statistics::Descriptive::Full->new();
	$stat1->add_data(@data1);
	$stat2->add_data(@data2);
	push @data1,@data2;
	$stat->add_data(@data1);
	my $sd1 = $stat1->standard_deviation();
	my $sd2 = $stat2->standard_deviation();
	my $sd = $stat->standard_deviation();
	my $sd_ratio = ($sd1+$sd2)/$sd;
	return $sd_ratio;
}

open FILE,"sort -k 3,3 -k 5,5 -k 4,4n $usage |";
my $header = <FILE>;
chomp $header;
my @USAGE = <FILE>;
open OUT,">$out";
print OUT "$header\tArich\tConservation\n";
my %dist;
my %readCount;
my %Motif;
my %ave_diff;
my %pas_id;
my %remove_id;
foreach(@USAGE){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$readCount,$motif,$ave_diff,$ur,$biotype) = split;
	#next if ! exists $ConserveOf{$pas_id} && $ave_diff<1;
	if(exists $dist{$symbol}){
		my $dist_diff = abs($pos - $dist{$symbol});
		if($dist_diff <= $dist_threshold){
			my $pas_id2 = $pas_id{$symbol};
			my $readCount2 = $readCount{$symbol};
			my $motif2 = $Motif{$symbol};
			my $mse1 = &mse($coverage1{$pas_id},$coverage2{$pas_id});
			my $mse2 = &mse($coverage1{$pas_id2},$coverage2{$pas_id2});
			my (undef,$motif_num1) = split /\=/,$motif;
			my (undef,$motif_num2) = split /\=/,$motif2;
			my $win1 = $readCount+$motif_num1;
			my $win2 = $readCount2+$motif_num2;
			if($mse1 > $mse2){
				$win2++;
			}
			elsif($mse1 < $mse2){
				$win1++;
			}
			my $remove = '';
			if($win1>$win2){
				$remove = $pas_id2;
			}
			elsif($win2>$win1){
				$remove = $pas_id;
			}
			elsif($readCount>$readCount2){
				$remove = $pas_id2;
			}
			else{
				$remove = $pas_id;
			}
			$remove_id{$remove} = '';

			#printf("%d\t%s,%.1f,%.3f\t%s,%.1f,%.3f\n",$dist_diff,$pas_id,$readCount,$mse1,$pas_id2,$readCount2,$mse2);
			my $remove_old = '';
			if($readCount > $readCount{$symbol}){
				#$remove_id{$pas_id{$symbol}} = '';
				$remove_old = $pas_id2;
			}
			elsif($readCount == $readCount{$symbol}){
				if($ave_diff >= $ave_diff{$symbol}){
					#$remove_id{$pas_id{$symbol}} = '';
					$remove_old = $pas_id2;
				}
				else{
					#$remove_id{$pas_id} = '';
					$remove_old = $pas_id;
				}
			}
			else{
				#remove_id{$pas_id} = '';
				$remove_old = $pas_id;
			}
			if($remove_old ne $remove){
				printf("%d\tremove %s\t%s,%.1f,%.3f\t%s,%.1f,%.3f\n",$dist_diff,$remove,$pas_id,$readCount,$mse1,$pas_id2,$readCount2,$mse2);
			}

		}
	}
	$dist{$symbol} = $pos;
	$readCount{$symbol} = $readCount;
	$ave_diff{$symbol} = $ave_diff;
	$pas_id{$symbol} = $pas_id;
	$Motif{$symbol}  = $motif;
}


my %total;
foreach(@USAGE){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$readCount,$motif,$ave_diff) = split;
	#next if $hasArich{$pas_id} ne "No" && $ave_diff<1;
	#next if ! exists $ConserveOf{$pas_id} && $ave_diff<1;
	if(!exists $remove_id{$pas_id}){
		$total{$symbol} += $readCount;
	}
}


my $remove_num = keys %remove_id;
print "$remove_num\n";

foreach(@USAGE){
	chomp;
	my @data = split;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$readCount,$motif,$ave_diff) = split;
	#next if ! exists $ConserveOf{$pas_id} && $ave_diff<1;
	if(!exists $remove_id{$data[0]}){
		$data[6] = 0;
		if(exists $total{$data[5]} && $total{$data[5]}>0){
			$data[6] = $data[7]/$total{$data[5]};
		}
		if($data[1] eq "intergenic"){
			#$data[7] /= 5;
			if($data[14] =~ "Diff"){
				$data[7] /= 2;
			}
			else{
				$data[7] /=3;
			}
		}
		elsif($data[1] eq "ncRNA"){
			$data[7] /= 2;
		}
		#print OUT join("\t",@data,$hasArich{$data[0]},$ConserveOf{$data[0]}),"\n";
		if(exists $ConserveOf{$data[0]}){
			print OUT join("\t",@data,$hasArich{$data[0]},"DB"),"\n";
		}
		else{
			print OUT join("\t",@data,$hasArich{$data[0]},"ENS"),"\n";
		}

	}
}
