#!/usr/bin/perl -w
#
#Yongakng Long 2020/02/02 fixed filter gene option
#2020/02/03 fixed some exon shared by multiple genes.
##To be fixed, intergene length
#return the scalar variable, not hash variable$inp,$out,$ENS) = @ARGV;
#

#my ($inp,$out,$ENS) = @ARGV;
my $inp = "K562/K562_Chen.pAs.coverage.txt";
my $out = "K562/new_pastype.groundtruth.txt";
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

open FILE,"awk '(\$5 == \"+\")' $inp | sort -k 3,3 -k 4,4n | ";
while(<FILE>){
	chomp;
	next if $_ =~ /^pas_id/;
	my @data = split /\t/;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$motif) = @data[0..6];
	my $length = int((@data-8)/2);
	my $sign = 1;
	my ($count,$new_pas_type,$new_symbol,$extend_length,$between_gene) = &Assign_pAs_To_Gene($exon_loc_ref,$tss_ref->{"$chr:-"},$count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);
	$count_for_ref->{"$chr:$strand"} = $count;
	$pas_type{$pas_id} = "$new_pas_type\t$chr\t$pos\t$strand\t$new_symbol\t$extend_length\t$between_gene";
	$pas_gene{$pas_id}  = $new_symbol;

}

open FILE,"awk '(\$5 == \"-\")' $inp | sort -k 3,3 -k 4,4nr | ";
while(<FILE>){
	chomp;
	next if $_ =~ /^pas_id/;
	my @data = split /\t/;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$motif) = @data[0..6];
	my $length = int((@data-8)/2);
	my $sign = -1;
	my ($count,$new_pas_type,$new_symbol,$extend_length,$between_gene) = &Assign_pAs_To_Gene($exon_loc_ref,$tss_ref->{"$chr:+"},$count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);
	$count_for_ref->{"$chr:$strand"} = $count;
	$pas_type{$pas_id} = "$new_pas_type\t$chr\t$pos\t$strand\t$new_symbol\t$extend_length\t$between_gene";
	$pas_gene{$pas_id}  = $new_symbol;
}

open FILE,"$inp";
my @INP = <FILE>;
open OUT,">$out";
print OUT "pas_id\tpas_type\tchr\tposition\tstrand\tsymbol\textend_length\tbewteen_gene\n";
foreach(@INP){
	chomp;
	next if $_ =~ /^pas_id/;
	my ($pas_id,undef,$chr,$pos,$strand) = split;
	my $new_symbol = $pas_gene{$pas_id};
	my $biotype = "upstream_antisense";
	if(exists $biotype_ref->{$new_symbol}){
		$biotype = $biotype_ref->{$new_symbol};
	}
	print OUT "$pas_id\t$pas_type{$pas_id}\t$biotype\n";
}
