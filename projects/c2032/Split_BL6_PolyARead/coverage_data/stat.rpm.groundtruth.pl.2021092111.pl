#!/usr/bin/perl -w
#
my $thle_file = "THLE2_Control.usage.1.txt";
my $thle_file2 = "../usage_data/THLE2_Control.pAs.usage.txt";
open OUT2,">../Figures/stat.gt_threshold.txt";
print OUT2 "RPM\tnum_groundtruth\tnum_predicted\tnum_true_pos\trecall\tprecision\tannotated%\tannotated_highusage%\tannotated_lowusage%\tunannotated%\tunannotated_highusage%\tunannotated_lowusage%\thighusage%\thighusage_annotated%\thighusage_unannotated%\tlowusage%\tlowusage_annotated%\tlowusage_unannotated%\n";
my @thle_thre = qw/1 3 5 9 18 27/;
my @rpm = qw/0.1 0.3 0.5 1 2 3/;
for (my$i=0;$i<@thle_thre;$i++){
	&statistics($i,$thle_file2);
}
sub statistics{
	my ($i,$file2) = @_;
	my $threshold = $thle_thre[$i];
	my $file = "THLE2_Control.usage.$threshold.txt";
	my $ground_truth =  &count_polyAread($file2,$threshold);
	open FILE,"$file";
	<FILE>;
	my $total = 0;
	my $polyA_correct = 0;
	my $annotated = 0;
	my $unannotated = 0;
	my $anno_high  = 0;
	my $anno_low = 0;
	my $unan_high = 0;
	my $unan_low = 0;
	my $high = 0;
	my $high_anno = 0;
	my $high_unan = 0;
	my $low = 0;
	my $low_anno = 0;
	my $low_unan = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$is_ground_true,$nearest_pas,$symbol,$pas_type,undef,undef,$usage,$polyA_readcount) = split;
		$total++;
		my $predict_pos = (split /\:/,$pas_id)[1];
		my $true_pos    = (split /\:/,$nearest_pas)[1];
		my $diff = abs($predict_pos-$true_pos);
		if(abs($diff)<25){
			$annotated++;
			if($usage>=0.05){
				$anno_high++;
			}
			else{
				$anno_low++;
			}
		}
		else{
			$unannotated++;
			if($usage>=0.05){
				$unan_high++;
			}
			else{
				$unan_low++;
			}
		}
		if($usage>=0.05){
			$high++;
			if(abs($diff)<25){
				$high_anno++;
			}
			else{
				$high_unan++;
			}
		}
		else{
			$low++;
			if(abs($diff)<25){
				$low_anno++;
			}
			else{
				$low_unan++;
			}
		}
		if($is_ground_true eq "True"){
			$polyA_correct++;
		}
	}
		my $rpm = $rpm[$i];
		my $recall = sprintf("%.2f",$polyA_correct/$ground_truth*100);
		my $precision = sprintf("%.2f",$polyA_correct/$total*100);
		my $per_anno = sprintf("%.2f",$annotated/$total*100);
		my $per_anhi = sprintf("%.2f",$anno_high/$annotated*100);
		my $per_anlo = sprintf("%.2f",$anno_low/$annotated*100);
		my $per_unan = sprintf("%.2f",$unannotated/$total*100);
		my $per_unhi = sprintf("%.2f",$unan_high/$unannotated*100);
		my $per_unlo = sprintf("%.2f",$unan_low/$unannotated*100);

		my $per_high = sprintf("%.2f",$high/$total*100);
		my $per_hian = sprintf("%.2f",$high_anno/$high*100);
		my $per_hiun = sprintf("%.2f",$high_unan/$high*100);
		my $per_low  = sprintf("%.2f",$low/$total*100);
		my $per_loan = sprintf("%.2f",$low_anno/$low*100);
		my $per_loun = sprintf("%.2f",$low_unan/$low*100);

		print OUT2 "$rpm\t$ground_truth\t$total\t$polyA_correct\t$recall\t$precision\t$per_anno\t$per_anhi\t$per_anlo\t$per_unan\t$per_unhi\t$per_unlo\t$per_high\t$per_hian\t$per_hiun\t$per_low\t$per_loan\t$per_loun\n";
}


sub count_polyAread{
	my ($file,$threshold) = @_;
	open FILE,"$file";   
	<FILE>;
	my $count = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		if($usage>=0.05 && $polyA_readcount>=$threshold && $rna_seq>=0.05){
			$count++;
		}
	}
	return $count;
}
