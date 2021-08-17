#!/usr/bin/perl -w
#

my $score_file = "../predict/SNU398_Control.pAs.single_kermax6.SNU398_Control_aug12_SC_p1r0.05u0.05_4-0025.chr5_-_2.txt";
my $coverage_file = "../../Split_BL6/SNU398_Control_data/chr5_-_2";
my $polya_file = "awk '(\$1==\"chr5\" && \$6==\"-\")' ../../Split_BL6/polyA_seq/stackSNU398_1.bed |";
my $pos_file = "../Figures/SNU398/predicted.txt";
my $times = 7.8;
#my $predict_PAS1 = "chr1:38023802:+";
#my $predict_PAS2 = "chr1:38024829:+";
#my $annotate_PAS1 = "chr1:38023803:+";
#my $annotate_PAS2 = "chr1:38024820:+";
#my $PAS = "chr13:45536625:+";
my $chr = "chr5";
my $strand = "-";
my $start = 50393447-100;
my $end   = 50398639+100;
open OUT,">../Figures/SNU398/EMB.bedGraph";

print OUT "browser position $chr:$start-$end\n";
#print OUT "#annotated pas not predicted $PAS\n";
#print OUT "#predicted PAS1:$predict_PAS1, annotate PAS1:$annotate_PAS1\n";
#print OUT "#predicted PAS2:$predict_PAS2, annotate PAS2:$annotate_PAS2\n";
#print OUT "#predicted PAS3:$predict_PAS3, annotate PAS3:$annotate_PAS3\n";


my $score_ref  = &read_file($score_file);
my $score_track = "track type=bedGraph name=\"Prediction Score\" visibility=full color=200,100,0 altColor=0,100,200 priority=20";
&write_bedGraph($score_ref,$score_track);
my $coverage_ref  = &read_file($coverage_file);
my $coverage_track = "track type=bedGraph name=\"RNA-Seq RPM\" visibility=full color=255,0,0 altColor=0,100,200 priority=20";
&write_bedGraph($coverage_ref,$coverage_track);
my $polya_ref  = &read_polya_file($polya_file,$chr,$strand,$times);
my $polya_track = "track type=bedGraph name=\"PolyA-Seq RPM\" visibility=full color=0,204,0 altColor=0,100,200 priority=20";
&write_bedGraph($polya_ref,$polya_track);
my $position_ref = &read_position_file($pos_file,$chr,$strand);
my $position_track = "track type=bedGraph name=\"Predicted Position\" visibility=full color=0,204,255 altColor=0,100,200 priority=20";
&write_bedGraph($position_ref,$position_track);

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
	my ($file,$chromosome,$strand,$times) = @_;
	my %hash;
	for(my$i=$start;$i<=$end;$i++){
		$hash{$i} = 0;
	}
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($chr,$pos,undef,$score,undef,$srd) = split;
		next if $strand ne $srd;
		next if $chromosome ne $chr;
		if($start<=$pos && $end >= $pos){
			print "$chr\t$chromosome\n";
			$hash{$pos} = $score/$times;
		}
	}
	return \%hash;
}
sub read_position_file{
	my ($file,$chromosome,$strand) = @_;
	my %hash;
	for(my$i=$start;$i<=$end;$i++){
		$hash{$i} = 0;
	}
	open FILE,"$file";
	<FILE>;
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$score) = (split)[0,-1];
		my ($chr,$pos,$srd) = split /\:/,$pas_id;
		next if $srd ne $strand;
		next if $chromosome ne $chr;
		if($start<=$pos && $end >= $pos){
			#print "$chr\t$chromosome\n";
			$hash{$pos} = $score;
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
			$pre_score = $score;
			$pre_pos = $pos;
		}
	}
	print OUT "$chr\t$pre_pos\t$end\t$pre_score\n";
}
