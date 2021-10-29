#!/usr/bin/perl -w
#
my %THLE2;
open FILE,"THLE2_Control.pAs.usage.txt";
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	$THLE2{$pas_id} = '';
}
my %thle2;
open FILE,"thle2_control.pAs.usage.txt";
while(<FILE>){
	chomp;
	my ($pas_id) = split;
	$thle2{$pas_id} = '';
	if(!exists $THLE2{$pas_id}){
		print "$pas_id\n";
	}
}
