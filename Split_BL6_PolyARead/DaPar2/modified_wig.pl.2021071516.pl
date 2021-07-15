#!/usr/bin/perl -w

my ($WIG,$chr,$OUT,$times) = @ARGV;

#my $WIG = "/home/longy/project/Split_BL6/STAR/SNU398_Control/Signal.Unique.str2.out.chr1.wig";

open FILE,"$WIG";
<FILE>; #skip header;
my $pre_pos = 0;
my $pre_cov = 0;
my $start = 0;
open OUT,">$OUT";
while(<FILE>){
	chomp;
	my ($pos,$cov) = split;
	$cov = sprintf("%.f",$cov*$times);
	if($pos-$pre_pos>1){
		print OUT "$chr\t$start\t$pre_pos\t$pre_cov\n" if $pre_pos>0;
		print OUT "$chr\t$pre_pos\t$pos\t0\n";
		$start = $pos;
	}
	elsif($cov != $pre_cov){
		print OUT "$chr\t$start\t$pos\t$pre_cov\n";
		$start = $pos;
	}
	$pre_cov = $cov;
	$pre_pos = $pos;
}

