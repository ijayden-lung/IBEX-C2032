#!/usr/bin/perl -w
#

my %pas;
open FILE,"human.pAs.brain.hg38.bed";
while(<FILE>){
	chomp;
	my ($chr,$pas_site,undef,$signal,$readCount,$strand) = split;
	$pas{"$chr,$strand"}->{$pas_site} = $readCount;
}

my %gene_count;
open FILE,"awk '(\$3 == \"three_prime_utr\")' /home/longy/cnda/ensembl/Homo_sapiens.GRCh38.95.gtf |";
open OUT,">human.pAs.brain.noUsage.txt";
print OUT "pas_id\tpas_type\tchr\tpostion\tstrand\tsymbol\treadCount\n";
while(<FILE>){
	chomp;
	my ($chr,$str,$end,$strand,$gene_id,$gene_name) = (split)[0,3,4,6,9,17];
	$chr = "chr$chr";
	$gene_id =~ s/\"|\;//g;
	$gene_name =~ s/\"|\;//g;
	if(exists $pas{"$chr,$strand"}){
		my $all_pas = $pas{"$chr,$strand"};
		while(my ($pas_site,$readCount) = each %$all_pas){
			if($str<=$pas_site && $end+100>=$pas_site){
				$gene_count{$gene_id}++;
				print OUT "$gene_id:$gene_count{$gene_id}\tUnknown\t$chr\t$pas_site\t$strand\t$gene_name\t$readCount\n";
				delete $all_pas->{$pas_site};
			}
		}
	}
}

