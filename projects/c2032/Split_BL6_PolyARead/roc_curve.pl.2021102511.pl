#!/usr/bin/perl -w
my $combination = "SC";
my $cell = "SNU398";
my $bestEpoch = "0038";
my $gt_num = &get_gt_num($cell);
if($combination eq "S"){
	$com = "sequence";
}
elsif($combination eq "C"){
	$com = "RNASeq";
}
else{
	$com = "SC";
}
open OUT,">Figures/$cell/predicted.$com.txt";
print OUT "# number of gournd truth pas: $gt_num\n";
print OUT "predict_pasid\tgt_pasid\tgt_diff\tdb_pasid\tdb_diff\tscore\n";
#for my $file (glob "maxSum/$cell\_Chen.pAs.single_kermax6.$cell\_Chen_aug12_$combination\_p1r0.05u0.05_4-$bestEpoch.*.txt.bidirection.0.1.txt"){
for my $file (glob "maxSum/snu398_control.pAs.single_kermax6.snu398_control_aug12_$combination\_p1r0.05u0.05_4-$bestEpoch.*.txt.bidirection.0.1.txt"){
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

sub get_gt_num{
	my ($cell) = @_;
	if($cell eq "THLE2"){
		return 20258;
	}
	elsif($cell eq "SNU398"){
		return 20990;
	}
	elsif($cell eq "HepG2"){
		return 20329;
	}
	elsif($cell eq "K562"){
		return 19946
	}
	else{
		print "cell line not exists\n";
		return 0;
	}
}
