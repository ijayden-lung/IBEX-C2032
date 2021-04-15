open FILE,"usage_data/BL6_REP1.pAs.usage.txt";
<FILE>;
my $i = 0;
my $PAS_TYPE_FILTER = 'Yes';
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
	next if $polyASeqRC <= 5;
	next if $RNASeqRC   <= 10;
	next if $usage <=  0.05;
	next if $pas_type eq "ncRNA" && $PAS_TYPE_FILTER eq "Yes";
	next if $pas_type eq "intergenic" && $PAS_TYPE_FILTER eq "Yes";
	$i++;
}
print "$i\n";
