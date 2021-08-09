#!/usr/bin/perl -w
#

open FILE,"../predict/THLE2_Control.pAs.single_kermax6.THLE2_Control_aug12_SC_p1r0.05u0.05_4-0006.chr1_+_0.txt";
my $predict_PAS1 = "chr1:6872040:+";
my $predict_PAS2 = "chr1:6888208:+";
my $annotate_PAS1 = "chr1:6872020:+";
my $annotate_PAS2 = "chr1:6888201:+";
my $chr = "chr1";
my $start = 6872040-1000;
my $end   = 6888208+1000;

open OUT,">../Figures/CAMTA1.bedGraph";
print OUT "browser position $chr:$start-$end\n";
print OUT "#predicted PAS1:$predict_PAS1, annotate PAS1:$annotate_PAS1\n";
print OUT "#predicted PAS2:$predict_PAS2, annotate PAS2:$annotate_PAS2\n";
print OUT "track type=bedGraph name=\"Prediction Score\" visibility=full color=200,100,0 altColor=0,100,200 priority=20\n";

my %hash;
for(my$i=$start;$i<=$end;$i++){
	$hash{$i} = 0;
}

while(<FILE>){
	chomp;
	my ($pas_id,$score) = split;
	my ($chr,$pos,$strand) = split /\:/,$pas_id;
	if($start<=$pos && $end >= $pos){
		$hash{$pos} = sprintf("%.2f",$score);
	}
}

my $pre_score = $hash{$start};
my $pre_pos = $start;
foreach my $pos(sort{$a<=>$b} keys %hash){
	my $score = $hash{$pos};
	if($score != $pre_score){
		print OUT "$chr\t$pre_pos\t$pos\t$pre_score\n" if $pre_pos != 0;
		$pre_score = $score;
		$pre_pos = $pos;
	}
}
print OUT "$chr\t$pre_pos\t$end\t$pre_score\n";
