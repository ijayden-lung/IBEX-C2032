package ReadFile;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/read_file read_polya_file read_position_file/;

sub read_file{
	my ($file,$start,$end,$SCORE) = @_;
	my %hash;
	for(my$i=$start;$i<=$end;$i++){
		$hash{$i} = 0;
	}
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($pas_id,$score) = split;
		my ($chr,$pos,$strand) = split /\:/,$pas_id;
		if($start<=$pos && $end >= $pos){
			if($SCORE eq 1){
				$hash{$pos} = 1;
			}
			else{
				$hash{$pos} = $score;
			}
		}
	}
	return \%hash;
}

sub read_polya_file{
	my ($file,$start,$end,$times) = @_;
	my %hash;
	for(my$i=$start;$i<=$end;$i++){
		$hash{$i} = 0;
	}
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($chr,$pos,undef,$score,undef,$srd) = split;
		if($start<=$pos && $end >= $pos){
			$hash{$pos} = $score/$times;
		}
	}
	return \%hash;
}

sub read_position_file{
	my ($file,$start,$end) = @_;
	my %hash;
	for(my$i=$start;$i<=$end;$i++){
		$hash{$i} = 0;
	}
	open FILE,"$file";
	while(<FILE>){
		chomp;
		my ($pas_id,$score) = (split)[0,-1];
		my ($chr,$pos,$srd) = split /\:/,$pas_id;
		if($start<=$pos && $end >= $pos){
			$hash{$pos} = $score;
		}
	}
	return \%hash;
}
