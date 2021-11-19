#!/usr/bin/perl -w

#my $ENS = "/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf";
my $ENS = "/home/longy/cnda/gencode/gencode.v38.annotation.gtf";
open ENS,"$ENS";
open OUT,">hg38/ensembl.identifiers.txt";
print OUT "Gene stable ID\tTranscript stable ID\tGene type\tTranscript type\tGene name\n";
while(<ENS>){
	chomp;
	next if $_ =~ /^\#/;
	my ($chr,$source,$type,$start,$end,$srd,$info) = (split  /\t/)[0,1,2,3,4,6,8];
	next if($type ne "transcript");
	my %gene_info;
	for $item (split /\;\ /,$info){
		#$item =~ s/^\ //g;
		my ($key,$val) = split /\ /,$item;
		$key =~ s/biotype/type/g;
		$val =~ s/\"|\;//g;
		$gene_info{$key} = $val;
	}
	if($chr !~ /chr/){
		$chr = "chr$chr";
	}
	my $gene_id = $gene_info{'gene_id'};
	my $trans_id = $gene_info{'transcript_id'};
	my $symbol = $gene_info{'gene_name'};
	my $gene_biotype = $gene_info{'gene_type'};
	my $trans_biotype = $gene_info{'transcript_type'};
	print OUT "$gene_id\t$trans_id\t$gene_biotype\t$trans_biotype\t$symbol\n";
}
