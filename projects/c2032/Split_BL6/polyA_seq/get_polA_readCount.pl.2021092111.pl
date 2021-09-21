#!/usr/bin/perl -w
#


open FILE,"awk '(\$1==\"chr5\" && \$6 == \"-\")'  modSNU398_2.bed |";
#open FILE,"awk '(\$1==\"chr1\" && \$6 == \"+\")'  modK562_Chen.bed |";

open OUT,">polyA_distribution.txt";
print OUT "position\treadCount\n";


#my $start = 1216887-200;
#my $end   = 1217071+200;
my $start = 256690-100;
my $end   = 256690+100;



my $middle  = ($start+$end)/2;

my %hash;
for(my$i=$start+1;$i<$end;$i++){
	$hash{$i-$middle} = 0;
}
my $count=0;
while(<FILE>){
	chomp;
	my ($chr,undef,$pos,undef,undef,$strand) = split;
	if($pos eq "256679"){
		$count++;
	}
		
	if($start<$pos && $end > $pos){
		my $relative_pos = $pos-$middle;
		if($strand eq "+"){
			$hash{-$relative_pos}++
		}
		else{
			$hash{$relative_pos}++
		}

	}
}
print"$count\n";

foreach my $key(sort{$b<=>$a} keys %hash){
	print OUT "$key\t$hash{$key}\n";
}
