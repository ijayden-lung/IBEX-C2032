#!/usr/bin/perl -w
#
use Statistics::Descriptive;
use TrimmedMean;
#2021/01/24 Fixed bugs. usage files should be sorted.
my $dist_threshold = 49;
my $length = 201;

=pod
my $usage = "../../Split_BL6/polyA_seq/bl6_rep1.pAs.usage.txt";
my $out = "bl6_rep1.pAs.usage.txt";
my $db = "/home/longy/workspace/apa_predict/pas_dataset/bl6.pAs.tianbin.txt";
my $COV = "bl6_rep1.pAs.merge.coverage.txt";
=cut
#=pod
#my $usage = "/home/longy/project/Split_BL6/polyA_seq/k562_chen.pAs.usage.txt";
#my $out = "K562_Chen.pAs.old.usage.txt";
#my $usage = "K562_Chen.pAs.old.usage.txt";
#my $out  = "K562_Chen.pAs.usage.txt";
my $usage = "K562_Chen.pAs.merge.coverage.txt";
my $out  = "test";
my $db = "/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt";
#=cut

open FILE,"sort -k 3,3 -k 5,5 -k 4,4n $usage |";
my $header = <FILE>;
chomp $header;
my @USAGE = <FILE>;
open OUT,">$out";
print OUT "$header\tArich\tConservation\n";
my %dist;
my %readCount;
my %Motif;
my %ave_diff;
my %pas_id;
my %remove_id;
foreach(@USAGE){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$readCount,$motif,$ave_diff,$ur,$biotype) = split;
	my @data = split;
	my $before = &TrimmedMean(@data[8..8+100]);
	next if $before < 0.05;
	if(exists $dist{$symbol}){
		my $dist_diff = abs($pos - $dist{$symbol});
		if($dist_diff != 0 && $dist_diff <= $dist_threshold){
			my $pas_id2 = $pas_id{$symbol};
			$remove = $pas_id2;
			$remove_id{$remove} = '';
		}
	}
	$dist{$symbol} = $pos;
	$readCount{$symbol} = $readCount;
	$ave_diff{$symbol} = $ave_diff;
	$pas_id{$symbol} = $pas_id;
	$Motif{$symbol}  = $motif;
}


my %total;
foreach(@USAGE){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$usage,$readCount,$motif,$ave_diff) = split;
	my @data = split;
	my $before = &TrimmedMean(@data[8..8+100]);
	next if $before < 0.05;
	if(!exists $remove_id{$pas_id}){
		$total{$pas_id} = '';
	}
}

my $num = keys %total;
print "$num\n";
