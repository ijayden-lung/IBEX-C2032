#!/usr/bin/perl -w
use List::Util qw(first max maxstr min minstr reduce shuffle sum shuffle) ;

my ($input,$scanGenome,$out1) = @ARGV;
open FILE,"$input";
<FILE>;
my %predict;
while(<FILE>){
	chomp;
	my ($pos,$id,$diff,$chr,$strand,$gt_pasid,$gt_diff) = split;
	my $end = sprintf("%.0f",$pos);
	my $pas_id = "$chr:$end:$strand";
	$predict{$pas_id}  = "$gt_diff\t$gt_pasid";
}

open FILE,"$scanGenome";
my $header  =<FILE>;
open OUT1,">$out1";
while(<FILE>){
	chomp;
	my @data = split;
	if(exists $predict{$data[0]}){
		my ($gt_diff,$gt_pasid) = split /\t/, $predict{$data[0]};
		$data[5] = $gt_diff;
		$data[6] = $gt_pasid;
		print OUT1 join("\t",@data),"\n";
	}
}
