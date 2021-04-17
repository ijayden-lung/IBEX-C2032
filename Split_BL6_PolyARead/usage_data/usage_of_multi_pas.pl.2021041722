#!/usr/bin/perl -w

my $pt = 40;
my $rt = 50;
my $ut = 0;
my %hash;
my %gene_total;
open FILE,"BL6_REP1.pAs.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my @data = split;
	next if $data[6] <= $ut;
	next if $data[7]<=$pt;
	next if $data[10]<=$rt;
	$hash{$data[5]}++;
	$gene_total{$data[5]} += $data[7];
}


open FILE,"BL6_REP1.pAs.usage.txt";
<FILE>;
open OUT,">BL6_REP1.pAs.multipAs.usage.txt";
print OUT "pas_id\tusage\n";
my $pas_count=0;
my %gene_count;
my $proximal_pas_count = 0;
while(<FILE>){
	chomp;
	my @data = split;
	next if $data[6] <= $ut;
	next if $data[7]<=$pt;
	next if $data[10]<=$rt;
	my $usage = 0;
	if(exists $gene_total{$data[5]} && $gene_total{$data[5]}>0){
		$usage = $data[7]/$gene_total{$data[5]};
	}
	print OUT "$data[0]\t$usage\n";
	$pas_count++;
	$gene_count{$data[5]}++;
	if($data[9]<1.8){
		$proximal_pas_count++;
	}
}

my $gene_count = keys %gene_count;
my $pas_per_gene = $pas_count/$gene_count;
print "$pas_count\t$gene_count\t$pas_per_gene\n";

my $multi_gene_count=0;
while(my($key,$val) = each %gene_count){
	if($val>1){
		$multi_gene_count++;
	}
}
my $per_multi_pas_gene = $multi_gene_count/$gene_count;
print "gene number:$multi_gene_count\tgene count:$gene_count\t$per_multi_pas_gene\n";

my $per_proximal_pas = ($pas_count-$gene_count)/$pas_count;
#my $per_proximal_pas = $proximal_pas_count/$pas_count;
print "\%proximal_pas\t$per_proximal_pas\n";
