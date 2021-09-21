#!/usr/bin/perl -w
#
open FILE,"grep motif=0 /home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.usage.txt |";
my %no_motif;
while(<FILE>){
	chomp;
	my ($pas_id) = (split);
	$no_motif{$pas_id} = '';
}

my %hg37Tohg38;
open FILE,"/home/longy/workspace/apa_predict/pas_dataset/human.PAS.hg38.bed";
while(<FILE>){
	chomp;
	my ($chr,undef,$pos,$hg37_pasid,undef,$strand) = split;
	my $pas_id = "$chr:$pos:$strand";
	if(exists $no_motif{$pas_id}){
		$hg37Tohg38{$hg37_pasid} = $pas_id;
	}
}


open FILE,"/home/longy/workspace/apa_predict/pas_dataset/human.PAS.txt";
while(<FILE>){
	chomp;
	my ($hg37_pasid,$motif) = (split)[0,-3];
	if(exists $hg37Tohg38{$hg37_pasid}){
		print "$hg37_pasid\t$motif\t$hg37Tohg38{$hg37_pasid}\n";
	}
}

