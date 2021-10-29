package Upstream;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/Determine/;

sub Determine{
	my ($exon_loc,$pos) = @_;
	my $pas_type = 'UR';
	my $trans_count = 0;
	my $trans_stat = 0;
	while (my ($trans_id,$pos_vals) = each %$exon_loc){
		foreach my $pos_val (keys %$pos_vals){
			my ($start,$end) = split /,/,$pos_val;
			if($pos>=$start && $pos <= $end){
				$trans_stat++;
			}
		}
		$trans_count++;
	}
	if($trans_stat == $trans_count){
		$pas_type = "Exonic";
	}
	elsif($trans_stat < $trans_count){
		$pas_type = "Inronic"
	}
	else{
		print "Invalid\n";
	}
	return $pas_type;
}
