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
open OUT,">Input_altLastExon.txt";
print OUT "pas_id\tpos\tstr\tend\tlength\n";
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$srd,$symbol,$usage) = split;
	my ($gene_id) = split /\./,$pas_id;
	#next if  $usage<0.3;
	if($pas_type eq "altLastExon"){
		if(exists $lastExon{$gene_id}){
			my $val = $lastExon{$gene_id};
			foreach my $key (keys %$val){
				my ($str,$end) = split /\t/,$key;
				if($pos<=$end  && $pos>=$str){
					my $length = $end-$str;
					$exon{"$str\t$end"}++;
					$pas{"$str\t$end"}  = "$pas_id\t$pos\t$str\t$end\t$length" if(($srd eq "+" && $pos>=$end-100) || ($srd eq "-"  && $pos<=$str+100))
				}
			}
		}
	}
}

while(my($key,$val) = each %exon){
	next if $val >1;
	print OUT "$pas{$key}\n" if exists $pas{$key};
}
