#!/usr/bin/perl -w
#
#
#
my %conventer;
open FILE,"/ibex/scratch/longy/cnda/ensembl/mm10_ID2Name.txt";
while(<FILE>){
	chomp;
	my ($id,$name) = split;
	$conventer{$name} = $id;
}


my %mm10;
open FILE,"mouse.PAS.mm10.bed";
while(<FILE>){
	chomp;
	my ($chr,undef,$pos,$id,undef,$srd) = split;
	$mm10{$id} = "$chr:$pos:$srd";
}

open FILE,"mouse.PAS.txt";
<FILE>;
open OUT,">bl6.pAs.tianbin.txt";
print OUT "pas_id\tpas_type\tchr\tposition\tstrand\tsymbol\texon_Location\tConservation\n";
my %ens;
while(<FILE>){
	chomp;
	my ($id,$exon_Location,$symbol,$pas_type,$conservation) = (split /\t/)[0,5,8,11,-2];
=pod
	#####Get all pAs Aug. 19
	#next if $pas_type eq "intergenic" || $pas_type eq "Pseudogene" || $pas_type eq "ncRNA";
	#next if $_ =~ "predicted";
	if($ens_id eq "NO" || $ens_id eq "na"){
		next;
		if(exists $conventer{$symbol}){
			$ens_id = $conventer{$symbol};
		}
		else{
			#$ens_id = "$symbol";
		}
	}
	if(exists $mm10{$pas_id}){
		$ens{$ens_id}++;
		print OUT "$ens_id\.$ens{$ens_id}\t$pas_type\t$mm10{$pas_id}\t$symbol\n";
	}
=cut
	if(exists $mm10{$id}){
		my $pas_id = $mm10{$id};
		my ($chr,$pos,$srd) = split /:/,$pas_id;
		next if $chr eq "chrY";
		print OUT "$pas_id\t$pas_type\t$chr\t$pos\t$srd\t$symbol\t$exon_Location\t$conservation\n";
	}

}
