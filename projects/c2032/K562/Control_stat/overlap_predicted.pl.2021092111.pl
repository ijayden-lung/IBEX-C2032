#!/usr/bin/perl -w

my $USAGE = "/home/longy/project/Split_BL6_PolyARead/usage_data/BL6.pAs.usage.txt";
my $COV = "/home/longy/project/Split_BL6_PolyARead/usage_data/BL6.pAs.coverage.txt";
my $RESULT = "bl6.pAs.single_kermax6.aug8_sc_p20r50_4-0067.12.1.results.txt";
my $OUT = "bl6.pAs.truePos.txt";
my $polyASeqRCThreshold = 20;
my $RNASeqRCThreshold = 50;

my %hash;
my %data_of;
open RES,"$RESULT";
while(<RES>){
	chomp;
	my ($predict_pasid,$motif,$chr,$predict_pos,$strand,$diff,$gt_pasid)  = split;
	$hash{$gt_pasid} = "$predict_pasid\t$diff\t$predict_pos";
	$data_of{$predict_pasid} = $motif;
}


open COV,"$COV";
<COV>;
open OUT,">$OUT";
my $predicted = 0;
my $total = 0;
while(<COV>){
	chomp;
	#my ($pas_id,$pas_type,$chr,$position,$strand,$symbol,$usage,$polReadCount,$motif,undef,$RNAReadCount,$biotype,undef,undef,undef,$Arich,$Conservation) = split /\t/;
	#next if $polReadCount < $polyASeqRCThreshold;
	my @data = split;
	my $pas_id = $data[0];
	my $pas_type = $data[1];
	my $chr = $data[2];
	my $pos = $data[3];
	my $strand = $data[4];
	my $symbol = $data[5];
	my $RNAReadCount = &TrimmedMean(@data[8..108]);
	next if $RNAReadCount < $RNASeqRCThreshold;
	$total++;
	if (exists $hash{$pas_id}){
		my ($predicted_pasid,$diff,$predict_pos) = split /\t/,$hash{$pas_id};
		if(abs($diff<25)){
			$predicted++;
			print OUT "$predicted_pasid\t$pas_type\t$chr\t$predict_pos\t$strand\t$symbol\t$pas_id\t$diff\n";
		}
	}
}


sub TrimmedMean{
	my @data = @_;
	my $sum = 0;
	my $count = 0;
	foreach my $ele (@data){
		if($ele>0){
			$sum += $ele;
			$count++;
		}
	}
	my $ave = $count>0 ? $sum/$count : 0;
	return $ave;
}
