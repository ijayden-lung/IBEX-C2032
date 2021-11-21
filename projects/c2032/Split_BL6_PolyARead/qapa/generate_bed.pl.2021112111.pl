#!/usr/bin/perl -w


open FILE,"awk '(\$2 != \"intergenic\" && \$7>=0.05 && \$8>=1 && \$11>=0.05)' ../usage_data/snu398_control.pAs.usage.txt |";
open OUT,">examples/hg38/SNU398.polyA_sites.bed";
while(<FILE>){
	next if $_ =~ /^pas_id/;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol) = split;
	my $start = $pos-2;
	my $end = $pos;
	if($strand eq "-"){
		$start = $pos;
		$end = $pos+2;
	}
	print OUT "$chr\t$start\t$end\tpolyA_site\t0\t$strand\n";
}

