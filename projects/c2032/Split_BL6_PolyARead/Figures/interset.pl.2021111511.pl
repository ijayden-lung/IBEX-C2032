#!/usr/bin/perl -w

my %utr_hash;
&get_utr_pos("../DaPar2/new2/hg38_ensembl_extracted_3UTR.str1.bed");   
&get_utr_pos("../DaPar2/new2/hg38_ensembl_extracted_3UTR.str2.bed");   

sub get_utr_pos{
	my ($file) = @_;
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($chr,$start,$end,$info,undef,$strand) = split;
		my ($gene_id,$gene_name) = split /\|/,$info;
		$utr_hash{$gene_name}->{"$start,$end"} = 2;

	}
}

open FILE,"SNU398/new_pastype.predicted.sequence.txt";
my $header = <FILE>;
open OUT,">SNU398/dapars2_interset.predicted.sequence.txt";
print OUT "$header";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol) = split;
	my $utr_pos = $utr_hash{$symbol};
	my $overlap = 0;
	foreach my $key (keys %$utr_pos){
		my ($start,$end) = split /,/,$key;
		if($pos > $start && $pos < $end){
			$overlap = 1;
		}
	}
	if ($overlap==1){
		print OUT "$_\n";
	}
}


