package TrimmedMean;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/TrimmedMean/;

sub TrimmedMean{
	my @data = @_;
	my $nonzero_count = 0;
	for(my$i=1;$i<50;$i++){
		if($data[-$i]>0){
			$nonzero_count++;
		}
	}
	my $sum = 0;
	my $count = 0;
	my $max = 0;
	foreach my $ele (@data){
		if($ele>0){
			$sum += $ele;
			$count++;
		}
		if($max<$ele){
			$max = $ele;
		}
	}
	my $ave = ($nonzero_count>0 && $count>20) ? $sum/$count : 0;
	#my $ave = $count>20 ? $sum/$count : 0;
	return $ave;
	#return $max;
}
