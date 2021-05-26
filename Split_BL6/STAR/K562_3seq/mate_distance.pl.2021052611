#!/usr/bin/perl -w

use Bio::Cigar;

my $Cigar = Bio::Cigar->new("50M1000N61M");
my $ops_ref = $Cigar->ops;
print "$ops_ref->[-2]->[0],$ops_ref->[-2]->[1]\n";



sub getSkip{
	my ($ops_ref) = @_;
	my @skip;
	foreach my $operation (@$ops_ref){
		if($operation->[1] eq "N"){
			push @skip,$operation->[0];
		}
	}
	return @skip;
}

open FILE, "samtools view -f 2 -q 255 Aligned.out.bam | ";
open OUT, ">Mate.distance.txt";
while(<FILE>){
	chomp;
	my ($read,$flag1,$chr,$coor1,$cigar1) = (split /\t/)[0,1,2,3,5];
	my $line2 = <FILE>;
	chomp $line2;
	my ($flag2,$coor2,$cigar2) = (split /\t/,$line2)[1,3,5];
	my $distance;
	my $strand;
	my $Cigar1 = Bio::Cigar->new($cigar1);
	my $Cigar2 = Bio::Cigar->new($cigar2);
	if($flag1 == 163 && $flag2==83){
		$coor1 += $Cigar1->reference_length;
		$coor2 += $Cigar2->reference_length;
		$distance = $coor2-$coor1;
		$strand = "+";
	}
	elsif($flag1 == 99 && $flag2==147){
		$distance = $coor1-$coor2;
		$strand = "-";
	}
	else{
		print "unproper mapped\n$read\n";
	}
	if (abs($distance)>1000){
		my $ops_ref1 = $Cigar1->ops;
		my $ops_ref2 = $Cigar2->ops;
		my @skip1 = &getSkip($ops_ref1);
		my @skip2 = &getSkip($ops_ref2);
		if($flag1 == 163 && $flag2==83){
			if(!@skip2){
				print OUT "$read\t$chr\t$strand\t$coor1\t$cigar1\t$coor2\t$cigar2\t$distance\n";
			}
		}
		elsif($flag1 == 99 && $flag2==147){
			if(!@skip1){
				print OUT "$read\t$chr\t$strand\t$coor1\t$cigar1\t$coor2\t$cigar2\t$distance\n";
			}
		}
	}
}

