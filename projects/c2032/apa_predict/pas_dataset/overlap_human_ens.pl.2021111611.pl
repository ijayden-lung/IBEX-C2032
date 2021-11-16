#!/usr/bin/perl -w

my %read_pas;
open FILE,"awk '(\$3 == \"three_prime_utr\")' /home/longy/cnda/ensembl/Homo_sapiens.GRCh38.95.gtf |";
while(<FILE>){
	chomp;
	my ($chr,$str,$end,$strand,$gene_id,$gene_name) = (split)[0,3,4,6,9,17];
	$chr = "chr$chr";
	$gene_id =~ s/\"|\;//g;
	$gene_name =~ s/\"|\;//g;
	my $pas_site = $strand eq "+" ? $end : $str;
	$read_pas{"$chr,$strand,$pas_site"} = '';
}


open FILE,"human.pAs.brain.txt";
open OUT,">human.pAs.brain.overlap.txt";
print OUT "pas_id\tpas_type\tchr\tpostion\tstrand\tsymbol\tusage\n";
<FILE>;
while(<FILE>){
	chomp;
	my ($chr,$pos,$strand) = (split)[2,3,4];
	if(exists $read_pas{"$chr,$strand,$pos"}){;
		print OUT "$_\n";
	}
}

