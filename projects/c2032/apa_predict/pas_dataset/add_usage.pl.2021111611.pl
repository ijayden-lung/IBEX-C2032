#!/usr/bin/perl -w
my %usage;
open FILE,"Parental/parental.pAs.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$usage) = split;
	next if $usage eq "";
	next if $usage eq "0.0";
	$usage{$pas_id} = $usage;
}

my %sequence;
open FILE,"Parental/bl.pAs.sequence.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($id,undef,undef,$seq) = split;
	#my $len = length $seq;
	#my $strat = int($len/2)-103;
	#$seq = substr($seq,$strat,206);
	$sequence{$id}  = $seq;
}


my %id2name;
open FILE, "/home/longy/cnda/ensembl/mm10_ID2Name.txt";
while(<FILE>){
	chomp;
	my ($gene_id,$gene_name) = split;
	$id2name{$gene_id} = $gene_name;
}


my %gene;



open FILE,"bl6.pAs.zhangbin.txt";
<FILE>;
open OUT,">bl6.pAs.zhangbin.fibroblast.txt";
print OUT "pas_id\tpas_type\tchr\tposition\tstrand\tsymbol\tusage\tsequence\n";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$srd) = split;
	my ($gene_id) = split /\./,$pas_id;
	$id2name{$gene_id} = "na" if !exists $id2name{$gene_id};
	if(exists $usage{$pas_id}){
		print OUT "$pas_id\t\t$pas_type\t$chr\t$pos\t$srd\t\t$id2name{$gene_id}\t$usage{$pas_id}\t$sequence{$pas_id}\n";
	}
}

