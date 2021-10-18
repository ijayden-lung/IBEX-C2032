#!/usr/bin/perl -w
#

my %hash;
&read("modhuman_brain_2.bed");
print "Finished read file 1\n";

#&read("modhuman_brain_2.bed");
#print "Finished read file 2\n";
my $output = "stackhuman_brain_2.bed";
open OUT,">$output.tmp";
#print OUT "position\treadCount\n";

sub read{
	my ($file) = @_;
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($chr,undef,$pos,undef,undef,$strand) = split;
		next if $chr =~ /KI|GL|Y|MT/;
		if($strand eq "+"){
			$strand = "-";
		}
		else{
			$strand = "+";
		}
		$hash{"$chr:$pos:$strand"}++;
	}
}

foreach my $key (keys %hash){
	my ($chr,$pos,$strand) = split /\:/,$key;
	my $pos0 = $pos-1;
	my $val = $hash{$key}/2;
	print OUT "$chr\t$pos0\t$pos\t$val\t255\t$strand\n";
}

system("sort -k1,1 -k6,6 -k2,2n -S 30G $output.tmp -o $output");
system("rm $output.tmp");
