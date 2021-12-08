#!/usr/bin/perl -w

my %hash;
open FILE,"test2";
while(<FILE>){
	chomp;
	my ($chr,$pos0,$pos,undef,undef,$strand) = split;
	my $pasid = "$chr:$pos:$strand";
	$hash{$pasid} = '';
}
open FILE,"test";
while(<FILE>){
	chomp;
	my ($chr,$pos0,$pos,undef,$pastype,$strand) = split;
	my $pasid = "$chr:$pos:$strand";
	if($pastype eq "ncRNA" && !exists $hash{$pasid}){
		print "$pasid\n";
	}
}
