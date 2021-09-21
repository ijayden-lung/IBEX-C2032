#!/usr/bin/perl -w
#
#
#Update: 2021/02/22 Yongkang Long ###Same Porpotion
use TrimmedMean;
use ReadGene;
use Assign;
use Augmentation;
use List::Util qw(first max maxstr min minstr reduce shuffle sum shuffle) ;

my ($ENS,$scanTranscriptome,$round,$RNASeqRCThreshold,$prob,$Shift) = @ARGV;
my $Threshold  = 50;
my $Extend = 10000;  ###Maximum extension: 10k;
my $Inter_extend = 10000; #####Maximum inter gene extension;
my $Window = 25;   ###Window size for predict
my $Extend_Info = [$Extend,$Inter_extend,$Window];
my ($baseName) = (split /\//,$scanTranscriptome)[-1];
my ($CHR,$SRD) = split /\_/,$baseName;
my $baseround = substr($round,0,-2);


print "Start getting gene information\n";
my ($utr_ref,$gene_start_ref,$gene_end_ref,$biotype_ref,$intergene_length_ref,$gene_location_ref,$gene_start_of_ref) = &GetGeneInfo($ENS,$Extend);
my $count_for_ref = &Init_count($gene_location_ref);
print "End getting gene information\n\n";


print "Start randomly selecting negative pas\n";
my %true_pas;
my %true_motif_count = (0=>0,1=>0);
my %true_pas_type_count = ("LE"=>0,"UR"=>0,"ncRNA"=>0,"intergenic"=>0);
my $positive = "data/positive/$baseround/$baseName";
open FILE,"$positive";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$motif_pas_type,$chr,$end,$srd,$shift) = split;
	next if $shift ne "Origin";
	my ($motif,$pas_type,$gene_name) = split /\_/,$motif_pas_type;
	$true_pas_type_count{$pas_type}++;
	$true_pas{$end} = '';
	if($motif eq "motif=0"){
		$true_motif_count{0}++;
	}
	else{
		$true_motif_count{1}++;
	}
}

my @sort_true_pas = sort{$a<=>$b} keys %true_pas;
my $true_pas_num = @sort_true_pas;

open FILE,"$scanTranscriptome";
my $header = <FILE>;

my $out = "data/negative/$round/$baseName";
print "$out\n";
open OUT,">$out";
my $index = 0;
my @lines = <FILE>;
@lines = reverse @lines if $SRD eq "-";
my $aug_count = 0;
my $parent_pasid = '';
my %negative_candidate;
my $pre_pos = 0;
for (my $i=0;$i<@lines;$i++){
	chomp $lines[$i];
	my @data = split /\t/,$lines[$i];
	my $length = int((@data-8)/2);
	my $before = &TrimmedMean(@data[8..8+$length]);
	next if $before <= $RNASeqRCThreshold;
	my ($pas_id,$motif,$chr,$pos,$strand) =  @data[0..4];
	my $p = $prob;
	my $motif_info = 1;
	if($motif eq "motif=0"){
		$p = $prob/5;
		#$p = $prob; #Modified
		$motif_info = 0;
	}
	my $sign = 1;
	$sign = -1 if $SRD eq "-";
	my ($count,$pas_type,$symbol) = &Assign_pAs_To_Gene($count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);  ####modified count later;

	$count_for_ref->{"$chr:$strand"} = $count;
	if($pas_type eq "UR"){
		#$p = $prob/4;
		$p = $prob; #Modified
	}
	if(rand() < $p){
		my $accept = 1;
		for(my$i=$index;$i<@sort_true_pas;$i++){
			if($sort_true_pas[$i] - $pos < -$Threshold){
				$index = $i;
				next;
			}
			elsif($sort_true_pas[$i] - $pos < $Threshold){
				$accept = 0;
			}
			else{
				last;
			}
		}
		if(abs($pos - $pre_pos)<$Threshold){
			$accept = 0
		}
		if($accept == 1){
			$negative_candidate{$pas_id} = [$i,$chr,$pos,$strand,$motif_info,$pas_type,$symbol];
			$pre_pos = $pos;
		}
	}
}
print "End randomly selecting negative pas\n\n";

print "Start assigning pAs with symbol and pAs type\n";
my $total_count = 0;
my %negative_pas_type_count  = ("LE"=>0,"UR"=>0,"ncRNA"=>0,"intergenic"=>0);;
my %negative_motif_count = (0=>0,1=>0);
my $sign = 1;
$sign = -1 if $SRD eq "-";

&fulfill();
sub fulfill{
	my @shuffle_negcan = &shuffle(keys %negative_candidate);
	foreach my $pas_id (@shuffle_negcan){
		my $val = $negative_candidate{$pas_id};
		my ($i,$chr,$pos,$strand,$motif_info,$pas_type,$symbol) = @$val;
		###Modified
		#next if $pas_type ne $PAS_TYPE;
		next if $negative_motif_count{$motif_info} >= $true_motif_count{$motif_info};
		#next if $negative_pas_type_count{$pas_type} >= $true_pas_type_count{$pas_type};
		$negative_motif_count{$motif_info}++;
		$negative_pas_type_count{$pas_type}++;
		my @meta_data = &Augmentation($i,$pos,$pas_id,$pas_type,$symbol,$RNASeqRCThreshold,$Shift,\@lines);
		foreach my $shift_data_ref (@meta_data){
			print OUT join("\t",@$shift_data_ref),"\n";
		}
		$total_count++;
		if($total_count % 10 == 0){
			print "processing $total_count pas\n";
		}
		last if $total_count >=  $true_pas_num;
		delete $negative_candidate{$pas_id};
	}
}

while(my ($key,$true_count) = each %true_motif_count){
	$negative_count = $negative_motif_count{$key};
	if($negative_count<$true_count){
		warn "Warning! At $scanTranscriptome Number of pseudo PAS with $key motif = $negative_count";
		warn "It is not enough compared to ground truth = $true_count\n";
	}
}
