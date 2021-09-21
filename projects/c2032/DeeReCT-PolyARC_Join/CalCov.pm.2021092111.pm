#!/usr/bin/perl -w
package CalCov;
require Exporter;
use List::Util qw/shuffle sum/;
use POSIX;

our @ISA = qw/Exporter/;
our @EXPORT = qw/calCov/;

sub calCov{
	my ($WIG,$out,$window,$step,$chr) = @_;
	open FILE,$WIG;
	open OUT,">$out";
	my %cov;
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pos,$read) = split;
		$cov{$pos} = $read;
		my @array = (0)x($window);
		my $sum=0;
		my $count=0;
		for(my$i=0;$i<$window/$step;$i++){
			my $pre_pos = $pos-$window+$i+1;
			if(exists $cov{$pre_pos} = $read){
				$array[$i] = $cov{$pre_pos};
				$sum += $array[$i];
				$count++;
			}
			else{
				$array[$i] = 0;
			}
		}
		my $trimMean = $sum/$count;
		my $pasEnd = $pos+$window-1;
		print OUT join("\t","Scan$i",$trimMean,"$chr:$pos-$pasEnd",@array),"\n" if $trimMean>10;
	}
}

