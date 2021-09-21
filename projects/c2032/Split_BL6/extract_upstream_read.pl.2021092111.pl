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
		####determine the border, min(extend,next_pos,sigularity)
		my $pos = $POS[$i];
		my $first_extend = $EXTEND;
		if($i>0){
			$first_extend = $pos-$POS[$i-1] if  ($pos-$POS[$i-1])<$first_extend;
		}
		my @pre_array = (0)x($first_extend);
		for(my$i=0;$i<$first_extend;$i++){
			if(exists $cov{$i+$pos-$first_extend}){
				$pre_array[$i] = $cov{$i+$pos-$first_extend};
			}
		}
		my ($first_quant,$first_min,$first_min_idx,$first_max,$first_max_idx) = &calculate_first(@pre_array);

		my $last_extend = $EXTEND;
		if($i<$#POS){
			$last_extend = $POS[$i+1]-$pos if ($POS[$i+1]-$pos)<$last_extend;
		}
		my @suf_array = (0)x($last_extend);
		for(my$i=0;$i<$last_extend;$i++){
			if(exists $cov{$i+$pos}){
				$suf_array[$i] = $cov{$i+$pos};
			}
		}
		my ($last_quant,$last_min,$last_min_idx,$last_max,$last_max_idx)  = &calculate_last(@suf_array);

		my $quant = $first_quant-$last_quant;
		if($last_extend<$EXTEND && (($last_max_idx<10 && $SRD eq "+") ||($last_max_idx>$#suf_array-10 && $SRD eq "-") )){
			#if($last_extend<$EXTEND){
			$last_quant = $last_max; 
			$quant = $first_quant - 1*$last_quant;
		}
		if($first_extend<$EXTEND && (($first_max_idx<10 && $SRD eq "+") ||($first_max_idx>$#pre_array-10 && $SRD eq "-") )){
		#if($first_extend<$EXTEND){
			$first_quant = $first_max; 
			$quant = 1*$first_quant - $last_quant;
		}

		$quant = -$quant if $SRD eq "-";
		#my $quant = $first_max-$last_min;
		#$quant = $last_max-$first_min if $SRD eq "-";
		$quant = 0 if $quant < 0;
		$quant += 0;
		my $pas_data_ref = $val->{$pos};
		my @pas_data = @$pas_data_ref;
		print OUT join("\t",@pas_data,$quant),"\n";
	}
}

sub calculate_first{
	my @array = @_;
	my $sum = 0;
	my $count = 0;
	my $min = 10000000000000;
	my $max = -1;
	my $max_idx = -1;
	my $min_idx = -1;
	for(my$i=$#array;$i>0;$i--){
		my $cov = $array[$i];
		my $nex_cov = $array[$i-1];
		$sum += $cov;
		$count++;
		if($min>$cov){
			$min=$cov;
			$min_idx = $i;
		}
		if($max<$cov){
			$max=$cov;
			$max_idx = $i;
		}
		if(($cov>15 && $cov/($nex_cov+1)>5) || ($nex_cov>15 && $nex_cov/($cov+1)>5)){
			last;
		}
	}
	my $quant = $sum/$count;
	return ($quant,$min,$min_idx,$max,$max_idx);
}

sub calculate_last{
	my @array = @_;
	my $sum = 0;
	my $count = 0;
	my $min = 10000000000000;
	my $max = -1;
	my $max_idx = -1;
	my $min_idx = -1;
	for(my$i=0;$i<@array-1;$i++){
		my $cov = $array[$i];
		my $nex_cov = $array[$i+1];
		$sum += $cov;
		$count++;
		if($min>$cov){
			$min=$cov;
			$min_idx = $i;
		}
		if($max<$cov){
			$max=$cov;
			$max_idx = $i;
		}
		if(($cov>15 && $cov/($nex_cov+1)>5) || ($nex_cov>15 && $nex_cov/($cov+1)>5)){
			last;
		}
	}
	my $quant = $sum/$count;
	#return $quant;
	return ($quant,$min,$min_idx,$max,$max_idx);
}

