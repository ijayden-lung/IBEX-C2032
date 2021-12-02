#!/usr/bin/perl -w
#
#Yongakng Long 2020/02/02 fixed filter gene option
#2020/02/03 fixed some exon shared by multiple genes.
##To be fixed, intergene length
#return the scalar variable, not hash variable$inp,$out,$ENS) = @ARGV;
#

#my ($inp
my $inp = "TCGA.LIHC.cut2sam.final.refind.cluster";
my $out = "TCGA.LIHC.cut2sam.final.refind.cluster.pastype";
my $ENS = "/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz";
use ReadGene;
use Assign;

my $Extend = 10000;  ###Maximum extension: 10k;
my $Inter_extend = 10000; #####Maximum inter gene extension;
my $Antisense_extend = 1000;
my $Window = 25;   ###Window size for predict
my $Extend_Info = [$Extend,$Inter_extend,$Antisense_extend,$Window];

my ($exon_loc_ref,$tss_ref,$utr_ref,$gene_start_ref,$gene_end_ref,$biotype_ref,$intergene_length_ref,$gene_location_ref,$gene_start_of_ref) = &GetGeneInfo($ENS,$Extend);
my $count_for_ref = &Init_count($gene_location_ref);



my %pas_gene;
my %pas_type;

open FILE,"awk '(\$6 ~ \"+\")' $inp | sort  -k1,1 -k7,7n |";
while(<FILE>){
	chomp;
	next if $_ =~ /#/;
	next if $_ =~ /predict_pasid/;
	my (undef,$utr_s,$utr_e,$pas_id) = split;
	my ($chr,$strand,$na,$pos) = split /\|/,$pas_id;
	my $sign = 1;
	my ($count,$new_pas_type,$new_symbol,$extend_length,$between_gene) = &Assign_pAs_To_Gene($exon_loc_ref,$tss_ref->{"$chr:-"},$count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);
	$count_for_ref->{"$chr:$strand"} = $count;
	$pas_type{$pas_id} = "$_\t$new_symbol\t$new_pas_type";
	$pas_gene{$pas_id}  = $new_symbol;

}

open FILE,"awk '(\$6 ~ \"-\")' $inp | sort -t ':' -k1,1 -k7,7nr |";
while(<FILE>){
	chomp;
	next if $_ =~ /#/;
	next if $_ =~ /predict_pasid/;
	my (undef,$utr_s,$utr_e,$pas_id) = split;
	my ($chr,$strand,$na,$pos) = split /\|/,$pas_id;
	my $sign = -1;
	my ($count,$new_pas_type,$new_symbol,$extend_length,$between_gene) = &Assign_pAs_To_Gene($exon_loc_ref,$tss_ref->{"$chr:+"},$count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);
	$count_for_ref->{"$chr:$strand"} = $count;
	$pas_type{$pas_id} = "$_\t$new_symbol\t$new_pas_type";
	$pas_gene{$pas_id}  = $new_symbol;
}

open FILE,"$inp";
my @INP = <FILE>;
open OUT,">$out";
foreach(@INP){
	chomp;
	next if $_ =~ /#/;
	next if $_ =~ /predict_pasid/;
	my (undef,$utr_s,$utr_e,$pas_id) = split;
	print OUT "$pas_type{$pas_id}\n";
}
