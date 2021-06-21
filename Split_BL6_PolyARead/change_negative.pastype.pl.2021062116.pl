#!/usr/bin/perl -w
#
#Yongkang Long 2020/12/27 Change to Block version
#
#
use List::Util qw(first max maxstr min minstr reduce shuffle sum shuffle) ;
use TrimmedMean;
use Augmentation;
use Assign;
use ReadGene;

my ($ENS,$input,$PAS,$scanTranscriptome,$negative,$out,$round,$polyASeqRCThreshold, $RNASeqRCThreshold,$usageThreshold,$Shift,$New) = @ARGV;
my $Threshold  = 50;
my $Extend = 10000;  ###Maximum extension: 10k;
my $Inter_extend = 10000; #####Maximum inter gene extension;
my $Window = 25;   ###Window size for predict
my $Extend_Info = [$Extend,$Inter_extend,$Window];

my ($baseName) = (split /\//,$scanTranscriptome)[-1];
my ($CHR,$SRD) = split /\_/,$baseName;

print "Start getting gene information\n";
my ($utr_ref,$gene_start_ref,$gene_end_ref,$biotype_ref,$intergene_length_ref,$gene_location_ref,$gene_start_of_ref) = &GetGeneInfo($ENS,$Extend);
my $count_for_ref = &Init_count($gene_location_ref);
print "End getting gene information\n\n";

open FILE,"$input";
<FILE>;
my %fp_pas;
while(<FILE>){
	chomp;
	if($New eq "Yes"){
		my ($pas_id,$truth) = (split)[0,5];
		next if $truth eq "Yes";
		$fp_pas{$pas_id} = '';
	}
	else{
		my ($pos,$id,$diff,$chr,$srd,$gt_id,$gt_diff) = split;
		next if (abs($gt_diff) <= $Threshold);
		my $end = sprintf("%.0f",$pos);
		$fp_pas{"$chr:$end:$srd"} = '';
	}
}

my %true_pas;
open FILE,"$PAS";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
	next if $chr ne $CHR;
	next if $srd ne $SRD;
	#######PolyA Seq Read Count threshold;
	next if $polyASeqRC <= $polyASeqRCThreshold;
	#######RNA Seq Read Count threshold;
	next if $RNASeqRC   <=  $RNASeqRCThreshold;
	next if $usage <= $usageThreshold;
	$true_pas{$end} = '';
}

my @sort_true_pas = sort{$a<=>$b} keys %true_pas;

my %pas;
my %fp_pastype;
my %fp_motif;
open FILE,"$scanTranscriptome";
my $header=<FILE>;
my @lines = <FILE>;
@lines = reverse @lines if $SRD eq "-";
for (my $i=0;$i<@lines;$i++){
	chomp $lines[$i];
	my @data = split /\t/,$lines[$i];
	my $length = int((@data-8)/2);
	my $before = &TrimmedMean(@data[8..8+$length]);
	next if $before <= $RNASeqRCThreshold;
	my ($pas_id,$motif,$chr,$pos,$strand) =  @data[0..4];
	if(exists $fp_pas{$pas_id}){
		my $sign = 1;
		$sign = -1 if $SRD eq "-";
		my ($count,$pas_type,$symbol) = &Assign_pAs_To_Gene($count_for_ref->{"$chr:$strand"},$sign,$pos,$Extend_Info,$utr_ref,$gene_start_ref->{"$chr:$strand"},$gene_end_ref->{"$chr:$strand"},$biotype_ref,$gene_start_of_ref->{"$chr:$strand"},$intergene_length_ref);  ####modified count later;
		$count_for_ref->{"$chr:$strand"} = $count;
		$data[5] = "Origin$round";
		$data[6] = $pas_id;
		my @meta_data = &Augmentation($i,$pos,$pas_id,$pas_type,$symbol,$RNASeqRCThreshold,$Shift,\@lines);
		push @{$fp_pastype{$pas_type}},$pas_id;

		if($motif eq "motif=0"){
			push @{$fp_motif{0}},$pas_id;
		}
		else{
			push @{$fp_motif{1}},$pas_id;
		}

		foreach my $shift_data_ref (@meta_data){
			$shift_data_ref->[5] .= "_$round";
			$pas{$pas_id}->{$shift_data_ref->[0]} = join("\t",@$shift_data_ref);
		}
	}
}

while(my($pas_type,$array_ref) = each %fp_pastype){
	my @array = &shuffle(@$array_ref);
	$fp_pastype{$pas_type} = \@array;
}

while(my($key,$array_ref) = each %fp_motif){
	my @array = &shuffle(@$array_ref);
	$fp_motif{$key} = \@array;
}

foreach my $pas_id (keys %fp_pas){
	if (!exists $pas{$pas_id}){
		warn "Warning. predicted PAS $pas_id not in scan transcriptome file\n";
	}
}


open OUT,">$out";
my @shuffle = keys %pas;
open FILE,"$negative";
my %negative;
my %neg_pas_type;
my %substitue_pas;
my %neg_motif;
while(<FILE>){
	chomp;
	my ($pas_id,$motif_pastpye_symbol,$chr,$pos,$strand,$shift,$origin_pas_id) = split;
	if(exists $pas{$pas_id}){
		#next if exists $substitue_pas{$origin_pas_id};
		$substitue_pas{$origin_pas_id} = $pas{$pas_id};
		#my $val = $pas{$pas_id};
		#while (my ($shift_pas_id,$shift_line) = each %$val){
		#	print OUT "$shift_line\n";
		#}
	}
	my ($motif,$pastype) = split /\_/,$motif_pastpye_symbol;
	$negative{$origin_pas_id}->{$pas_id} = $_;
	$neg_pas_type{$origin_pas_id} = $pastype;
	if($motif eq "motif=0"){
		$neg_motif{$origin_pas_id} = 0;
	}
	else{
		$neg_motif{$origin_pas_id} = 1;
	}
}
	

=pod
my $i=0;
while(my($key,$val) = each %negative){
	#next if exists $substitue_pas{$key};
	if(rand()<0.6){
		######Continue
		my $motif = $neg_motif{$key};
		my $pas_id = pop @{$fp_motif{$motif}};
		if(defined $pas_id){#same pas type
			my $val2 = $pas{$pas_id};
			while (my ($shift_pas_id,$shift_line) = each %$val2){
				print OUT "$shift_line\n";
			}
		}
		else{
			warn "No more motif $motif";
			while (my ($shift_pas_id,$shift_line) = each %$val){
				print OUT "$shift_line\n";
			}
		}
	}
	else{
		while (my ($shift_pas_id,$shift_line) = each %$val){
			print OUT "$shift_line\n";
		}
	}
}
=cut
