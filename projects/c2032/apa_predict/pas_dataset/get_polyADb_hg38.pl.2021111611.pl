#!/usr/bin/perl -w
#
#
#

my %hg38;
open FILE,"human.PAS.hg38.bed";
while(<FILE>){
	chomp;
	my ($chr,undef,$pos,$id,undef,$srd) = split;
	$hg38{$id} = "$chr:$pos:$srd";
}

open FILE,"human.PAS.txt";
<FILE>;
open OUT,">hg38.pAs.tianbin.txt";
print OUT "pas_id\tpas_type\tchr\tposition\tstrand\tsymbol\texon_Location\tConservation\n";
while(<FILE>){
	chomp;
	my ($id,$exon_Location,$symbol,$pas_type,$conservation) = (split /\t/)[0,5,8,-5,-2];
	$symbol = 'na' if $symbol eq '';
	if(exists $hg38{$id}){
		my $pas_id = $hg38{$id};
		my ($chr,$pos,$srd) = split /:/,$pas_id;
		next if $chr eq "chrY";
		next if $chr eq "MT";
		print OUT "$pas_id\t$pas_type\t$chr\t$pos\t$srd\t$symbol\t$exon_Location\t$conservation\n";
	}
}
