#!/usr/bin/perl -w
my $threshold = 49;

my %db_hash;
my %ens_hash;
open FILE,"SNU398_Control.pAs.db.usage.txt";
my $header = <FILE>;
while(<FILE>){
	chomp;
	my @data = split;
	my ($chr,$strand) = @data[2,4];
	push @{$db_hash{"$chr:$strand"}},\@data;
}

open FILE,"SNU398_Control.pAs.gen.usage.txt";
<FILE>;
while(<FILE>){
	chomp;
	my @data = split;
	my ($chr,$strand) = @data[2,4];
	push @{$ens_hash{"$chr:$strand"}},\@data;
}

open OUT,">SNU398_Control.pAs.usage.txt";
print OUT "$header";
while(my ($key,$val) = each %db_hash){
	my @db_data = @$val;
	my $val2 = $ens_hash{$key};
	my @ens_data = @$val2;
	my $j = 0;
	my $db_pre = 0;
	for(my $j=0;$j<@ens_data;$j++){
		my $ens_ref = $ens_data[$j];
		my $ens_pos = $ens_ref->[3];
		my $print = 1;
		for(my $i=0;$i<@db_data;$i++){
			my $db_ref = $db_data[$i];
			my $db_pos = $db_ref->[3];
			my $dist = abs($db_pos-$ens_pos);
			if($dist<=$threshold){
				$print = 0;
				last;
			}
		}
		if($print==1){
			print OUT join("\t",@$ens_ref),"\n";
		}
	}


	for(my $i=0;$i<@db_data;$i++){
		my $db_ref = $db_data[$i];
		#my $ens_ref = $ens_data[$j];
		my $db_pos = $db_ref->[3];
		#my $ens_pos = $ens_ref->[3];
=pod
		while($j<@ens_data && $ens_pos < $db_pos-$threshold){
			#print "$db_pos\t$ens_pos\t$db_pre\n";
			if($ens_pos > $db_pre+$threshold){
				print OUT join("\t",@$ens_ref),"\n";
			}
			$j++;
			$ens_ref = $ens_data[$j];
			$ens_pos = $ens_ref->[3];
		}
=cut
		print OUT join("\t",@$db_ref),"\n";
		$db_pre = $db_pos;
	}
}
