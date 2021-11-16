#!/usr/bin/perl -w
my %pas_fwd;
my %pas_rev;
my %type;
my @type;
open FILE,"/ibex/scratch/longy/workspace/apa_predict/pas_dataset/Parental/bl.pAs.sequence.txt";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$coordinate) = split;
	my ($bl6,$spr) = split /,/,$coordinate;
	my ($chr,$srd,$spe,$mid) = split /\|/,$bl6;
	my $beg = $mid-100;
	my $end = $mid+100;
	if($spe eq "BL"){
		$type{"$pas_id\t$pas_type"} = "$chr:$beg-$end";
		push @type, "$pas_id\t$pas_type";
		if($srd eq "+"){
			$pas_rev{$chr}->{$mid} = '';
		}
		else{
			$pas_fwd{$chr}->{$mid} = '';
		}
	}
}

open FILE,"/ibex/scratch/longy/workspace/apa_predict/STAR/BL6_REP1/Signal.Unique.str2.out.wig";
my @sortCoor;
my $i=0;
my $str=-100;
my $chr = "chr1";
my $j = 0;
my %cov;
while(<FILE>){
	chomp;
	my ($pos,$read) = split;
	if($pos eq "variableStep"){
		(undef,$chr) = split /\=/,$read;
		if(exists $pas_fwd{"chr$chr"}){
			my $pos = $pas_fwd{"chr$chr"};
			@sortCoor = sort{$a<=>$b} keys %$pos;
			my $len = @sortCoor;
			#print "chr$chr $len\n";
			$i=0;
			$j=0;
		}
	}
	elsif(exists $pas_fwd{"chr$chr"}){
		#next if $j>0;
		#print "chr:$chr\n";
		#print "$sortCoor[0]\n";
		#$j++;
		if($i >= @sortCoor || $pos < $sortCoor[$i]-100){
			next;
		}
		elsif($pos > $sortCoor[$i]+100){
			$i++;
			$str=-100;
		}
		else{
			my $beg = $sortCoor[$i]-100;
			my $end = $sortCoor[$i]+100;
			$cov{"chr$chr:$beg-$end"} .= "\t$read";
		}
	}
}

open OUT,">Coverage_BL6_REP1.txt";
foreach my $id (@type){
	my $key = $type{$id};
	next if !exists $cov{$key};
	my $val = $cov{$key};
#while(my($key,$val) = each %cov){
	my @data = split /\t/,$val;
	if (@data <202){
		my $len = 202-@data;
		my @new = (0)x$len;
		print OUT "$id\t$key";
		print OUT join "\t",$val,@new;
		print OUT "\n";
	}
	else{
		print OUT "$id\t$key";
		print OUT "$val\n";
	}
}

open OUT,">Coverage_BL6_REP1_old.txt";
while(my($key,$val) = each %cov){
	my @data = split /\t/,$val;
	if (@data <201){
		my $len = 201-@data;
		my @new = (0)x$len;
		print OUT join "\t",$key,$val,@new;
		print OUT "\n";
	}
	else{
		print OUT "$key\t$val\n";
	}
}
