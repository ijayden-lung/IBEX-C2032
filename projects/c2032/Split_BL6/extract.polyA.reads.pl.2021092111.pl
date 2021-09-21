#!/usr/bin/perl -w
#
#
#
#From Bin Zhang
#Modified by Yongkang Long
#2021/01/03
#Fixed strandness problems.
#Add idendity parameter to control the error rate in A/T rich section 
#2021/01/04
#Fixed positions calculation problems.


use strict;
use Bio::Cigar;
=use
extract non-template polyA reads from Bam file or fastq/fasta file ...
...
=cut

my $polyAcut = 3;
my $identity = 0.8;

### get alignment score from sam file columns 
sub getAS {
	my @Columns = @_;
	my $AS = "";
	for(11..$#Columns){
		my $p = $_;
		if($Columns[$p] =~ /AS:/){
			$AS = $Columns[$p];
			$AS =~ s/\D//g; 
		}
	}
	return($AS);
}

### extract polyA/polyT reads from bam file for paired-end RNA-seq data 
sub extractFromPEBam{
	my ($bam,$out) = @_;
	print "open the bam file $bam\n";
	open IN,"-|","samtools view -q 255 $bam" or die $!; ###Uniq mapped reads
	#open IN,"-|","samtools view -q 255 $bam | head -n 1000000" or die $!; ###Uniq mapped reads
	#open IN,"-|","samtools sort -n  $bam" or die $!;
	open OUT,">$out" or die $!;
	## counting the number of 5', 3' and no softclip reads, as well as polyA reads and polyT reads
	my $sc5 = 0; my $sc3 = 0;my $ns = 0;my $polyan = 0; my $polytn = 0;
	my $i = 0;
	while(<IN>){
		chomp;
		next if (/^@/);
		my $line1 = $_;
		my $line2 = <IN>;
		chomp $line2;
		my @Columns1 = split(/\s+/,$line1);
		my @Columns2 = split(/\s+/,$line2);
		if($Columns1[0] ne $Columns2[0]){
			$line1 = $line2;
			$line2 = <IN>;
			chomp $line2;
			@Columns2 = split(/\s+/,$line2);
			if($Columns1[0] ne $Columns2[0]){
				print "error:bam file were not sorted by read name for paired-end RNA-seq data\n";
				last;
			}
		}
		$i ++;
		print "processed $i reads\n" if($i % 1000000 == 0);
		#if(($Columns2[5] !~ /(([$polyAcut-9]|[0-9]\d+)S)$/) and ($Columns1[5] !~ /^(([$polyAcut-9]|[0-9]\d+)S)/)){
		if(($Columns1[5] !~ /(([$polyAcut-9]|[1-9]\d+)S)$/) and ($Columns1[5] !~ /^(([$polyAcut-9]|[1-9]\d+)S)/)){
			$ns ++;
		}else{
			### read2 contaning soft-clipped polyA 
			#if($Columns2[5] =~ /(([$polyAcut-9]|[1-9]\d+)S)$/){
			if($Columns1[1] == 83 && $Columns1[5] =~ /(([$polyAcut-9]|[1-9]\d+)S)$/){
				## skip juncion reads 
				next if($Columns1[5] =~ /N/);
				## skip secondary alignment,not passing filters and PCR duplication 
				#next if($Columns2[1] & 256);
				#next if($Columns2[1] & 512);
				#next if($Columns2[1] & 1024);
				$sc3 ++;
				my $AS = &getAS(@Columns1);
				my $cigar = Bio::Cigar->new($Columns1[5]);
				my $ref_len = $cigar->reference_length;
				my $index = $1;
				$index =~ s/\D//g;
				my $subseq = substr($Columns1[9],length($Columns1[9])-$index);
				my $count = () = $subseq =~ /A/g;
				if ($count >= $polyAcut && $count/length($subseq)>$identity){
				#if($Columns1[9] =~ /(A)\1{$polyAcut,}$/){
					$polyan ++;
					#my $end = $Columns1[3] + length($Columns1[9]) - $index-1;
					my $end = $Columns1[3] + $ref_len-1;
					print OUT "$Columns1[2]\t$Columns1[3]\t$end\t$Columns1[0]\t$AS\t+\n";
				}
			}
			### read1 contaning soft-clipped polyT 
			if($Columns1[1] == 99 && $Columns1[5] =~ /^(([$polyAcut-9]|[1-9]\d+)S)/){
				## skip juncion reads 
				next if($Columns1[5] =~ /N/);
				## skip secondary alignment,not passing filters and PCR duplication 
				#next if($Columns1[1] & 256);
				#next if($Columns1[1] & 512);
				#next if($Columns1[1] & 1024);
				$sc5 ++;
				my $AS1 = &getAS(@Columns1);
				my $cigar = Bio::Cigar->new($Columns1[5]);
				my $ref_len = $cigar->reference_length;
				my $index = $1;
				$index =~ s/\D//g;
				my $subseq = substr($Columns1[9],0,$index);
				my $count = () = $subseq =~ /T/g;
				if ($count >= $polyAcut && $count/length($subseq)>$identity){
				#if($Columns1[9] =~ /^(T)\1{$polyAcut,}/){
					$polytn ++;
					#my $end = $Columns1[3] + length($Columns1[9]) - $index-1;
					my $end = $Columns1[3] + $ref_len-1;
					print OUT "$Columns1[2]\t$Columns1[3]\t$end\t$Columns1[0]\t$AS1\t\-\n";
				}
			}
		}
	}
	close IN;
	close OUT;
	print "#5softclip\t3softclip\tnonsoftclip\tpolya\tpolyt\n";
	print "$sc5\t$sc3\t$ns\t$polyan\t$polytn\n";	
}

if(@ARGV < 3){
	print "Usage:input_bam\toutput_bed\tSE or PE\n";
}else{
	$polyAcut = $ARGV[3] if(defined $ARGV[3]);
	if($ARGV[2] =~ /SE/){
		&extractFromSEBam($ARGV[0],$ARGV[1]);
	}elsif($ARGV[2] =~ /PE/){
		&extractFromPEBam($ARGV[0],$ARGV[1]);
	}else{
		print "error:RNA-seq data is undermined, it should be either SE or PE\n";
	}
#	print "polyAcut is $polyAcut\n";
}


