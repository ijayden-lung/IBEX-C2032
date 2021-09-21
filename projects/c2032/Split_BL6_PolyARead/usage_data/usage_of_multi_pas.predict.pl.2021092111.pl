#!/usr/bin/perl -w

my $pt = 3;
my $rt = 9;
my $ut = 0.05;
my %gene_total;
my %tp_pas;
my %near_pas;
my %rever_pas;
my $pas_count=0;
my %gene_count;

my $baseName = "K562_Chen.pAs";

#my $usage = "/home/longy/project/Split_BL6/polyA_seq/BL6_REP1.pAs.predict.aug8_SC_p5r10u0.05_4-0026.12.2.usage.txt";
my $usage = "/home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.predict.aug8_SC_p3r9u0.05_4-0072.12.1.usage.txt";
my $file = "$baseName.predict.aug8_SC_p3r9u0.05_4-0072.12.1.txt";
open FILE,"$usage";
<FILE>;
my %pas_usage;
my %pas_pr;
my %multi_pas;
while(<FILE>){
	chomp;
	my @data = split;
	$pas_usage{$data[0]} = $data[6];
	$pas_pr{$data[0]} = $data[7];
	$multi_pas{$data[5]}++;
}
open FILE,"$usage";
<FILE>;
my %sinle_pas;
while(<FILE>){
	chomp;
	my @data = split;
	if($multi_pas{$data[5]}<=1){
		$sinle_pas{$data[0]} = ''
	}
}


open FILE,$file;
open OUT,">$baseName.predict.multipAs.usage.txt";
print OUT "pas_id\tpas_type\tmotif\tusage\tmappedToGroundTruth\n";
<FILE>;
while(<FILE>){
	chomp;
	my @data = split;
	my ($motif,$pas_type,$gene_name) = split /\_/,$data[1];
	#next if exists $sinle_pas{$data[0]};
	my ($gt_id,$gt_diff,$db_id,$db_diff) = split /,/,$data[6];
	if($motif =~ /motif=0/){
		$motif="NoMotif";
	}
	else{
		$motif="WithMotif";
	}
	#if ($data[5] ne "unassigned"){
	if($pas_pr{$data[0]} > $pt){
		$tp_pas{$gt_id} = '';
		$rever_pas{$gt_id} = $data[0];
		$near_pas{$data[0]} = $gt_id;
		print OUT "$data[0]\t$pas_type\t$motif\t$pas_usage{$data[0]}\tYes\n";
	}
	else{
		print OUT "$data[0]\t$pas_type\t$motif\t$pas_usage{$data[0]}\tNo\n";
	}
}

my %hash;
open FILE,"$baseName.usage.txt";
<FILE>;
while(<FILE>){
	my @data = split;
	next if $data[6] <= $ut;
	next if $data[7]<=$pt;
	next if $data[10]<=$rt;
	$hash{$data[5]}++;
}

open OUT,">$baseName.multipAs.usage.txt";
print OUT "pas_id\tpas_type\tmotif\tusage\tpredicted\n";
open FILE,"$baseName.usage.txt";
<FILE>;
my %distal_pas;
while(<FILE>){
	chomp;
	my @data = split;
	next if $data[6] <= $ut;
	next if $data[7]<=$pt;
	next if $data[10]<=$rt;
	#next if $hash{$data[5]} <=1;
	my ($pas_id,$pas_type,$chr,$end,$srd,$gene,$usage,$polyASeqRC,$motif,undef,$RNASeqRC) = split;
	if($motif =~ /motif=0/){
		$motif="NoMotif";
	}
	else{
		$motif="WithMotif";
	}
	if(exists $tp_pas{$pas_id}){
		print OUT "$data[0]\t$pas_type\t$motif\t$usage\tYes\n";
	}
	else{
		print OUT "$data[0]\t$pas_type\t$motif\t$usage\tNo\n";
	}
	if ($srd eq "+"){
		if(exists $distal_pas{$gene}){
			if($distal_pas{$gene}->[1]<$end){
				$distal_pas{$gene} = [$pas_id,$end];
			}
		}
		else{
			$distal_pas{$gene} = [$pas_id,$end];
		}
	}
	else{
		if(exists $distal_pas{$gene}){
			if($distal_pas{$gene}->[1]>$end){
				$distal_pas{$gene} = [$pas_id,$end];
			}
		}
		else{
			$distal_pas{$gene} = [$pas_id,$end];
		}
	}
}

