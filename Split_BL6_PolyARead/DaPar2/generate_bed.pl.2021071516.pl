#!/usr/bin/perl -w
#

$ENS = "/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz";
$OUT = "hg38_ensembl_extracted_3UTR.bed";

open FILE,"zcat $ENS | awk '(\$3 == \"three_prime_utr\")'|";
open OUT,">$OUT";
my %open;
my %close;
my %item;
while(<FILE>){
	chomp;
	my ($chr,$start,$end,$strand,$gene_id,$symbol) = (split)[0,3,4,6,9,17];
	$chr = "chr$chr";
	$gene_id =~ s/\"|\;//g;
	$symbol =~ s/\"|\;//g;
	if(exists $open{"$chr:$strand"}->{$start}){
		my $old_end = $open{"$chr:$strand"}->{$start};
		if($end>$old_end){
			delete $item{"$chr:$start:$old_end:$strand"};
		}
		else{
			next;
		}
	}
	elsif(exists $close{"$chr:$strand"}->{$end}){
		my $old_start = $close{"$chr:$strand"}->{$end};
		if($start<$old_start){
			delete $item{"$chr:$old_start:$end:$strand"};
		}
		else{
			next;
		}
	}
	$open{"$chr:$strand"}->{$start} = $end;
	$close{"$chr:$strand"}->{$end} = $start;
	$item{"$chr:$start:$end:$strand"} = "$chr\t$start\t$end\t$gene_id|$symbol|$chr|$strand\t0\t$strand";

}
while(my ($key,$val) = each %item){
	print OUT "$val\n";
}
