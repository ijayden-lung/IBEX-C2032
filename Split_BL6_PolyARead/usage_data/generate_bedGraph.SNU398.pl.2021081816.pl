#!/usr/bin/perl -w
#

my $chr = "chr7";
my $strand = "+";
my $start = 131487965-100;
my $end   = 131496632+100;
my $block_dir = "../../Split_BL6/SNU398_Control_data";
my $block = &find_block($start,$end,$chr,$strand,$block_dir);
my $score_file = "../predict/SNU398_Control.pAs.single_kermax6.SNU398_Control_aug12_SC_p1r0.05u0.05_4-0025.$chr\_$strand\_$block.txt";
my $coverage_file = "$block_dir/$chr\_$strand\_$block";
my $polya_file = "awk '(\$1==\"$chr\" && \$6==\"$strand\")' ../../Split_BL6/polyA_seq/stackSNU398.bed |";
my $pos_file = "../Figures/SNU398/predicted.txt";
my $times = 7.8;
open OUT,">../Figures/SNU398/SNU398.MKLN1.bedGraph";

print OUT "browser position $chr:$start-$end\n";
#print OUT "#annotated pas not predicted $PAS\n";
#print OUT "#predicted PAS1:$predict_PAS1, annotate PAS1:$annotate_PAS1\n";
#print OUT "#predicted PAS2:$predict_PAS2, annotate PAS2:$annotate_PAS2\n";
#print OUT "#predicted PAS3:$predict_PAS3, annotate PAS3:$annotate_PAS3\n";

my $score_ref  = &read_file($score_file);
my $score_track = "track type=bedGraph name=\"SNU398 Prediction Score\" visibility=full color=200,100,0 altColor=0,100,200 priority=20";
&write_bedGraph($score_ref,$score_track);
my $coverage_ref  = &read_file($coverage_file);
my $coverage_track = "track type=bedGraph name=\"SNU398 RNA-Seq RPM\" visibility=full color=255,0,0 altColor=0,100,200 priority=20";
&write_bedGraph($coverage_ref,$coverage_track);
my $polya_ref  = &read_polya_file($polya_file,$chr,$strand,$times);
my $polya_track = "track type=bedGraph name=\"SNU398 PolyA-Seq RPM\" visibility=full color=0,204,0 altColor=0,100,200 priority=20";
&write_bedGraph($polya_ref,$polya_track);
my $position_ref = &read_position_file($pos_file,$chr,$strand);
my $position_track = "track type=bedGraph name=\"SNU398 Predicted Position\" visibility=full color=0,204,255 altColor=0,100,200 priority=20 yLineMark=12 yLineOnOff=on";
&write_bedGraph($position_ref,$position_track);


sub find_block{
	my ($start,$end,$chr,$strand,$block_dir) = @_;
	open FILE,"$block_dir/info.txt";
	my $Block = 0;
	while(<FILE>){
		chomp;
		my ($block_id,$open,$close) = split;
		my ($ch,$str,$block) = split /\_/,$block_id;
		if($ch eq $chr && $str eq $strand && $open < $start && $close > $end){
			print "block is is $block_id\n";
			$Block = $block;
		}
	}
	return $Block;
}

				


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
			print OUT "$chr\t$pre_pos\t$pos\t$pre_score\n" if $pre_pos != 0;
			$pre_score = $score;
			$pre_pos = $pos;
		}
	}
	print OUT "$chr\t$pre_pos\t$end\t$pre_score\n";
}
