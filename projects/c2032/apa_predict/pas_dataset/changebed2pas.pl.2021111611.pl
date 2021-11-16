#!/usr/bin/perl -w


open FILE,"/home/longy/project/human.polyAdb3.2_gtf.hg38.bed";
open OUT,">human.pAs.all.txt";
print OUT "pas_id\tpas_type\tchr\tpos\tstrand\n";
while(<FILE>){
	chomp;
	my ($chr,undef,$end,undef,undef,$srd) = split /\t/;
	my $pas_id;
	if($srd eq "+"){
		my $head = $end-100;
		my $tail = $end+76;
		$pas_id = "$chr:$head-$tail";
	}
	else{
		my $head = $end-76;
		my $tail = $end+100;
		$pas_id = "$chr:$head-$tail";
	}
	print OUT "$pas_id\tNone\t$chr\t$end\t$srd\n";
}
