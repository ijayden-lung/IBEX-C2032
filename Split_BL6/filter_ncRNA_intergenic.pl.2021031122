#!/usr/bin/perl -w
#
#
#Update: 2021/02/22 Yongkang Long ###Same Propotation
use ReadGene;
use Assign;

my ($ENS,$scanTranscriptome,$out) = @ARGV;
my $Threshold  = 50;
my $Extend = 10000;  ###Maximum extension: 10k;
my $Inter_extend = 10000; #####Maximum inter gene extension;
my $Window = 25;   ###Window size for predict
my $Extend_Info = [$Extend,$Inter_extend,$Window];


print "Start getting gene information\n";
my ($utr_ref,$gene_start_ref,$gene_end_ref,$biotype_ref,$intergene_length_ref,$gene_location_ref,$gene_start_of_ref) = &GetGeneInfo($ENS,$Extend);
print "End getting gene information\n\n";


open FILE,"$scanTranscriptome";
open OUT,">$out";
my @lines = <FILE>;
for (my $i=0;$i<@lines;$i++){
	chomp $lines[$i];
	my @data = split /\t/,$lines[$i];
	my ($pas_id,$motif,$chr,$pos,$strand) =  @data[0..4];
	my $sign = 1;
	$sign = -1 if $strand eq "-";
	my (undef,$pas_type,$symbol) = &Assign_pAs_To_Gene(0,$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);
	next if $pas_type eq "ncRNA";
	next if $pas_type eq "intergenic";
	$data[5] = $symbol;
	$data[6] = $pas_type;
	print OUT join("\t",@data),"\n";
}
