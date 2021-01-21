#!/usr/bin/perl -w

use Statistics::Descriptive;

my ($USAGE,$READCOUNT,$OUT) = @ARGV;
my $blank = 0;
my $length = 200;


my %exp_readCount;
my %exp_totalReadCount;
my %pas_num;
my %pasid2symbol;
open FILE,"$USAGE";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$readCount) = split;
	#next if !exists $db_pas{"$chr:$pos:$strand"};
	$exp_readCount{$symbol}->{"$chr:$pos:$strand"} = $readCount;
	$exp_totalReadCount{$symbol} += $readCount;
	$pas_num{$symbol}++;
	$pasid2symbol{$pas_id} = $symbol;
}

my %exp_usage;
while(my ($symbol,$val) = each %exp_readCount){
	#next if $pas_num{$symbol} <=1;
	my $totalReadCount = $exp_totalReadCount{$symbol};
	while(my ($pas_id,$readCount) = each %$val){
		if($totalReadCount == 0){
			$exp_usage{$pas_id} = 0;
		}
		else{
			$exp_usage{$pas_id} = $val->{$pas_id} / $totalReadCount;
		}
	}
}

my %predict_readCount_plus;;
my %predict_readCount_minus;;
open FILE2,"$READCOUNT";
<FILE2>;
while(<FILE2>){
	chomp;
	my @data = split;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol) = split;
	#next if !exists $db_pas{"$chr:$pos:$strand"};
	$symbol = $pasid2symbol{$pas_id};
	#next if $pas_num{$symbol} <=1;
	#my @up_cov = @data[6..$#data-$blank];
	my @up_cov;
	for(my$i=6+$length;$i<@data-$blank;$i++){
		if($data[$i]>0){
			push @up_cov,$data[$i];
		}
	}
	my $stat = Statistics::Descriptive::Full->new();
	$stat->add_data(@up_cov);
	#my $median= $stat->median();
	my $median= $stat->max();
	if($strand eq "+"){
		$predict_readCount_plus{$symbol}->{$pos} = ["$chr:$pos:$strand",$median];
	}
	else{
		$predict_readCount_minus{$symbol}->{$pos} = ["$chr:$pos:$strand",$median];
	}
}


my %predict_readCount;
my %total_readCount;
while(my ($symbol,$val) = each %predict_readCount_plus){
	my $total = 0;
	foreach my $pos (sort{$b <=> $a} keys %$val){
		my $readCount_ref = $val->{$pos};
		my ($pas_id, $com_readCount) = @$readCount_ref;
		my $readCount = $com_readCount-$total;
		$readCount = 0 if $readCount < 0;
		$predict_readCount{$symbol}->{$pas_id} = $readCount;
		$total += $readCount;
	}
	$total_readCount{$symbol} = $total;
}
while(my ($symbol,$val) = each %predict_readCount_minus){
	my $total = 0;
	foreach my $pos (sort{$a <=> $b} keys %$val){
		my $readCount_ref = $val->{$pos};
		my ($pas_id, $com_readCount) = @$readCount_ref;
		my $readCount = $com_readCount-$total;
		$readCount = 0 if $readCount < 0;
		$predict_readCount{$symbol}->{$pas_id} = $readCount;
		$total += $readCount;
	}
	$total_readCount{$symbol} = $total;
}


open OUT,">$OUT";
print OUT "pas_id\tsymbol\tpredict_usage\texp_usage\n";
while(my ($symbol,$val) = each %predict_readCount){
	while(my ($pas_id,$readCount) = each %$val){
		my $predict_usage = $readCount/$total_readCount{$symbol};
		print OUT "$pas_id\t$symbol\t$predict_usage\t$exp_usage{$pas_id}\n";
	}
}
