#!/usr/bin/perl -w
use strict;
=use
cut the leading multiple nucleotides with the giving pattern. i.e. 
leading T: ^T{1+}...
=cut

sub trimLeadingN {
	my ($inputfq,$outputfq,$pattern) = @_;
	if($inputfq =~ /gz$/){
		print "file is gzip \n";
		open IN,"zcat $inputfq | " or die $!;
	}else{
		open IN,"$inputfq" or die $!;
	}
	open OUT,">$outputfq" or die $!;
	my $t = 0; my $m = 0;
	while(<IN>){
		chomp;
		$t ++;
		my $head = $_;
		my $seq = <IN>;
		chomp $seq; 
		my $plus = <IN>;
		chomp $plus;
		my $qua = <IN>;
		chomp $qua;
		if($seq =~ /$pattern/){
			$m ++;
			$seq =~ s/$pattern//;
			$qua = substr($qua,length($qua) - length($seq));
		}
		print OUT "$head\n$seq\n$plus\n$qua\n";
	}
	close IN;
	close OUT;
	print "$m out of $t reads contaning $pattern, which have been trimmed\n";
	#system("gzip $outputfq");
}

if(@ARGV < 3){
	print "usage:input_fastq\toutput_fastq\tpattern\n";
	exit(0);
}else{
	&trimLeadingN($ARGV[0],$ARGV[1],$ARGV[2]);
}

