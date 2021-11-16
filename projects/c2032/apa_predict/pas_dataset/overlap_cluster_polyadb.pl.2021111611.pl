#!/usr/bin/perl -w
#

my %tissue_pas;
#open FILE,"GSM747473_human_maqc-brain1.sites.clustered.hg19.bed";
#open OUT,">human_brain.hg37.rep1.bed";
#open FILE,"GSM747474_human_maqc-brain2.sites.clustered.hg19.bed";
#open OUT,">human_brain.hg37.rep2.bed";
#
open FILE,"GSM747472_human_liver.sites.clustered.hg19.bed";
open OUT,">human_liver.hg37.rep1.bed";
while(<FILE>){
	chomp;
	my ($chr,$pos,$pos2,undef,$readCount,$strand) = split;
	$tissue_pas{"$chr:$strand"}->{$pos} = $readCount;
}


my %db_pas;
open FILE,"human.PAS.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$chr,$pos,$strand,$symbol,$pas_type) = (split)[0,1,2,3,8,-5];
	my $readCount = 0;
	my $pas_pos_ref = $tissue_pas{"$chr:$strand"};
	if(exists $db_pas{$pas_id}){
		next;
	}
	else{
		$db_pas{$pas_id} = '';
	}
	while(my ($tissue_pas_pos,$val) = each %$pas_pos_ref){
		my $diff = abs($pos-$tissue_pas_pos);
		if($diff < 25){
			$readCount += $val;
			delete $tissue_pas{"$chr:$strand"}->{$tissue_pas_pos};
		}
	}
	if($readCount>0){
		my $pos0 = $pos-1;
		print OUT "$chr\t$pos0\t$pos\t$symbol\_$pas_type\t$readCount\t$strand\n";
	}
}


open FILE,"zcat /home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz | awk '(\$3 == \"transcript\")'|";
while(<FILE>){
	chomp;
	my ($chr,$start,$end,$strand,$symbol,$pas_type) = (split)[0,3,4,6,17,27];
	$chr = "chr$chr";
	my $pos = $end;
	$pos = $start if $strand eq "-";
	$symbol =~ s/\"|\;//g;
	$pas_type =~ s/\"|\;//g;
	my $pas_id = "$chr:$pos:$strand";
	my $readCount = 0;
	my $pas_pos_ref = $tissue_pas{"$chr:$strand"};
	if(exists $db_pas{$pas_id}){
		next;
	}
	else{
		$db_pas{$pas_id} = '';
	}
	while(my ($tissue_pas_pos,$val) = each %$pas_pos_ref){
		my $diff = abs($pos-$tissue_pas_pos);
		if($diff < 25){
			$readCount += $val;
		}
	}
	if($readCount>0){
		my $pos0 = $pos-1;
		print OUT "$chr\t$pos0\t$pos\t$symbol\_$pas_type\t$readCount\t$strand\n";
	}

}
