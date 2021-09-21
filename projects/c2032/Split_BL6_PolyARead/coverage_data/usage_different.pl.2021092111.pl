#!/usr/bin/perl -w

#open FILE,"pAs.list.txt";
#open FILE,"newall.thle2_control.usage.txt";
#open FILE,"THLE2_Control.usage.0.01.txt";
open FILE,"THLE2_Control.usage.3.txt";
#open FILE,"THLE2_Control.usage.txt";
#open FILE,"thle2_control.usage.txt";
<FILE>;
my %predict_total1;
my %predict_total2;
my %true_total1;
my %true_total2;
my %pas_num_of_symbol;
my %hash;
my $total_pas = 0;
while(<FILE>){
	chomp;
	#my ($symbol,$pas_id,$readCount1,$readCount2,$readCount3,$readCount4) = split;
	my ($symbol) = (split)[3];
	#if($readCount4 ne "None"){
		$total_pas++;
		$hash{$symbol}++;
		#}
=pod
	if($readCount1 ne "None" && $readCount2 ne "None"){
		$pas_num_of_symbol{$symbol}++;
		my ($predict1,$true1) = split /,/,$readCount1;
		my ($predict2,$true2) = split /,/,$readCount2;
		$predict_total1{$symbol} += $predict1;
		$predict_total2{$symbol} += $predict2;
		$true_total1{$symbol} += $true1;
		$true_total2{$symbol} += $true2;
	}
=cut
}

my $count=0;
my $gene_total=0;
while(my($key,$val) = each %hash){
	if($val>1){
		$count++;
	}
	$gene_total++;
}
my $gene_per = $count/$gene_total;
print "$count\t$gene_total\t$gene_per\n";
my $multi_pas = $total_pas-($gene_total-$count);
my $pas_per = $multi_pas/$total_pas;
print "$multi_pas\t$total_pas\t$pas_per\n";


=pod
open FILE,"pAs.list.txt";
open OUT,">Usage.diff.txt";
print OUT "symbol\tpas_id\tpredict_delta_usage\ttrue_delta_usage\tpredict_usage1\ttrue_usage1\tpredict_usage2\ttrue_usage2\n";
<FILE>;
while(<FILE>){
	chomp;
	my ($symbol,$pas_id,$readCount1,$readCount2) = split;
	if($readCount1 ne "None" && $readCount2 ne "None"){
		next if $pas_num_of_symbol{$symbol} == 1;
		my ($predict1,$true1) = split /,/,$readCount1;
		my ($predict2,$true2) = split /,/,$readCount2;
		my $predict_usage1 = $predict1/$predict_total1{$symbol};
		my $predict_usage2 = $predict2/$predict_total2{$symbol};
		my $true_usage1 = $true1/$true_total1{$symbol};
		my $true_usage2 = $true2/$true_total2{$symbol};
		my $predict_usage_diff = $predict_usage1-$predict_usage2;
		my $true_usage_diff = $true_usage1-$true_usage2;
		print OUT "$symbol\t$pas_id\t$predict_usage_diff\t$true_usage_diff\t$predict_usage1\t$true_usage1\t$predict_usage2\t$true_usage2\n";
	}
}
=cut
