#!/usr/bin/perl -w

my ($input,$PAS) = @ARGV;
my $usageThreshold = -1;
my $polyASeqRCThreshold = -1;
my $RNASeqRCThreshold = 0;

my %PAS_pos;
open FILE,$input;
#<FILE>;
my $total=0;
while(<FILE>){
	my ($chr,$strand,$pos1,$pos) = (split /\t/)[0,5,6,7];
	if($chr =~ /MT|Y|GL|KI/){
		next;
	}
	#my ($pas_id) = split /\t/;
	$chr = "chr$chr";
	$total++;
	#my ($chr,$pos,$strand) = split /\:/,$pas_id;
	$PAS_pos{"$chr:$strand"}->{$pos} = '';
}

my %nearest;
my %nearReal;
my $ground_truth = 0 ;
open FILE,"$PAS";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
	#next if $polyASeqRC <= $polyASeqRCThreshold;
	#next if $RNASeqRC   <=  $RNASeqRCThreshold;
	#next if $usage <= $usageThreshold;
	$ground_truth++;
	$POS = $PAS_pos{"$chr:$srd"};
	while(my($pos,$val) = each %$POS){
		if(!exists $nearest{$pos} || abs($pos-$end)<abs($nearest{$pos})){
			$nearest{$pos} = $pos-$end;
			$nearReal{$pos} = "$pas_id";
		}
	}
}

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
print  "ground truth in\t$RealNum25\t$RealNum50\t$RealNum100\t$ground_truth\n";
print "recall\t$recall25\t$recall50\t$recall100\n";

my $percent25 = $RealNum25/$total;
my $percent50 = $RealNum50/$total;
my $percent100 = $RealNum100/$total;
print "Num\t$RealNum25\t$RealNum50\t$RealNum100\t$total\n";
print "Percentage\t$percent25\t$percent50\t$percent100\n";
