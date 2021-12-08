#!/usr/bin/perl -w
#
#Yongakng Long 2020/02/02 fixed filter gene option
#2020/02/03 fixed some exon shared by multiple genes.
##To be fixed, intergene length
#return the scalar variable, not hash variable$inp,$out,$ENS) = @ARGV;
#

my $ENS = "/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz";
use ReadGene;
use Assign;

my $Extend = 10000;  ###Maximum extension: 10k;
my $Inter_extend = 10000; #####Maximum inter gene extension;
my $Antisense_extend = 1000;
my $Window = 25;   ###Window size for predict
my $Extend_Info = [$Extend,$Inter_extend,$Antisense_extend,$Window];

my ($exon_loc_ref,$tss_ref,$utr_ref,$gene_start_ref,$gene_end_ref,$biotype_ref,$intergene_length_ref,$gene_location_ref,$gene_start_of_ref) = &GetGeneInfo($ENS,$Extend);

my %strand;
open ENS,"zcat $ENS | ";
while(<ENS>){
	chomp;
	next if $_ =~ /^\#/;
	my ($chr,$source,$type,$start,$end,$srd,$info) = (split  /\t/)[0,1,2,3,4,6,8];
	my %gene_info;
	for $item (split /\;\ /,$info){
		#$item =~ s/^\ //g;
		my ($key,$val) = split /\ /,$item;
		$key =~ s/biotype/type/g;
		#print "$key\t$val\n";
		$val =~ s/\"|\;//g;
		$gene_info{$key} = $val;
	}

	if($chr !~ /chr/){
		$chr = "chr$chr";
	}
	$strand{$gene_info{'gene_name'}} = "$srd\t$chr";
}

open OUT,">gencode.hg38.utr.bed";
while(my($symbol,$val) = each %$utr_ref){
	my ($srd,$chr) = split /\t/,$strand{$symbol};
	my ($pos1,$pos2) = split /\-/,$val;
	my $start = $pos1-1;
	my $end  = $pos2;
	if($srd eq "-"){
		$start = $pos2-1;
		$end = $pos1;
	}
	if($start >$end){
		print "$chr\t$end\t$start\t$symbol\t.\t$srd\n";
	}
	else{
		print  OUT "$chr\t$start\t$end\t$symbol\t.\t$srd\n";
	}
}


