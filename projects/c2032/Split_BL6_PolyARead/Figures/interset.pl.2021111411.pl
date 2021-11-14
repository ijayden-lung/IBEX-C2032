#!/usr/bin/perl -w

my %utr_hash;
&get_utr_pos("../DaPar2/hg38_ensembl_extracted_3UTR.str1.bed");   
&get_utr_pos("../DaPar2/hg38_ensembl_extracted_3UTR.str2.bed");   

sub get_utr_pos{
	my ($file) = @_;
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($chr,$start,$end,$info,undef,$strand) = split;
		my ($gene_id,$gene_name) = split /\|/,$info;
		if(exists $utr_hash{$gene_name}){
			if($start < $utr_hash{$gene_name}->[0]){
				$utr_hash{$gene_name}->[0] = $start;
			}
			elsif($end > $utr_hash{$gene_name}->[1]){
				$utr_hash{$gene_name}->[1] = $end;
			}
		}
		else{
			$utr_hash{$gene_name} = [$start,$end];
		}
	}
}

print "$utr_hash{'SDF4'}->[0]\n";
