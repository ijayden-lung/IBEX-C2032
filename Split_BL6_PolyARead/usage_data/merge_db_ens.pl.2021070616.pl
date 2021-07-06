#!/usr/bin/perl -w
my $threshold = 49;

my %db_hash;
open FILE,"human_liver.pAs.coverage.txt";
while(<FILE>){
	chomp;
	my @data = split;
	my ($chr,$strand) = @data[2,4];
	push @{$db_hash{"$chr:$strand"}},\@data;
}

my %ens_hash;
open FILE,"human_liver.pAs.ens.coverage.txt";
while(<FILE>){
	chomp;
	my @data = split;
	my ($chr,$strand) = @data[2,4];
	push @{$ens_hash{"$chr:$strand"}},\@data;
}

open OUT,">human_liver.pAs.merge.coverage.txt";
while(my ($key,$val) = each %db_hash){
	my @db_data = @$val;
	my $val2 = $ens_hash{$key};
	my @ens_data = @$val2;
	my $j = 0;
	my $db_pre = 0;
	for(my $i=0;$i<@db_data;$i++){
		my $db_ref = $db_data[$i];
		my $ens_ref = $ens_data[$j];
		my $db_pos = $db_ref->[3];
		my $ens_pos = $ens_ref->[3];
		while($j<@ens_data && $ens_pos < $db_pos-$threshold){
			#print "$db_pos\t$ens_pos\t$db_pre\n";
			if($ens_pos > $db_pre+$threshold){
				print OUT join("\t",@$ens_ref),"\n";
			}
			$j++;
			$ens_ref = $ens_data[$j];
			$ens_pos = $ens_ref->[3];
		}
		print OUT join("\t",@$db_ref),"\n";
		$db_pre = $db_pos;
	}
}
