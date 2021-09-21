#!/usr/bin/perl -w

my $INFO  = "../Split_BL6/K562_Chen_data/info.txt";
my $PAS   = "usage_data/K562_Chen.pAs.usage.txt";
my $polyASeqRCThreshold = 3.5;
my $RNASeqRCThreshold  = 0.05;
my $usageThreshold = 0.05;

open INFO,$INFO;
my %info;
while(<INFO>){
	chomp;
	my ($baseName,$start,$end) = split /\t/;
	$info{$baseName} = [$start,$end];
}

my $gt_num = 0;
my %all_hash;
my %in_hash;
foreach my $baseName (keys %info){
	my ($CHR,$SRD) = split /\_/,$baseName;
	open FILE,"$PAS";
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$pas_type,$chr,$end,$srd,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
		next if $polyASeqRC < $polyASeqRCThreshold;
		next if $RNASeqRC   < $RNASeqRCThreshold;
		next if $usage < $usageThreshold;
		$all_hash{$pas_id} = '';
		if ($srd eq $SRD && $chr eq $CHR && $end>=$info{$baseName}->[0] && $end<=$info{$baseName}->[1]){
			$gt_num ++;
			$in_hash{$pas_id} = '';
		}
	}
}
print "$gt_num\n";
while( my ($key,$val) = each %all_hash){
	if(!exists $in_hash{$key}){
		print "$key\n";
	}
}
