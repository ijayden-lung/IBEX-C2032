#!/usr/bin/perl -w
#
#
#WRN Good Example
#B3GLCT Not Good in K562
#ELP5 very good
use ReadFile;
my %gene = (#"AP1AR"=>['chr4','+',112269096,112270053],
			#sequence	
			#"DKK1"=>['chr10','+',52316950,52318037],
			#RNASeq
			"BYSL"=>['chr6','+',41933043,41934380],
			"ACOT2"=>['chr14','+',73575848,73575057],
			);
&cell_line("SNU398","RNASeq");
sub cell_line{
	my ($cell,$type) = @_;
	my $rep;
	my $times  = 7.8;
	$rep = "SNU398_Control";
	my $block_dir = "../../Split_BL6/$rep\_data";
	my $anno_base = "../usage_data/$rep.pAs.merge.coverage.txt";
	my $pol_base = "../../Split_BL6/polyA_seq/stack$cell.bed";
	my $pos_base = "../Figures/$cell/predicted.txt";
	my $pos_base2 = "../Figures/$cell/predicted.$type.txt";
	open OUT,">../Figures/$cell/$cell.example.compare2$type.bedGraph";
	my @genes = keys %gene;
	print OUT join("\t","#gene",@genes),"\n";
	&main("anno",$cell,$block_dir,$anno_base,$times) if $cell eq "SNU398";
	&main("cov",$cell,$block_dir,undef,$times);
	&main("pol",$cell,$block_dir,$pol_base,$times);
	&main("pos","APAIQ",$block_dir,$pos_base,$times);
	&main("pos","$type Only",$block_dir,$pos_base2,$times);
}
sub main{
	my ($action,$cell,$block_dir,$base,$times) = @_;
	print "Taking action $action\n";
	my $count = 0;
	while(my ($symbol,$val) = each %gene){
		my $chr = $val->[0];
		my $strand = $val->[1];
		my $start = $val->[2]-1000;
		my $end   = $val->[3]+1000;
		print "$symbol\t$strand,$chr,$start,$end\n";
		my $block = &find_block($start,$end,$chr,$strand,$block_dir);
		$count++;
		if($action eq "anno"){
			my $anno_base = $base;
			if($count <=1){
				print OUT "browser position $chr:$start-$end\n";
			}
			my $anno_file = "awk '(\$3==\"$chr\" && \$5==\"$strand\")' $anno_base |";
			my $anno_ref  = &read_file($anno_file,$start,$end,1);
			my $anno_track = "track type=bedGraph name=\"Annotated PAS\" visibility=dense color=200,100,100 altColor=0,100,200 priority=20";
			print OUT "$anno_track\n" if($count <=1);
			&write_bedGraph($anno_ref,$chr,$start,$end);
		}
		elsif($action eq "score"){
			my $score_base = $base;
			my $score_file = "$score_base.$chr\_$strand\_$block.txt";
			my $score_ref  = &read_file($score_file,$start,$end,0);
			my $score_track = "track type=bedGraph name=\"$cell Prediction Score\" visibility=full color=200,100,0 altColor=0,100,200 priority=20";
			print OUT "$score_track\n" if $count <=1;
			&write_bedGraph($score_ref,$chr,$start,$end);
		}
		elsif($action eq "cov"){
			my $coverage_file = "$block_dir/$chr\_$strand\_$block";
			my $coverage_ref  = &read_file($coverage_file,$start,$end,0);
			my $coverage_track = "track type=bedGraph name=\"$cell RNA-Seq RPM\" visibility=full color=255,0,0 altColor=0,100,200 priority=20";
			print OUT "$coverage_track\n" if $count <=1;
			&write_bedGraph($coverage_ref,$chr,$start,$end);
		}
		elsif($action eq "pol"){
			my $pol_base = $base;
			my $polya_file = "awk '(\$1==\"$chr\" && \$6==\"$strand\")' $pol_base |";
			my $polya_ref  = &read_polya_file($polya_file,$start,$end,$times);
			my $polya_track = "track type=bedGraph name=\"$cell PolyA-Seq RPM\" visibility=full color=0,204,0 altColor=0,100,200 priority=20";
			print OUT "$polya_track\n" if $count <=1;
			&write_bedGraph($polya_ref,$chr,$start,$end);
		}
		elsif($action eq "pos"){
			my $pos_base = $base;
			my $pos_file = "grep $chr $pos_base | grep $strand | ";
			my $position_ref = &read_position_file($pos_file,$start,$end);
			my $position_track = "track type=bedGraph name=\"$cell Predicted Position\" visibility=full color=0,204,255 altColor=0,100,200 priority=20 alwaysZero=on yLineMark=0 yLineOnOff=on";
			print OUT "$position_track\n" if $count <=1;
			&write_bedGraph_withoutzero($position_ref,$chr,$start,$end);
		}
	}
}

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
	my ($hash_ref,$chr,$start,$end) = @_;
	my %hash = %$hash_ref;
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
}


sub write_bedGraph_withoutzero{
	my ($hash_ref,$chr,$start,$end) = @_;
	my %hash = %$hash_ref;
	foreach my $pos(sort{$a<=>$b} keys %hash){
		my $score = $hash{$pos};
		if($score != 0){
			my $pre_pos = $pos-1;
			print OUT "$chr\t$pre_pos\t$pos\t$score\n";
		}
	}
}
