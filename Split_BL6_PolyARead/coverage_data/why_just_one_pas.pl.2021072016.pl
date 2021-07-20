#!/usr/bin/perl -w
#

my $out = "single_pas_usage.txt";
my $out2 = "single_pas_barchart.txt";
my $snu398_single_pas_ref = &get_sigle_pas("newall.snu398_control.usage.txt");
my $thle2_single_pas_ref = &get_sigle_pas("newall.thle2_control.usage.txt");
my $hepg2_single_pas_ref = &get_sigle_pas("newall.hepg2_control.usage.txt");
my $k562_single_pas_ref = &get_sigle_pas("newall.k562_chen.usage.txt");

&output($snu398_single_pas_ref,"../usage_data/snu398_control.pAs.usage.txt","snu398","n");
&output($thle2_single_pas_ref,"../usage_data/thle2_control.pAs.usage.txt","thle2","y");
&output($hepg2_single_pas_ref,"../usage_data/hepg2_control.pAs.usage.txt","hepg2","y");
&output($k562_single_pas_ref,"../usage_data/k562_chen.pAs.usage.txt","k562","y");
&barchart($out,$out2);

sub get_sigle_pas{
	my %single_pas;
	my ($file) = @_;
	open FILE,$file;
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$true_pas,$usage) = (split)[0,2,7];
		my $true_pas_id = $true_pas;
		if($true_pas =~ /\./){
			(undef,$true_pas_id) = split /\./,$true_pas;
		}
		if($usage<1){
			$single_pas{$true_pas_id} = '';
		}
	}
	return \%single_pas;
}

sub output{
	my ($single_pas_ref,$usage,$cell,$append) = @_;
	if($append eq "y"){
		open OUT,">>$out";
	}
	else{
		open OUT,">$out";
		print OUT "pas_id\tusage\tcell_line\n";
	}
	open FILE,"$usage";
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage) = (split)[0,6];
		if(exists $single_pas_ref->{$pas_id}){
			print OUT "$pas_id\t$usage\t$cell\n";
		}
	}
}

=pod
sub barchart{
	my ($inp,$out2) = @_;
	open FILE,"$inp";
	<FILE>;
	my %hash;
	my %total;
	open OUT,">$out2";
	print OUT "range\tpercentage\tcell_line\n";
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$cell) = split;
		$total{$cell}++;
		if($usage<0.2){
			$hash{'0-0.2'}->{$cell}++;
		}
		elsif($usage<0.5){
			$hash{'0.2-0.5'}->{$cell}++;
		}
		elsif($usage<0.8){
			$hash{'0.5-0.8'}->{$cell}++;
		}
		else{
			$hash{'0.8-1'}->{$cell}++;
		}
	}
	while(my ($cell,$sum) = each %total){
		my $percent1 = $hash{'0-0.2'}->{$cell}/$sum;
		print OUT "0-0.2\t$percent1\t$cell\n";
		my $percent2 = $hash{'0.2-0.5'}->{$cell}/$sum;
		print OUT "0.2-0.5\t$percent2\t$cell\n";
		my $percent3 = $hash{'0.5-0.8'}->{$cell}/$sum;
		print OUT "0.5-0.8\t$percent3\t$cell\n";
		my $percent4 = $hash{'0.8-1'}->{$cell}/$sum;
		print OUT "0.8-1\t$percent4\t$cell\n";
	}

}
=cut
sub barchart{
	my ($inp,$out2) = @_;
	open FILE,"$inp";
	<FILE>;
	my %hash;
	my %total;
	open OUT,">$out2";
	print OUT "range\tpercentage\tcell_line\n";
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$cell) = split;
		$total{$cell}++;
		if($usage<0.2){
			$hash{'0-0.2'}->{$cell}++;
		}
		elsif($usage<0.5){
			$hash{'0.2-0.5'}->{$cell}++;
		}
		elsif($usage<0.8){
			$hash{'0.5-0.8'}->{$cell}++;
		}
		else{
			$hash{'0.8-1'}->{$cell}++;
		}
	}
	while(my ($cell,$sum) = each %total){
		my $percent1 = $hash{'0-0.2'}->{$cell}/$sum;
		print OUT "0-0.2\t$percent1\t$cell\n";
		my $percent2 = $hash{'0.2-0.5'}->{$cell}/$sum;
		print OUT "0.2-0.5\t$percent2\t$cell\n";
		my $percent3 = $hash{'0.5-0.8'}->{$cell}/$sum;
		print OUT "0.5-0.8\t$percent3\t$cell\n";
		my $percent4 = $hash{'0.8-1'}->{$cell}/$sum;
		print OUT "0.8-1\t$percent4\t$cell\n";
	}

}
