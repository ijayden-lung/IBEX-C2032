#!/usr/bin/perl -w


my ($data,$WIG,$ScanGeomome,$window,$SRD,$CHR) = @ARGV;

print "$data\n";
open FILE,$WIG;
open OUT,">$ScanGeomome";
#print OUT "pas_id\tpas_type\tchr\tpos\tstrand\tsymbol\tusage\tsequence\n";
my %cov;
<FILE>;
while(<FILE>){
	chomp;
	my ($pos,$read) = split;
	$cov{$pos} = $read;
}

open DATA,"$data";
<DATA>;
my %all;
while(<DATA>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$srd,$symbol) = split;
	next if $chr ne $CHR;
	next if $srd ne $SRD;
	my $new_pos = $pos;
	$new_pos += $window-1 if $srd eq "-";
	my @array = (0)x($window);
	for(my $i=0;$i<$window;$i++){
		my $each_pos = $new_pos-$i;
		if(exists $cov{$each_pos}){
			$array[$i] = $cov{$each_pos};
		}
	}
	@array = reverse @array if $SRD eq "+";
	print OUT "$pas_id\t$pas_type\t$chr\t$pos\t$srd\t$symbol\t";
	print OUT join ("\t",@array),"\n";
}
