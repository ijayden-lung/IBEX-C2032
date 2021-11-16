#!/usr/bin/perl -w

open FILE,"tianbin_data/bl6.pAs.raw.tianbin.txt";
#open FILE,"/home/longy/workspace/apa_predict/pas_dataset/bl6.pAs.tianbin.txt";
<FILE>;
my @total;
my $pre_pos = 0;
my $pre_type = "NA";
my $pre_id = "NA";
while(<FILE>){
	chomp;
	#my ($pas_id,$chr,$pos,$strand,$rep1,$rep2) = (split)[0,1,4,5,6,7];
	my ($pas_id,$pas_type,$chr,$pos,$strand) = (split)[0,1,2,3,4];
	next if $pas_id =~ "^na";
	next if $pas_id =~ "^NO";
	next if $chr =~ /chrY/;
	push @total,$_;
	if(abs($pos-$pre_pos)<25){
		print "$_\n";
		if($pas_type =~ /UTR/){
			pop @total;
			pop @total;
			push @total,$_;
		}
		elsif($pre_type =~ /UTR/){
			pop @total;
		}
		else{
			pop @total;
			pop @total;
			push @total,$_;
		}
	}
	$pre_pos = $pos;
	$pre_type = $pas_type;
	$pre_id = $pas_id;
}

=pod
open OUT,">tianbin_data/bl6.pAs.raw.tianbin.txt";
print OUT "pas_id\tpas_type\tchr\tpos\tstrand\tsymbol\n";
foreach my $ele (@total){
	print OUT "$ele\n";
}
