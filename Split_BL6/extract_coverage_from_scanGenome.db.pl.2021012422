#!/usr/bin/perl -w

my ($file,$PAS) = @ARGV;
print "$file\n";

my %pas_plus;
open FILE,"$PAS";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd,$symbol) = split /\t/; 
	$pas_plus{$pas_id} = "$pas_type\t$symbol";
}

open FILE,"$file";
my $header = <FILE>;
my ($out) = (split /\//,$file)[-1];
$out = "../Split_BL6_PolyARead/usage_data/$out";
open OUT,">$out";
while(<FILE>){
	chomp;
	my @data = split /\t/;
	my $chr = $data[2];
	my $pos = $data[3];
	my $srd = $data[4];
	my $pas_id = $data[0];
	if(exists $pas_plus{$pas_id}){
		my $val = $pas_plus{$pas_id};
		my ($pas_type,$symbol) = split /\t/,$val;
		$data[6] = $data[1];
		$data[1] = $pas_type;
		$data[5] = $symbol;
		print OUT join("\t",@data), "\n";
	}
}
