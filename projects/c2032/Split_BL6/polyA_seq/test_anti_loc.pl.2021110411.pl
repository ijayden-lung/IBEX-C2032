#!/usr/bin/perl -w

my $ENS = "/home/longy/cnda/gencode/gencode.v38.annotation.gtf";
open ENS,"$ENS";
my $normal_gene;
my $antisense_gene;
while(<ENS>){
	chomp;
	next if $_ =~ /^\#/;
	my ($chr,$source,$type,$start,$end,$srd,$info) = (split  /\t/)[0,1,2,3,4,6,8];
	next if $type ne "gene";
	my %gene_info;
	for $item (split /\;\ /,$info){
		my ($key,$val) = split /\ /,$item;
		$key =~ s/biotype/type/g;
		$val =~ s/\"|\;//g;
		$gene_info{$key} = $val;
	}
	if($chr !~ /chr/){
		$chr = "chr$chr";
	}
	my $gene_symbol = $gene_info{'gene_name'};
	if($gene_symbol =~ /\-AS/){
		my ($normal_symbol) = split /\-/,$gene_symbol;
		#print "$normal_symbol\t$gene_symbol\n";
		if($srd eq "+"){
			$antisense_gene{$normal_symbol} = -$end;
		}
		else{
			$antisense_gene{$normal_symbol} = $start;
		}
	}
	else{
		if($srd eq "+"){
			$normal_gene{$gene_symbol} = $start;
		}
		else{
			$normal_gene{$gene_symbol} = -$end;
		}
	}
}

open OUT,">test";
while(my ($gene,$pos) = each %normal_gene){
	if(exists $antisense_gene{$gene}){
		my $anti_pos = $antisense_gene{$gene};
		my $diff = $pos-$anti_pos;
		print OUT "$gene\t$diff\n";
	}
}
