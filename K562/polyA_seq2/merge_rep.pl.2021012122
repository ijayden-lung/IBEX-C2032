#!/usr/bin/perl -w

my ($count1,$count2,$out) = @ARGV;


my %hash;
open FILE,"$count1";
while(<FILE>){
	chomp;
	my ($chr,$pre,$end,$pas_id,$pos,$strand,$readCount) = split;
	$hash{$pas_id} = $readCount;
}


open OUT,">$out";
open FILE,"$count2";
print OUT "pas_id\tchr\tstart\tend\tposition\tstrand\trep1\trep2\n";
while(<FILE>){
	chomp;
	my ($chr,$pre,$end,$pas_id,$pos,$strand,$readCount) = split;
	if(exists $hash{$pas_id}){
		print OUT "$pas_id\t$chr\t$pre\t$end\t$pos\t$strand\t$hash{$pas_id}\t$readCount\n";
	}
}

