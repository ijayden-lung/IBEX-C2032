#!/usr/bin/perl -w

open OUT,">DB.pAs.txt";
open FILE,"/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol) = split;
	$db_hash{$pas_id} = [$pas_id,$pas_type,$chr,$pos,$strand,$symbol];
}

my $num;
open FILE,"zcat gencode.v38.annotation.gtf.gz | awk '(\$3==\"transcript\")' | ";
open OUT,">DB.pAs.txt";
while(<FILE>){
	chomp;
	my ($chr,$start,$end,$strand,$symbol) = (split)[0,3,4,6,15];
	
	$symbol =~ s/\"|\;//g;
	$num++;
	my $pos = $end;
	if($strand eq "-"){
		$pos = $start;	
	}
	my $pas_id = "$chr:$pos:$strand";
	if (!exists $db_hash{$pas_id}){
		my @data = ($pas_id,'Gencode',$chr,$pos,$strand,$symbol);
		$db_hash{$pas_id} = \@data;
	}
}

while(my ($key,$val) = each %db_hash){
	print OUT join("\t",@$val),"\n";
}
