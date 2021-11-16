#!/usr/bin/perl -w

my %pas;
open FILE,"bl6.pAs.zhangbin.fibroblast.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$srd,$symbol,$usage) = split;
	next if $pas_type ne "terminal" && $pas_type ne "tandemUTR";
	#next if $pas_type !~ /3'UTR/;
	next if $usage <0.3;
	my ($gene_id) = split /\./,$pas_id;
	$pas{$gene_id}->{$pos} = "$pas_id\t$pas_type\t$chr:$pos:$srd";
}

open OUT,">Input_density_zhangbin.fibroblast.txt";
print OUT "dist\tpas_id_pre\tpas_type_pre\tcoor_pre\tpas_id_nex\tpas_type_nex\tcoor_nex\n";
while(my($key,$val) = each %pas){
	my @dis = sort{$a<=>$b} keys %$val;
	next if @dis == 1;
	for(my$i=1;$i<@dis;$i++){
		my $dist = $dis[$i]-$dis[$i-1];
		print OUT "$dist\t$val->{$dis[$i-1]}\t$val->{$dis[$i]}\n";
	}
}

system("./density.r Input_density_zhangbin.fibroblast.txt Density_zhangbin.fibroblast.pdf");
