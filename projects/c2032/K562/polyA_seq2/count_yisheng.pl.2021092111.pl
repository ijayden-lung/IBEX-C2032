#!/usr/bin/perl -w
#
open FILE,"k562_sg_con.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($hg37_pasid,$con1,$con2) = split;
	if($con1+$con2>10){
		print "$_\n";
	}
}
