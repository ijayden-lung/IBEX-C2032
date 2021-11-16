#!/usr/bin/perl -w
#

my %mm9tomm10;
my %coor2id;
open FILE,"bl6.pAs.tianbin.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$srd,$symbol) = split;
	$coor2id{"$chr:$pos:$srd"} = "$pas_id\t$pas_type";
}

my %mm9toid;
open FILE,"mouse.PAS.mm10.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($coor,$chr,$pos,$srd) = split;
	if(exists $coor2id{"$chr:$pos:$srd"}){
		$mm9toid{$coor} = $coor2id{"$chr:$pos:$srd"};
		$mm9tomm10{$coor} = "$chr:$pos:$srd";
	}
}



my %total;
my %gene;
open FILE,"pAs_usage.csv";
open OUT,">bl6.pAs.tianbin.liver.txt";
print OUT "pas_id\tpas_type\tchr\tposition\tstrand\tsymbol\tusage\n";
<FILE>;
while(<FILE>){
	chomp;
	my ($coor,$gene_name,$liver,$gene_id) = (split /,/)[0,1,7,-1];
	#$liver = 0 if($liver eq "");
	next if $liver eq "";
	if(exists $mm9toid{$coor}){
		my ($pas_id,$pas_type) = split /\t/,$mm9toid{$coor};
		my ($chr,$pos,$srd) = split /:/,$mm9tomm10{$coor};
		print OUT "$pas_id\t$pas_type\t$chr\t$pos\t$srd\t$gene_name\t$liver\n";
	}
}

