package AddPas;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/add_pas count_polyAread/;

sub add_pas{
	my ($file) = @_;
	my %db;
	my %hash;

	my $file2 = $file;
	$file2 =~ s/pAs\.usage/pAs.merge\.coverage/g;
	print "$file2\n";
	open FILE,"$file2";
	while(<FILE>){
		chomp;
		my ($id,undef,$chr,$pos,$strand) = split;
		$db{"$chr:$strand"}->{$pos} = '';
	}

	open FILE,"$file";   
	<FILE>;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		if($rna_seq>=0.05){
			my ($chr,$pos,$strand) = split /\:/,$pas_id;
			my $db_ref = $db{"$chr:$strand"};
			foreach my $key (keys %$db_ref){
				if(abs($key-$pos)<49){
					my $new_pasid = "$chr:$key:$strand";
					$hash{$pas_id}->{$new_pasid} = $polyA_readcount;
				}
			}
		}
	}
	return \%hash;
}
sub count_polyAread{
	my %gt_readcount;
	my ($file,$threshold,$all_pas_ref) = @_;
	open FILE,"$file";   
	<FILE>;
	my $count = 0;
	while(<FILE>){
		chomp;
		my ($pas_id,$usage,$polyA_readcount,$rna_seq) = (split)[0,6,7,10];
		if($polyA_readcount>=$threshold && $rna_seq>=0.05){
			$count++;
			$gt_readcount{$pas_id} = $polyA_readcount;
			my $close_pas_ref = $all_pas_ref->{$pas_id};
			foreach my $pas_id2 (keys %$close_pas_ref){
				$gt_readcount{$pas_id2} = $polyA_readcount;
			}
		}
	}
	#my $gt_readcount_ref = &add_pas($file2,\%gt_readcount);
	return $count,\%gt_readcount;
	#return $count,$gt_readcount_ref;
}


