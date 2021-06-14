#!/usr/bin/perl -w

my ($file,$ENS) = @ARGV;
print "$file\n";

my %pas_plus;
open FILE,"zcat $ENS | awk '(\$3 == \"transcript\")'|";
<FILE>;
while(<FILE>){
	chomp;
	#my ($pas_id,$pas_type,$chr,$end,$srd,$symbol) = split /\t/; 
	my ($chr,$start,$end,$strand,$symbol,$pas_type) = (split)[0,3,4,6,17,27];
	$chr = "chr$chr";
	my $pos = $end;
	$pos = $start if $strand eq "-";
	$symbol =~ s/\"|\;//g;
	$pas_type =~ s/\"|\;//g;
	my $pas_id = "$chr:$pos:$strand";
	$pas_plus{$pas_id} = "$pas_type\t$symbol";
	print "$pas_id\n";
}

open FILE,"$file";
my $header = <FILE>;
my ($out) = (split /\//,$file)[-1];
$out = "../Split_BL6_PolyARead/usage_data/ens.$out";
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
