#!/usr/bin/perl -w
#

my $out = "single_pas_usage.txt";
my $snu398_single_pas_ref = &get_sigle_pas("all.snu398_control.usage.txt");
my $thle2_single_pas_ref = &get_sigle_pas("all.thle2_control.usage.txt");
my $hepg2_single_pas_ref = &get_sigle_pas("all.hepg2_control.usage.txt");
my $k562_single_pas_ref = &get_sigle_pas("all.k562_chen.usage.txt");

&output($snu398_single_pas_ref,"../usage_data/snu398_control.pAs.usage.txt","snu398","n");
&output($thle2_single_pas_ref,"../usage_data/thle2_control.pAs.usage.txt","thle2","y");
&output($hepg2_single_pas_ref,"../usage_data/hepg2_control.pAs.usage.txt","hepg2","y");
&output($k562_single_pas_ref,"../usage_data/k562_chen.pAs.usage.txt","k562","y");

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
		if($usage==1){
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
