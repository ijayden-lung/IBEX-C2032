#!/usr/bin/perl -w

open OUT,">Figures/THLE2/predicted.txt";
print OUT "# number of gournd truth pas: 20258\n";
print OUT "predict_pasid\tgt_pasid\tgt_diff\tdb_pasid\tdb_diff\tscore\n";
for my $file (glob "maxSum/THLE2_Control.pAs.single_kermax6.THLE2_Control_aug12_SC_p1r0.05u0.05_4-0006.*.txt.bidirection.0.1.txt"){
#for my $file (glob "$base.*.txt.bidirection.0.1.txt"){
	open FILE,$file;
	<FILE>; #ship header;
	while(<FILE>){
		chomp;
		my ($predict_pos,undef,undef,$chr,$strand,$gt_pasid,$gt_diff,$db_pasid,$db_diff,$score) = split;
		my $pos = sprintf("%.0f",$predict_pos);
		my $pas_id = "$chr:$pos:$strand";
		my (undef,$gt_pos) = split /\:/,$gt_pasid;
		my (undef,$db_pos) = split /\:/,$db_pasid;
		$gt_diff = $pos-$gt_pos;
		$db_diff = $pos-$db_pos;
		print OUT "$pas_id\t$gt_pasid\t$gt_diff\t$db_pasid\t$db_diff\t$score\n";
	}
}

