#!/usr/bin/perl -w

open FILE,"human.pAs.brain.noUsage.txt";
my $header = <FILE>;

my %usage;
while(<FILE>){
	chomp;
	my ($pas_id,$readCount) = (split)[0,-1];
	my ($gene_id) = split /\:/,$pas_id;
	$usage{$gene_id} += $readCount;
}



open FILE,"human.pAs.brain.noUsage.txt";
<FILE>;
open OUT,">human.pAs.brain.filter.txt";
print OUT "pas_id\tpas_type\tchr\tpostion\tstrand\tsymbol\tusage\n";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pas_site,$strand,$symbol,$readCount) = split;
	next if $readCount<10;
	my ($gene_id) = split /\:/,$pas_id;
	my $usage = $readCount/$usage{$gene_id};
	print OUT "$pas_id\t$pas_type\t$chr\t$pas_site\t$strand\t$symbol\t$usage\n";
	
}
