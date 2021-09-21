#!/usr/bin/perl -w

my %hash_predict;
&read_predict("../train.Regression.new_thle2.shift16.1001");
&read_predict("../valid.Regression.new_thle2.shift16.1001");
&show("newall.thle2_control.usage.txt","allpredict.thle2_control.usage.txt");

#&read_predict("../train.Regression.f_hepg2.shift16.1001");
#&read_predict("../valid.Regression.f_hepg2.shift16.1001");
#&show("all.hepg2_control.usage.txt","predict.hepg2_control.usage.txt");

#&read_predict("../train.Regression.f_snu398.shift16.1001");
#&read_predict("../valid.Regression.f_snu398.shift16.1001");
#&show("all.snu398_control.usage.txt","predict.snu398_control.usage.txt");
#&read_predict("../train.thle2.mle.linear");
#&read_predict("../valid.thle2.mle.linear");
#&show("all.thle2_control.usage.txt","predict.thle2_control.usage.txt");
#&read_predict("../train.k562.mle.linear");
#&read_predict("../valid.k562.mle.linear");
#&show("all.k562_chen.usage.txt","predict.k562_chen.usage.txt");
sub read_predict{
	my ($file) = @_;
	print "$file\n";
	open FILE,"$file";
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,undef,undef,$predict_readCount) = split;
		$hash_predict{$pas_id} = $predict_readCount;
	}
}

sub show{
	my ($inp,$out) = @_;
	open FILE,"$inp";
	open OUT,">$out";
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$is_ground_true,$nearest_pas,$symbol,$pas_type,$extend,$biotype,$usage,$polyA_readcount) = split;
		if(exists $hash_predict{$pas_id}){
			print OUT "$pas_id\t$is_ground_true\t$nearest_pas\t$symbol\t$pas_type\t$extend\t$biotype\t$usage\t$polyA_readcount\t$hash_predict{$pas_id}\n";
		}
		else{
			print OUT "$pas_id\t$is_ground_true\t$nearest_pas\t$symbol\t$pas_type\t$extend\t$biotype\t0\t0\t0\n";
		}
	}
}
