#!/usr/bin/perl -w
#
#Yongakng Long 2020/02/02 fixed filter gene option
#2020/02/03 fixed some exon shared by multiple genes.
##To be fixed, intergene length
#return the scalar variable, not hash variable

my ($data,$inp,$out,$ENS) = @ARGV;
use TrimmedMean;
use ReadGene;
use Assign;

my $Extend = 10000;  ###Maximum extension: 10k;
my $Inter_extend = 10000; #####Maximum inter gene extension;
my $Antisense_extend = 1000;
my $Window = 25;   ###Window size for predict
my $Extend_Info = [$Extend,$Inter_extend,$Antisense_extend,$Window];

my ($exon_loc_ref,$tss_ref,$utr_ref,$gene_start_ref,$gene_end_ref,$biotype_ref,$intergene_length_ref,$gene_location_ref,$gene_start_of_ref) = &GetGeneInfo($ENS,$Extend);
my $count_for_ref = &Init_count($gene_location_ref);


my %valid_pas;
open FILE,"sort -k2,2 -k6,6 -k5,5n $inp |";
my $header = <FILE>;
my @INP = <FILE>;
foreach(@INP){
	chomp;
	my ($pas_id,$chr,$pos,$strand,$rep1,$rep2) = (split)[0,1,4,5,6,7];
	my $ave = ($rep1+$rep2);
	#next if $ave <=0;
	$valid_pas{$pas_id} = '';
}

my %pas_gene;
my %pas_type;
my %filter;
my %symbol_of;
my %remark;

open FILE,"awk '(\$5 == \"+\")' $data | sort -k 3,3 -k 4,4n | ";
while(<FILE>){
	chomp;
	next if $_ =~ /^pas_id/;
	my @data = split /\t/;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$motif) = @data[0..6];
	next if !exists $valid_pas{$pas_id};
	my $length = int((@data-8)/2);
	my $before = &TrimmedMean(@data[8..8+$length]);
	next if $before <=0;
	my $after = &TrimmedMean(reverse (@data[9+$length..$#data]));
	my $ave = ($before+$after)/2;
	my $diff = $before-$after;
	my $ave_diff = $diff/$ave;
	my $sign = 1;
	##count if the start of mapping pas to gene,update every time;
	my ($count,$new_pas_type,$new_symbol,$extend_length,$between_gene) = &Assign_pAs_To_Gene($exon_loc_ref,$tss_ref->{"$chr:-"},$count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);
	$count_for_ref->{"$chr:$strand"} = $count;
	$pas_type{$pas_id} = "$pas_type\t$chr\t$pos\t$strand\t$symbol";
	$filter{$pas_id} = "$motif\t$ave_diff\t$before";
	$symbol_of{$pas_id} = $symbol;
	$pas_gene{$pas_id}  = $new_symbol;

	$remark{$pas_id} = "$new_symbol\t$new_pas_type\t$extend_length\t$between_gene";
}

open FILE,"awk '(\$5 == \"-\")' $data | sort -k 3,3 -k 4,4nr | ";
while(<FILE>){
	chomp;
	next if $_ =~ /^pas_id/;
	my @data = split /\t/;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$motif) = @data[0..6];
	next if !exists $valid_pas{$pas_id};
	my $length = int((@data-8)/2);
	my $before = &TrimmedMean(@data[8..8+$length]);
	next if $before <=0;
	my $after = &TrimmedMean(reverse (@data[9+$length..$#data]));
	my $ave = ($before+$after)/2;
	my $diff = $before-$after;
	my $ave_diff = $diff/$ave;
	my $sign = -1;
	my ($count,$new_pas_type,$new_symbol,$extend_length,$between_gene) = &Assign_pAs_To_Gene($exon_loc_ref,$tss_ref->{"$chr:+"},$count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);
	$count_for_ref->{"$chr:$strand"} = $count;
	$pas_type{$pas_id} = "$pas_type\t$chr\t$pos\t$strand\t$symbol";
	$filter{$pas_id} = "$motif\t$ave_diff\t$before";
	$symbol_of{$pas_id} = $symbol;
	$pas_gene{$pas_id}  = $new_symbol;
	$remark{$pas_id} = "$new_symbol\t$new_pas_type\t$extend_length\t$between_gene";
}

my %total;
foreach(@INP){
	chomp;
	my ($pas_id,$chr,$pos,$strand,$rep1,$rep2) = (split)[0,1,4,5,6,7];
	next if !exists $pas_gene{$pas_id};
	my $ave = ($rep1+$rep2);
	#next if $ave <= 0;
	my $symbol = $pas_gene{$pas_id};
	$total{$symbol} += $ave;
}

open OUT,">$out";
print OUT "pas_id\tpas_type\tchr\tposition\tstrand\tsymbol\tusage\treadCount\tmotif\tave_diff\n";
foreach(@INP){
	chomp;
	next if $_ =~ /^pas_id/;
	my ($pas_id,$chr,$pos,$strand,$rep1,$rep2) = (split)[0,1,4,5,6,7];
	next if !exists $pas_gene{$pas_id};
	my $ave = ($rep1+$rep2);
	#next if $ave <=0;
	my $symbol = $symbol_of{$pas_id};
	my $new_symbol = $pas_gene{$pas_id};
	my $usage;
	if (!exists $total{$new_symbol} || $total{$new_symbol} == 0){
		$usage = 0;
	}
	else{
		$usage = $ave/$total{$new_symbol};
	}
	my $remark = $remark{$pas_id};
	my $biotype = "upstream_antisense";
	if(exists $biotype_ref->{$new_symbol}){
		$biotype = $biotype_ref->{$new_symbol};
	}
	#########You should remove this if two replicate are not the same
	$ave /= 2;
	print OUT "$pas_id\t$pas_type{$pas_id}\t$usage\t$ave\t$filter{$pas_id}\t$remark\t$biotype\n";
}
