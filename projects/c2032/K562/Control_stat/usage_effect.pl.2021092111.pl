#!/usr/bin/perl -w

my $USAGE = "/home/longy/project/Split_BL6_PolyARead/usage_data/K562_Control.pAs.usage.txt";
my $RESULT = "hg38.pAs.control.txt";
my $OUT = "Stat.usage.recall.txt";
my $polyASeqRCThreshold = 20;
my $RNASeqRCThreshold = 50;

$usage_threhold = 0.2;

my %hash;
open RES,"$RESULT";
while(<RES>){
	chomp;
	my ($predict_pasid,$motif,$chr,$predict_pos,$strand,$diff,$gt_pasid)  = split;
	$hash{$gt_pasid} = $diff;
}


open USAGE,"$USAGE";
<USAGE>;
open OUT,">$OUT";
print OUT "pas_id\tdiff\tusage\tPredicted\n";


my $total = 0;
my $predicted = 0;

while(<USAGE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$position,$strand,$symbol,$usage,$polReadCount,$motif,undef,$RNAReadCount,$biotype,undef,undef,undef,$Arich,$Conservation) = split /\t/;
	next if $polReadCount < $polyASeqRCThreshold;
	next if $RNAReadCount < $RNASeqRCThreshold;
	if (exists $hash{$pas_id}){
		my $diff = $hash{$pas_id};
		if(abs($diff<25)){
			print OUT "$pas_id\t$diff\t$usage\tYes\n";
		}
		else{
			print OUT "$pas_id\t$diff\t$usage\tNo\n";
		}
	}
	else{
		print OUT "$pas_id\t10000000\t$usage\tNo\n";
	}

	if ($usage>$usage_threhold){
		$total++;
		if (exists $hash{$pas_id} && abs($hash{$pas_id})<25){
			$predicted++;
		}
	}
}


my $recall = sprintf("%.3f",$predicted/$total);
print "$recall\t$predicted\t$total\n";
