#!/usr/bin/perl -w
my %lastExon;
open FILE,"/home/longy/cnda/ensembl/mm10.ensemblv95.nopsuedo.gtf";
while(<FILE>){
	chomp;
	my ($type,$str,$end,$gene_id) = (split)[2,3,4,9];
	$gene_id =~ s/\"|\;//g;
	$lastExon{$gene_id}->{"$str\t$end"} = '' if $type eq "exon";
}

my %pas;
my %exon;
open FILE,"bl6.pAs.zhangbin.fibroblast.txt";
<FILE>;
open OUT,">Input_intronicPAS.txt";
print OUT "pas_id\tpos\tstr\tend\tdistance\tusage\n";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$srd,$symbol,$usage) = split;
	my ($gene_id) = split /\./,$pas_id;
	#next if $usage < 0.3;
	if($pas_type eq "intronicPAS"){
		if(exists $lastExon{$gene_id}){
			my $val = $lastExon{$gene_id};
			my $distance = 100000000;
			my $exon;
			foreach my $key (keys %$val){
				my ($str,$end) = split /\t/,$key;
				if($srd eq "+"){
					my $dist = $str-$pos;
					$exon = "$str\t$end" if $dist>0 && $dist<$distance;
					$distance = $dist if $dist>0 && $dist<$distance;
				}
				else{
					my $dist = $pos-$end;
					$exon = "$str\t$end" if $dist>0 && $dist<$distance;;
					$distance = $dist if $dist>0 && $dist<$distance;
				}
			}
			print  OUT "$pas_id\t$pos\t$exon\t$distance\t$usage\n" if $distance < 1000000;
		}
	}
}

=pod
while(my($key,$val) = each %exon){
	next if $val >1;
	print OUT "$pas{$key}\n" if exists $pas{$key};
}
=cut
