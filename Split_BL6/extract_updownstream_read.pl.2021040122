#!/usr/bin/perl -w


my ($data,$WIG,$out,$polyASeqThreshod,$EXTEND,$SRD,$CHR) = @ARGV;
use List::Util qw(first max maxstr min minstr reduce shuffle sum shuffle) ;

open FILE,$WIG;
open OUT,">$out";
my %cov;
<FILE>;
while(<FILE>){
	chomp;
	my ($pos,$read) = split;
	$cov{$pos} = $read;
}

open DATA,"$data";
<DATA>;
my %gene;
while(<DATA>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$srd,$symbol,undef,$polyASeq,$result) = split;
	next if $chr ne $CHR;
	next if $srd ne $SRD;
	next if $polyASeq < $polyASeqThreshod;
	my ($gt_pas,$gt_diff) = split /,/,$result;
	#next if abs($gt_diff) > 25;
	$gene{$symbol}->{$pos} = [$pas_id,$pas_type,$chr,$pos,$srd,$symbol,$polyASeq];
}


while(my ($symbol,$val) = each %gene){
	my @POS = sort{$a<=>$b} keys %$val;
	for(my$i=0;$i<@POS;$i++){
		my $pos = $POS[$i];
		my @array = (0)x(2*$EXTEND+1);
		for(my$i=-$EXTEND;$i<=$EXTEND;$i++){
			$array[$i+$EXTEND] = $cov{$i+$pos} if exists $cov{$i+$pos};
		}
		if($SRD eq "-"){
			@array = reverse @array;
		}
		my $pas_data_ref = $val->{$pos};
		my @pas_data = @$pas_data_ref;
		print OUT join("\t",@pas_data,@array),"\n";
	}
}

