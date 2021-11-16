#!/usr/bin/perl -w

my ($count1,$count2,$out) = @ARGV;


my %hash;
my %hash1;
open FILE,"$count1";
while(<FILE>){
	chomp;
	#my ($chr,$pre,$end,$pas_id,$pos,$strand,$readCount) = split;
	my ($chr,$pre,$end,undef,$readCount,$strand) = split;
	my $pas_id = "$chr:$end:$strand";
	$hash{$pas_id} = "$pas_id\t$chr\t$pre\t$end\t$end\t$strand";
	$hash1{$pas_id} = $readCount;
}


my %hash2;
open FILE,"$count2";
while(<FILE>){
	chomp;
	my ($chr,$pre,$end,undef,$readCount,$strand) = split;
	my $pas_id = "$chr:$end:$strand";
	$hash{$pas_id} = "$pas_id\t$chr\t$pre\t$end\t$end\t$strand";
	$hash2{$pas_id} = $readCount;
}

open OUT,">$out";
print OUT "pas_id\tchr\tstart\tend\tposition\tstrand\trep1\trep2\n";
while(my($key,$val) = each %hash){
	$hash1{$key} = 0 if !exists $hash1{$key};
	$hash2{$key} = 0 if !exists $hash2{$key};
	print OUT "$val\t$hash1{$key}\t$hash2{$key}\n";
}
