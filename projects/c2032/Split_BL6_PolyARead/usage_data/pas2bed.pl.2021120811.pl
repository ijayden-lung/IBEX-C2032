#!/usr/bin/perl -w

open FILE,"THLE2_Control.pAs.usage.txt";
<FILE>;
while(<FILE>){
	my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol) = split;
