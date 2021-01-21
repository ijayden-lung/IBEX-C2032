#!/usr/bin/perl -w

my $USAGE = "/home/longy/project/Split_BL6_PolyARead/usage_data/K562_Control.pAs.usage.txt";
my $RESULT = "hg38.pAs.control.txt";
my $OUT = "Stat.conserved.diff.txt";
my $polyASeqRCThreshold = 20;
my $RNASeqRCThreshold = 50;


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
print OUT "pas_id\tdiff\tConserved\tPredicted\n";

my $cp = 0;
my $np = 0;
my $cn = 0;
my $nn = 0;
my $predicted = 0;
my $total = 0;
my $conserved  = 0;
while(<USAGE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$position,$strand,$symbol,$usage,$polReadCount,$motif,undef,$RNAReadCount,$biotype,undef,undef,undef,$Arich,$Conservation) = split /\t/;
	next if $polReadCount < $polyASeqRCThreshold;
	next if $RNAReadCount < $RNASeqRCThreshold;
	$total++;
	if (exists $hash{$pas_id}){
		my $diff = $hash{$pas_id};
		if(abs($diff<25)){
			$predicted++;
			print OUT "$pas_id\t$diff\t$Conservation\tYes\n";
			if($Conservation eq "Yes"){
				$cp++;
				$conserved++
			}
			else{
				$np++;
			}
		}
		else{
			print OUT "$pas_id\t$diff\t$Conservation\tNo\n";
			if($Conservation eq "Yes"){
				$cn++;
				$conserved++
			}
			else{
				$nn++;
			}
		}
	}
	else{
		if($Conservation eq "Yes"){
			$cn++;
			$conserved++
		}
		else{
			$nn++;
		}
	}
}

my $not_predicted = $total-$predicted;
my $not_conserved = $total-$conserved;
print "$cp\t$np\t$predicted\n";
print "$cn\t$nn\t$not_predicted\n";
print "$conserved\t$not_conserved\t$total\n";
