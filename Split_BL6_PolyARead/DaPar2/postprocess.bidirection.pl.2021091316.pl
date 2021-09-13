#!/usr/bin/perl -w

use Statistics::Descriptive;

my ($PAS,$DB,$input,$polyASeqRCThreshold,$RNASeqRCThreshold,$usageThreshold) = @ARGV;

my %pas_pos;
open FILE,"$input";
while(<FILE>){
	my ($pas_id,$fit_value,$pas_type,$chr,$pos,$strand,$symbol,$usage) = split;
	$pas_pos{"$chr:$strand"}->{$pos} = $_;
}


my %nearest;
my %nearReal;
my $ground_truth = 0 ;
open FILE,"$PAS";
<FILE>;
my $previous = 0;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
	next if $polyASeqRC < $polyASeqRCThreshold;
	next if $RNASeqRC   < $RNASeqRCThreshold;
	next if $usage < $usageThreshold;
	if ($srd eq $SRD && $chr eq $CHR && $end>=$info{$baseName}->[0] && $end<=$info{$baseName}->[1]){
		$ground_truth++;
		$previous = $end;
		while(my($pos,$val) = each %pas_pos){
			if(!exists $nearest{$pos} || abs($pos-$end)<abs($nearest{$pos})){
				$nearest{$pos} = $pos-$end;
				$nearReal{$pos} = "GT.$chr:$end:$srd";
			}
		}
	}
}

my $near_num = keys %nearest;
my $pas_num = keys %pas_pos;
print "$near_num\t$pas_num\n";


my $RealNum25 = 0;
my $RealNum50 = 0;
my $RealNum100 = 0;
while(my($pas_id,$diff) = each %nearest){
	if(abs($diff)<100){
		$RealNum100++;
		if(abs($diff)<50){
			$RealNum50++;
			if(abs($diff)<25){
				$RealNum25++;
			}
		}
	}
}
$recall25 = $RealNum25/$ground_truth;
$recall50 = $RealNum50/$ground_truth;
$recall100 = $RealNum100/$ground_truth;


my %db;
my %db2;
open FILE,"$DB";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd) = split;
	if ($srd eq $SRD && $chr eq $CHR && $end>=$info{$baseName}->[0] && $end<=$info{$baseName}->[1]){
		while(my($pos,$val) = each %pas_pos){
			if( abs($pos-$end)<abs($nearest{$pos})){
				$nearest{$pos} = $pos-$end;
				$nearReal{$pos} = "DB.$chr:$end:$srd";
			}
			if(!exists $db2{$pos} ||  abs($pos-$end)<abs($db2{$pos})){
				$db{$pos} = "$chr:$end:$srd";
				$db2{$pos} = $pos-$end;
			}
		}
	}
}


my $precis25 = 0;
my $precis50 = 0;
my $precis100 = 0;

open OUT,">$OUT";
print OUT "predict_pos\tnearestPasID\tdiff\tchr\tstrand\tgt_pasid\tgt_diff\tdb_pasid\tdb_diff\tmaxPoint\n";
my @stat;
foreach my $key (sort{$a<=>$b} keys %nearReal){
	my $val = $nearReal{$key};
	my $diff = $nearest{$key};
	my $usage = exists $usage{$key} ? $usage{$key} : "None";
	my $usage2 = exists $usage2{$key} ? $usage2{$key} : "NaN";
	my $db = exists $db{$key} ? $db{$key} : "None";
	my $db2 = exists $db2{$key} ? $db2{$key} : "NaN";
	print OUT "$key\t$val\t$diff\t$CHR\t$SRD\t$usage\t$usage2\t$db\t$db2\t$pas_pos{$key}\n";
	if(abs($diff)<100){
		$precis100++;
		if(abs($diff)<50){
			$precis50++;
			if(abs($diff)<25){
				push @stat,$diff;
				$precis25++;
			}
		}
	}
}

