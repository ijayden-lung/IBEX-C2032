#!/usr/bin/perl -w
#

my $score_file = "../predict/THLE2_Control.pAs.single_kermax6.THLE2_Control_aug12_SC_p1r0.05u0.05_4-0006.chr1_+_1.txt";
my $coverage_file = "../../Split_BL6/THLE2_Control_data/chr1_+_1";
my $polya_file = "awk '(\$1==\"chr1\" && \$6==\"+\")' ../../Split_BL6/polyA_seq/stackTHLE2_1.bed |";
=pod
my $predict_PAS1 = "chr1:15428846:+";
my $predict_PAS2 = "chr1:15430207:+";
my $predict_PAS3 = "chr1:15430336:+";
my $annotate_PAS1 = "chr1:15428845:+";
my $annotate_PAS2 = "chr1:15430208:+";
my $annotate_PAS3 = "chr1:15430339:+";
my $chr = "chr1";
my $start = 15428846-200;
my $end   = 15430336+200;
open OUT,">../Figures/EFHD2.bedGraph";
=cut

=pod
my $predict_PAS1 = "chr1:27823772:+";
my $predict_PAS2 = "chr1:27824303:+";
my $predict_PAS3 = "chr1:27824448:+";
my $annotate_PAS1 = "chr1:27823768:+";
my $annotate_PAS2 = "chr1:27824305:+";
my $annotate_PAS3 = "chr1:27824443:+";
my $chr = "chr1";
my $start = 27823772-100;
my $end   = 27824448+100;
open OUT,">../Figures/STX12.bedGraph";
=cut

my $predict_PAS1 = "chr1:38023802:+";
my $predict_PAS2 = "chr1:38024829:+";
my $annotate_PAS1 = "chr1:38023803:+";
my $annotate_PAS2 = "chr1:38024820:+";
my $chr = "chr1";
my $start = 38023803-100;
my $end   = 38024829+100;
open OUT,">../Figures/UTP11.bedGraph";

print OUT "browser position $chr:$start-$end\n";
print OUT "#predicted PAS1:$predict_PAS1, annotate PAS1:$annotate_PAS1\n";
print OUT "#predicted PAS2:$predict_PAS2, annotate PAS2:$annotate_PAS2\n";
#print OUT "#predicted PAS3:$predict_PAS3, annotate PAS3:$annotate_PAS3\n";


my $score_ref  = &read_file($score_file);
my $score_track = "track type=bedGraph name=\"Prediction Score\" visibility=full color=200,100,0 altColor=0,100,200 priority=20";
&write_bedGraph($score_ref,$score_track);
my $coverage_ref  = &read_file($coverage_file);
my $coverage_track = "track type=bedGraph name=\"RNA-Seq RPM\" visibility=full color=255,0,0 altColor=0,100,200 priority=20";
&write_bedGraph($coverage_ref,$coverage_track);
my $polya_ref  = &read_polya_file($polya_file);
my $polya_track = "track type=bedGraph name=\"PolyA-Seq RPM\" visibility=full color=0,204,0 altColor=0,100,200 priority=20";
&write_bedGraph($polya_ref,$polya_track);

sub read_file{
	my ($file) = @_;
	my %hash;
	for(my$i=$start;$i<=$end;$i++){
		$hash{$i} = 0;
	}
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($pas_id,$score) = split;
		my ($chr,$pos,$strand) = split /\:/,$pas_id;
		if($start<=$pos && $end >= $pos){
			$hash{$pos} = $score;
		}
	}
	return \%hash;
}
sub read_polya_file{
	my ($file) = @_;
	my %hash;
	for(my$i=$start;$i<=$end;$i++){
		$hash{$i} = 0;
	}
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($chr,$pos,undef,$score) = split;
		if($start<=$pos && $end >= $pos){
			$hash{$pos} = $score/9;
		}
	}
	return \%hash;
}
sub write_bedGraph{
	my ($hash_ref,$track) = @_;
	my %hash = %$hash_ref;
	my $pre_score = $hash{$start};
	my $pre_pos = $start;
	print OUT "$track\n";
	foreach my $pos(sort{$a<=>$b} keys %hash){
		my $score = $hash{$pos};
		if($score != $pre_score){
			print OUT "$chr\t$pre_pos\t$pos\t$pre_score\n" if $pre_pos != 0;
			$pre_score = $score;
			$pre_pos = $pos;
		}
	}
	print OUT "$chr\t$pre_pos\t$end\t$pre_score\n";
}
