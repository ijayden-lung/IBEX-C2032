#!/usr/bin/perl -w
#
#
my $out = "bl6.pAs.usage.txt";
my $db = "/home/longy/workspace/apa_predict/pas_dataset/bl6.pAs.tianbin.txt";
open DB,$db;
<DB>;
my %ConserveOf;
while(<DB>){
	chomp;
	my ($pas_id,$conserve) = (split /\t/)[0,-1];
	$ConserveOf{$pas_id} = $conserve;
}



open FILE,"../polyA_seq/bl6_rep1.pAs.usage.txt";
my $header = <FILE>;
chomp $header;
open OUT,">$out";
print OUT "$header\tArich\tConservation\n";
my %dist;
my %readCount;
my %ave_diff;
my %pas_id;
my %remove_id;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$readCount,$motif,$ave_diff) = split;
	if(exists $dist{$symbol}){
		my $dist_diff = $pos - $dist{$symbol};
		if($dist_diff <= 50){
			#print "$pas_id\n" if $usage > 0.2;
		#if($dist_diff <= 50){
			if($readCount > $readCount{$symbol}){
				$remove_id{$pas_id{$symbol}} = '';
			}
			elsif($readCount == $readCount{$symbol}){
				if($ave_diff > $ave_diff{$symbol}){
					$remove_id{$pas_id{$symbol}} = '';
				}
				else{
					$remove_id{$pas_id} = '';
				}
			}
			else{
				$remove_id{$pas_id} = '';
			}
		}
	}
	$dist{$symbol} = $pos;
	$readCount{$symbol} = $readCount;
	$ave_diff{$symbol} = $ave_diff;
	$pas_id{$symbol} = $pas_id;
}


my %total;
open FILE,"../polyA_seq/bl6.pAs.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$readCount,$motif,$ave_diff) = split;
	if(!exists $remove_id{$pas_id}){
		$total{$symbol} += $readCount;
		if($readCount =~ /motif/){
			print "$_\n";
			last;
		}
	}
}



my %hasArich;
open FILE,"bl6.pAs.coverage.txt";
while(<FILE>){
	chomp;
	my ($pas_id,$sequence) = (split)[0,7];
	my $seq = substr($sequence,99,25);
	if($seq =~ /AAAAAA/){
		$hasArich{$pas_id} = "Arich";
	}
	else{
		 $hasArich{$pas_id} = "No";
	 }
 }


open FILE,"../polyA_seq/bl6.pAs.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my @data = split;
	if(!exists $remove_id{$data[0]}){
		$data[6] = $data[7]/$total{$data[5]};
		print OUT join("\t",@data,$hasArich{$data[0]},$ConserveOf{$data[0]}),"\n";
	}
}
