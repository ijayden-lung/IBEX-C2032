#!/usr/bin/perl -w

open OUT,">K562_Control.pAs.pasPerGene.txt";
print OUT "cutoff\tpas_num\tgene_num\tpas_per_gene\n";
for(my $i=0;$i<=20;$i++){
	open FILE,"K562_Control.pAs.usage.txt";
	<FILE>;
	my $pas_num = 0;
	my %gene_list;
	while(<FILE>){
		chomp;
		my @data = split;
		#next if $data[7] <=$i;
		next if $data[10] <=$i;
		$pas_num += 1;
		$gene_list{$data[5]} = '';
	}
	my $gene_num = keys %gene_list;
	my $pas_per_gene = $pas_num/$gene_num;
	print OUT "$i\t$pas_num\t$gene_num\t$pas_per_gene\n";
}
