#!/usr/bin/perl -w

use Statistics::Descriptive;

my ($PAS,$DB,$input,$input2,$out,$polyASeqRCThreshold,$RNASeqRCThreshold,$usageThreshold) = @ARGV;

my %pvalue;
open FILE,"$input";
while(<FILE>){
	chomp;
	next if $_ =~ /temp/;
	my ($chr,$pos1,$pos2,undef,undef,$pval,$strand) = split;
	$pos = $pos1;
	my $pasid = "chr$chr:$pos:$strand";
	$pvalue{$pasid} = $pval;
	$pos = $pos2;
	$pasid = "chr$chr:$pos:$strand";
	$pvalue{$pasid} = $pval;
}

my $total = 0;
my %pas_pos;
open FILE,"$input2";
<FILE>;
while(<FILE>){
	chomp;
	next if $_ =~ /track/;
	my ($chr,$pos1,$pos2,$name,$usage,$strand) = split;
	my $pasid;
	if($strand eq "+"){
		$pos = $pos2;
		$pasid = "chr$chr:$pos:$strand";
		if(!exists $pvalue{$pasid}){
			$pos = $pos1;
		}
	}
	else{
		$pos = $pos1;
		$pasid = "chr$chr:$pos:$strand";
		if(!exists $pvalue{$pasid}){
			$pos = $pos2;
		}
	}
	$pasid = "chr$chr:$pos:$strand";
	next if $name =~ /TSS/;
	$pas_pos{"chr$chr:$strand"}->{$pos} = $pvalue{$pasid};
	$total++;
}

my %nearest;
my %nearReal;
my $ground_truth = 0 ;
open FILE,"$PAS";
<FILE>;
my $previous = 0;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$strand,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
	next if $polyASeqRC < $polyASeqRCThreshold;
	next if $RNASeqRC   < $RNASeqRCThreshold;
	next if $usage < $usageThreshold;
	my $predict_pas_ref = $pas_pos{"$chr:$strand"};
	$ground_truth++;
	$previous = $end;
	while(my($pos,$val) = each %$predict_pas_ref){
		if(!exists $nearest{"$chr:$strand"}->{$pos} || abs($pos-$end)<abs($nearest{"$chr:$strand"}->{$pos})){
			$nearest{"$chr:$strand"}->{$pos} = $pos-$end;
			$nearReal{"$chr:$strand"}->{$pos} = "$chr:$end:$strand";
		}
	}
}


my $RealNum25 = 0;
my $RealNum50 = 0;
my $RealNum100 = 0;
while(my($key,$val) = each %nearest){
	while(my($pos,$diff) = each %$val){
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
}
my $recall25 = $RealNum25/$ground_truth;
my $recall50 = $RealNum50/$ground_truth;
my $recall100 = $RealNum100/$ground_truth;
print "$recall25,$RealNum25\t$recall100,$RealNum100\t$ground_truth\n";


my %db;
my %db2;
open FILE,"$DB";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$strand) = split;
	my $predict_pas_ref = $pas_pos{"$chr:$strand"};
	while(my($pos,$val) = each %$predict_pas_ref){
		if(!exists $db2{"$chr:$strand"}->{$pos} ||  abs($pos-$end)<abs($db2{"$chr:$strand"}->{$pos})){
			$db{"$chr:$strand"}->{$pos} = "$chr:$end:$strand";
			$db2{"$chr:$strand"}->{$pos} = $pos-$end;
		}
	}
}


my $precis25 = 0;
my $precis50 = 0;
my $precis100 = 0;

open OUT,">$out";
my (undef,undef,$cell) = split /\//,$out;
my $gt_num = &get_gt_num($cell);
print OUT "# number of gournd truth pas: $gt_num\n";
print OUT "predict_pasid\tgt_pasid\tgt_diff\tdb_pasid\tdb_diff\tpvalue\n";
my @stat;
foreach my $key (sort{$a cmp $b} keys %nearReal){
	my $val = $nearReal{$key};
	foreach my $pos (sort{$a<=>$b} keys %$val){
		my $pas  = $nearReal{$key}->{$pos};
		my $diff = $nearest{$key}->{$pos};
		my $db_pas = $db{$key}->{$pos};
		my $db_diff = $db2{$key}->{$pos};
		my $score = $pas_pos{$key}->{$pos};
		my ($chr,$srd) = split /:/,$key;
		my $pas_id = "$chr:$pos:$srd";
		print OUT "$pas_id\t$pas\t$diff\t$db_pas\t$db_diff\t$score\n";
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
}
my $percent25 = $precis25/$total;
my $percent50 = $precis50/$total;
my $percent100 = $precis100/$total;
print "$percent25,$precis25,$percent100,$precis100\t$total\n";
sub get_gt_num{
	my ($cell) = @_;
	if($cell eq "THLE2"){
		return 20258;
	}
	elsif($cell eq "SNU398"){
		return 20990;
	}
	elsif($cell eq "HepG2"){
		return 20329;
	}
	elsif($cell eq "K562"){
		return 19946
	}
	else{
		print "cell line not exists\n";
		return 0;
	}
}
