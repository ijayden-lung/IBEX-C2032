#!/usr/bin/perl -w

my %seq;
foreach my $file (glob "/home/longy/workspace/DeeReCT-PolyA/data/mouse/bl_mouse/positive/*"){
	open FILE,$file;
	while(<FILE>){
		chomp;
		$seq{$_} = '';
	}
}

my %pas;
open FILE,"bl6.pAs.zhangbin.fibroblast.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($id) = split;
	$pas{$id} = '';
}

open FILE,"Parental/bl.pAs.sequence.txt";
<FILE>;
open OUT,">bl6.sequence.zhangbin.fibroblast2.txt";
while(<FILE>){
	chomp;
	my ($id,undef,undef,$seq) = split;
	if(exists $pas{$id}){
		foreach my $key (keys %seq){
			if($seq =~ /$key/){
				print OUT "$key\n";
				undef $seq{$key};
				next;
			}
		}
	}

}
