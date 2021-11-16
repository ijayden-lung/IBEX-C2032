#!/usr/bin/perl -w

my %pas;
open FILE,"Parental/nor.parental.pAs.count.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($id,$bl6_count1,$bl6_count2,$spr_count1,$spr_count2) = split;
	if($bl6_count2+$bl6_count1>10){
		$pas{$id} = '';
	}
}

my %usage;
open FILE,"Parental/parental.pAs.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($id,$bl6_usage,$spr_usage) = split;
	if(exists $pas{$id} && $bl6_usage>0){
		$usage{$id} = $bl6_usage;
	}
}

my %id2name;
open FILE, "/home/longy/cnda/ensembl/mm10_ID2Name.txt";
while(<FILE>){
	chomp;
	my ($gene_id,$gene_name) = split;
	$id2name{$gene_id} = $gene_name;
}



open FILE,"bl6.pAs.zhangbin.txt";
<FILE>;
open OUT,">bl6.pAs.fibroblast.txt";
print OUT "pas_id\tpas_type\tchr\tpostion\tstrand\tsymbol\tusage\n";
while(<FILE>){
	chomp;
	my ($id,$type,$chr,$pos,$strand) =split;
	my ($gene_id) = split /\./,$id;
	$id2name{$gene_id} = "na" if !exists $id2name{$gene_id};
	if(exists $usage{$id}){
		print OUT "$_\t$id2name{$gene_id}\t$usage{$id}\n";
	}
}

