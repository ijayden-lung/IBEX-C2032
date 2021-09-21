#!usr/bin/perl -w
open FILE,"test";
<FILE>;
open OUT,">test4";
print OUT "symbol\tpolyA_diff\tpredict_diff\n";
while(<FILE>){
	chomp;
	chomp;
	my ($pas_id,$pas_type,$symbol,$pr,$rr,$pu,$ru) = split;
	#my ($pas_id,$symbol,$pr,$rr,$pu,$ru) = split;
	next if $pu eq 1;
	my $next_line = <FILE>;
	chomp $next_line;
	my ($pas_id2,$pas_type2,$symbol2,$pr2,$rr2,$pu2,$ru2) = split /\t/,$next_line;
	my $poly_diff = $pu-$pu2;
	my $rna_diff = $ru-$ru2;
	print OUT "$symbol\t$poly_diff\t$rna_diff\n";
}
