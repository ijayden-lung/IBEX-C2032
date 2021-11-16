#!/usr/bin/perl -w

my %brain1;
my $brain1_total=0;
my %signal;
my @brain;
my %brain;
open FILE,"GSM747473_human_maqc-brain1.sites.clustered.hg19.bed";
while(<FILE>){
	chomp;
	my ($chr,undef,$pos,$signal,$readCount,$strand) = split;
	$brain1{"$chr:$pos:$strand"} = $readCount;
	$brain1_total += $readCount;
	$signal{"$chr:$pos:$strand"} = $signal;
	push @brain,"$chr:$pos:$strand";
	$brain{"$chr:$pos:$strand"} = '';
}


my %brain2;
my $brain2_total=0;
open FILE,"GSM747474_human_maqc-brain2.sites.clustered.hg19.bed";
while(<FILE>){
	chomp;
	my ($chr,undef,$pos,$signal,$readCount,$strand) = split;
	$brain2{"$chr:$pos:$strand"} = $readCount;
	$brain2_total += $readCount;
	$signal{"$chr:$pos:$strand"} = $signal;
	$brain{"$chr:$pos:$strand"} = '';
}

my $ave = ($brain2_total+$brain1_total)/2;
my $brain1_factor = $ave/$brain1_total;
my $brain2_factor = $ave/$brain2_total;

open OUT,">human.pAs.brain.union.bed";
#foreach my $key (@brain){
foreach my $key (keys %brain){
	$brain2{$key} = 0 if ! exists $brain2{$key};
	$brain1{$key} = 0 if ! exists $brain1{$key};
	$signal{$key} = "No" if ! exists $signal{$key};
	my $val = $brain1{$key};
	#if(exists $brain2{$key}){
		my $val2 = $brain2{$key};
		my $ave = ($val*$brain1_factor+$val2*$brain2_factor)/2;
		my ($chr,$pos,$strand) = split /:/,$key;
		my $signal = $signal{$key};
		my $pre = $pos-1;
		print OUT "$chr\t$pre\t$pos\t$signal\t$ave\t$strand\n";
		#}
}


