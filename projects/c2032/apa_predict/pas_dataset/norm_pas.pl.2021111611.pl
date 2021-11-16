#!/usr/bin/perl -w
my %pas_fwd;
my %pas_rev;
my %type;
my @type;
open FILE,"/ibex/scratch/longy/workspace/apa_predict/pas_dataset/Parental/bl.pAs.sequence.txt";
<FILE>;
open OUT,">spr.pAs.zhangbin.txt";
print OUT "pas_id\tpas_type\tchr\tposition\tstrand\n";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$coordinate) = split;
	my ($bl6,$spr) = split /,/,$coordinate;
	my ($chr,$srd,$spe,$mid) = split /\|/,$bl6;
	$srd = $srd eq "+" ? "-" : "+";
	if($spe eq "SP"){
		print OUT "$pas_id\t$pas_type\t$chr\t$mid\t$srd\n";
	}
	next if ! defined  $spr;
	($chr,$srd,$spe,$mid) = split /\|/,$spr;
	$srd = $srd eq "+" ? "-" : "+";
	if($spe eq "SP"){
		print OUT "$pas_id\t$pas_type\t$chr\t$mid\t$srd\n";
	}
}

