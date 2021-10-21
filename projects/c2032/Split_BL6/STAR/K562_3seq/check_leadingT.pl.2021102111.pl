#!/usr/bin/perl -w

open FILE,"zcat K562-3-seq_cutadapt_R1_001.fastq.gz | ";
while(<FILE>){
	chomp;
	if($. %4 ==2){
		if($_ !~ /^TT/){
			print "$_\n";
		}
	}
}
