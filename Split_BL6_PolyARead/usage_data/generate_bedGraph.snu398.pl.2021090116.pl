#!/usr/bin/perl -w
#
#
use ReadFile;
my $chr = "chr7";
my $strand = "+";
my $start = 36453429-300;
my $end   = 36453784+300;
my $symbol = "ANLN";

my $block_dir = "../../Split_BL6/snu398_control_data";
my $block = &find_block($start,$end,$chr,$strand,$block_dir);
my $score_file = "../predict/snu398_control.pAs.single_kermax6.snu398_control_aug12_SC_p1r0.05u0.05_4-0038.$chr\_$strand\_$block.txt";
my $coverage_file = "$block_dir/$chr\_$strand\_$block";
my $polya_file = "awk '(\$1==\"$chr\" && \$6==\"$strand\")' ../../Split_BL6/polyA_seq/stackSNU398.bed |";
my $anno_file = "awk '(\$3==\"$chr\" && \$5==\"$strand\")' SNU398_Control.pAs.merge.coverage.txt |";
my $pos_file = "grep $chr ../Figures/SNU398/predicted.txt | grep $strand | ";
my $times = 7.8;
open OUT,">../Figures/SNU398/SNU398.$symbol.bedGraph";

print OUT "browser position $chr:$start-$end\n";

my $anno_ref  = &read_file($anno_file,$start,$end,1);
my $anno_track = "track type=bedGraph name=\"Annotated PAS\" visibility=full color=200,100,100 altColor=0,100,200 priority=20";
&write_bedGraph($anno_ref,$anno_track);
my $score_ref  = &read_file($score_file,$start,$end,0);
my $score_track = "track type=bedGraph name=\"SNU398 Prediction Score\" visibility=full color=200,100,0 altColor=0,100,200 priority=20";
&write_bedGraph($score_ref,$score_track);
my $coverage_ref  = &read_file($coverage_file,$start,$end,0);
my $coverage_track = "track type=bedGraph name=\"SNU398 RNA-Seq RPM\" visibility=full color=255,0,0 altColor=0,100,200 priority=20";
&write_bedGraph($coverage_ref,$coverage_track);
my $polya_ref  = &read_polya_file($polya_file,$start,$end,$times);
my $polya_track = "track type=bedGraph name=\"SNU398 PolyA-Seq RPM\" visibility=full color=0,204,0 altColor=0,100,200 priority=20";
&write_bedGraph($polya_ref,$polya_track);
my $position_ref = &read_position_file($pos_file,$start,$end);
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
