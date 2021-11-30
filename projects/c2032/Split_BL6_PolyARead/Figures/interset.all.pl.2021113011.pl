#!/usr/bin/perl -w

my %utr_hash;
&get_utr_pos("../DaPar2/new2/hg38_ensembl_extracted_3UTR.str1.bed");   
&get_utr_pos("../DaPar2/new2/hg38_ensembl_extracted_3UTR.str2.bed");   

sub get_utr_pos{
	my ($file) = @_;
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($chr,$start,$end,$info,undef,$strand) = split;
		my ($gene_id,$gene_name) = split /\|/,$info;
		$utr_hash{"$chr:$strand"}->{"$start,$end"} = 2;

	}
}

#open FILE,"/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt";
#open FILE,"/home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.db.usage.txt";
open FILE,"awk '(\$11>=0.05)' /home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.db.usage.txt |";
my $header = <FILE>;
my %overlap;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol) = split;
	my $utr_pos = $utr_hash{"$chr:$strand"};
	foreach my $key (keys %$utr_pos){
		my ($start,$end) = split /,/,$key;
		if($pos > $start && $pos < $end){
			$overlap{$pas_id} = '';
		}
	}
}
my $key_num = keys %overlap;
print "$key_num\n";
