#!/usr/bin/perl -w
#
my $hepg2_file = "predict.hepg2_control.usage.txt";
my $k562_file = "predict.k562_chen.usage.txt";
my $thle2_file = "predict.thle2_control.usage.txt";
my $snu398_file = "predict.snu398_control.usage.txt";


open OUT,">pAs.list.txt";
my %near_no_polyA;
my %total_predict_true;
my @cells = ('snu398','k562','thle2','hepg2');
print OUT "pas_id\tsymbol\t",join("\t",@cells),"\n";
&statistics($snu398_file,'snu398',0.78);
&statistics($k562_file,'k562',3.33);
&statistics($thle2_file,'thle2',0.89);
&statistics($hepg2_file,'hepg2',0.62);

my $num = keys %total_predict_true;
while(my ($symbol,$val) =each %total_predict_true){
	while (my ($pas_id,$val2) = each %$val){
		print OUT "$symbol\t$pas_id";
		foreach my $cell (@cells){
			if(exists $val2->{$cell}){
				print OUT "\t$val2->{$cell}";
			}
			else{
				print OUT "\tNone";
			}
		}
		print OUT "\n";
	}
}


sub statistics{
	my ($file,$cell,$times) = @_;
	open FILE,"$file";
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$is_ground_true,$nearest_pas,$symbol,$pas_type,undef,undef,$usage,$polyA_readcount,$predict_readcount) = split;
		my $predict_pos = (split /\:/,$pas_id)[1];
		my $true_pos    = (split /\:/,$nearest_pas)[1];
		my $diff = abs($predict_pos-$true_pos);
		#if($diff < 25){
			my $nearest_pasid = $nearest_pas;
			if($nearest_pas =~ /\./){
				(undef,$nearest_pasid) = split /\./,$nearest_pas;
			}
			$total_predict_true{$symbol}->{$nearest_pasid}->{$cell} = "$polyA_readcount,$predict_readcount";
			#}
	}
}
