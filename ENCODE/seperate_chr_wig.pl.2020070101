#!/usr/bin/perl -w

my ($wig) = @ARGV;
my $out = substr($wig,0,-4);
open FILE,"$wig";
while(<FILE>){
	chomp;
	my ($pos,$read) = split;
	if($pos eq "variableStep"){
		(undef,$chr) = split /\=/,$read;
		$chr="chr$chr" if $chr !~ /^chr/;
		open OUT,">$out.$chr.wig";
		print OUT "$_\n";
	}
	else{
		print OUT "$_\n";
	}
}
