#!/usr/bin/perl -w
#
my $thle2_file = "THLE2_Control.usage.txt";
my $thle2_file2 = "../usage_data/THLE2_Control.pAs.usage.txt";
my $k562_file = "K562_Chen.usage.txt";
my $k562_file2= "../usage_data/K562_Chen.pAs.usage.txt";
my $snu398_file = "SNU398_Control.usage.txt";
my $snu398_file2 = "../usage_data/SNU398_Control.pAs.usage.txt";
my $hepg2_file = "HepG2_Control.usage.txt";
my $hepg2_file2 = "../usage_data/HepG2_Control.pAs.usage.txt";
open OUT2,">../Figures/stat.fp.txt";
print OUT2 "RPM\tnum_groundtruth\tnum_predicted\tnum_true_pos\trecall\tprecision\tfp_anno%\tfp_unanno%\tfp_anno_exp%\tfp_anno_unexp%\tfp_unanno_exp%\tfp_unanno_unexp%\n";
&statistics($thle2_file,$thle2_file2,1,"THLE2");
&statistics($k562_file,$k562_file2,3.5,"K562");
&statistics($snu398_file,$snu398_file2,1,"SNU398");
&statistics($hepg2_file,$hepg2_file2,1,"HepG2");
sub statistics{
	my ($file,$file2,$threshold,$cell) = @_;
	my ($ground_truth,$gt_rc_ref) =  &count_polyAread($file2,$threshold);
	open FILE,"$file";
	<FILE>;
	my $total = 0;
	my $polyA_correct = 0;
	my $fp = 0;
	my $fp_anno = 0;
	my $fp_unanno = 0;
	my $fp_anno_exp = 0;
	my $fp_anno_unexp = 0;
	my $fp_unanno_exp = 0;
	my $fp_unanno_unexp = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$is_ground_true,$nearest_pas,$symbol,$pas_type,undef,undef,$usage,$polyA_readcount) = split;
		$total++;
		my $predict_pos = (split /\:/,$pas_id)[1];
		my $true_pos    = (split /\:/,$nearest_pas)[1];
		my $true_pas_id = $nearest_pas;
		$true_pas_id =~ s/DB\.//g;
		my $diff = abs($predict_pos-$true_pos);
		if($is_ground_true eq "True"){
			$polyA_correct++;
		}
		else{
			$fp++;
			if(abs($diff)<25){
				$fp_anno++;
				if($polyA_readcount>=$threshold || (exists $gt_rc_ref->{$true_pas_id} && $gt_rc_ref->{$true_pas_id}>=$threshold)){
					$fp_anno_exp++;
				}
				else{
					$fp_anno_unexp++;
				}
			}
			else{
				$fp_unanno++;
				if($polyA_readcount>=$threshold){
					$fp_unanno_exp++;
				}
				else{
					$fp_unanno_unexp++;
				}

			}
		}
	}
	my $recall = sprintf("%.2f",$polyA_correct/$ground_truth*100);
	my $precision = sprintf("%.2f",$polyA_correct/$total*100);
	my $per_fp_anno = sprintf("%.2f",$fp_anno/$fp*100);
	my $per_fp_anno_exp = sprintf("%.2f",$fp_anno_exp/$fp_anno*100);
	my $per_fp_anno_unexp = sprintf("%.2f",$fp_anno_unexp/$fp_anno*100);
	my $per_fp_unanno = sprintf("%.2f",$fp_unanno/$fp*100);
	my $per_fp_unanno_exp = sprintf("%.2f",$fp_unanno_exp/$fp_unanno*100);
	my $per_fp_unanno_unexp = sprintf("%.2f",$fp_unanno_unexp/$fp_unanno*100);

	print OUT2 "$cell\t$ground_truth\t$total\t$polyA_correct\t$recall\t$precision\t$per_fp_anno\t$per_fp_unanno\t$per_fp_anno_exp\t$per_fp_anno_unexp\t$per_fp_unanno_exp\t$per_fp_unanno_unexp\n";
}


sub count_polyAread{
	my ($file,$threshold) = @_;
	my %hash;
	open FILE,"$file";   
	<FILE>;
	my $count = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		if($usage>=0.05 && $polyA_readcount>=$threshold && $rna_seq>=0.05){
			$count++;
		}
		$hash{$pas_id} = $polyA_readcount;
	}
	return $count,\%hash;
}
