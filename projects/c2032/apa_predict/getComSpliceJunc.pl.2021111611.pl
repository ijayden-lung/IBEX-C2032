#!/usr/bin/perl -w
my %junc;
open FILE,"STAR/BL6_REP1/SJ.out.tab";
while(<FILE>){
	chomp;
	my ($chr,$str,$end,$srd,$motif,$anno,$uniq,$multi,$overhang) = split;
	if($anno ==0){
		if($motif != 0 && $uniq >10){
			$junc{"$chr:$str-$end,$srd"} = $_;
		}
		elsif($uniq>50){
			$junc{"$chr:$str-$end,$srd"} = $_;
		}
	}
}
open FILE,"STAR/BL6_REP2/SJ.out.tab";
while(<FILE>){
	chomp;
	my ($chr,$str,$end,$srd,$motif,$anno,$uniq,$multi,$overhang) = split;
	if($anno ==0){
		if($motif != 0 && $uniq >10){
			$junc{"$chr:$str-$end,$srd"} = $_;
		}
		elsif($uniq>50){
			$junc{"$chr:$str-$end,$srd"} = $_;
		}
	}
}
open FILE,"STAR/BL6_REP3/SJ.out.tab";
while(<FILE>){
	chomp;
	my ($chr,$str,$end,$srd,$motif,$anno,$uniq,$multi,$overhang) = split;
	if($anno ==0){
		if($motif != 0 && $uniq >10){
			$junc{"$chr:$str-$end,$srd"} = $_;
		}
		elsif($uniq>50){
			$junc{"$chr:$str-$end,$srd"} = $_;
		}
			
	}
}
open OUT,">BL6_SJ.out.tab";
while(my($key,$val) = each %junc){
	print OUT "$val\n";
}
