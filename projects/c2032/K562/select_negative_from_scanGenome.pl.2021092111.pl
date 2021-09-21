#!/usr/bin/perl -w
#
#
#Update: 2020/12/12 Yongkang Long

my ($PAS,$file,$round,$polyASeqRCThreshold,$RNASeqRCThreshold,$prob,$Shift) = @ARGV;
my $Threshold  = 50;
my ($baseName) = (split /\//,$file)[-1];
my ($CHR,$SRD) = split /\_/,$baseName;


my %true_pas;
open FILE,"$PAS";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
	next if $chr ne $CHR;
	next if $srd ne $SRD;
	#######PolyA Seq Read Count threshold;
	next if $polyASeqRC < $polyASeqRCThreshold;
	#######RNA Seq Read Count threshold;
	next if $RNASeqRC   < $RNASeqRCThreshold;
	$true_pas{$end} = '';
}

my @sort_true_pas = sort{$a<=>$b} keys %true_pas;

open FILE,"$file";
my $header = <FILE>;

$out = "data/negative/$round/$baseName";
print "$out\n";
open OUT,">$out";
my $index = 0;
my @lines = <FILE>;
my $aug_count = 0;
my $parent_pasid = '';
#while(<FILE>){
for (my $i=0;$i<@lines;$i++){
	chomp $lines[$i];
	my @data = split /\t/,$lines[$i];
	my ($chr,$pos,$srd) =  @data[2..4];
	my $pas_id  = $data[0];
	#my $p = 0.000248;
	my $p = $prob;
	if(rand() < $p){
		my $accept = 1;
		for(my$i=$index;$i<@sort_true_pas;$i++){
			if($sort_true_pas[$i] - $pos < -$Threshold){
				$index = $i;
				next;
			}
			elsif($sort_true_pas[$i] - $pos < $Threshold){
				$accept = 0;
			}
			else{
				last;
			}
		}
		if($accept == 1){
			my $before = &TrimmedMean(@data[8..108]);
			next if $before < $RNASeqRCThreshold;
			if ($aug_count % (2*$Shift+1) == 0) {
				$parent_pasid = $pas_id;
				$data[5] = 'Origin';
				$data[6] = $parent_pasid;
				print OUT join("\t",@data),"\n";
			}
			else{
				my $shift = $aug_count % (2*$Shift+1) ;
				$data[5] = "Shift$shift";
				$data[6] = $parent_pasid;
				print OUT join("\t",@data),"\n";
			}
			$aug_count++;
			#&Augmentation($i,\@lines,$srd,$pos,$pas_id);
		}
	}
}


sub Augmentation{
	my ($i,$lines_ref,$srd,$pos,$pas_id) = @_;
	for (my $j=$i-$Shift;$j<=$i+$Shift;$j++){
		next if $j==$i;
		chomp $lines[$j];
		my @shift_data = split /\t/,$lines[$j];
		my $shift_pos = $shift_data[3];
		my $shift_diff = $pos-$shift_pos;
		if (abs($shift_diff) <= $Shift){
			$shift_data[6] = $pas_id;
			if($shift_diff<0){
				if ($srd eq "+"){
					$shift_data[5] = "Up".abs($shift_diff);
				}
				else{
					$shift_data[5] = "Dn".abs($shift_diff);
				}
			}
			else{
				if ($srd eq "+"){
					$shift_data[5] = "Dn".abs($shift_diff);
				}
				else{
					$shift_data[5] = "Up".abs($shift_diff);
				}
			}
			my $before = &TrimmedMean(@shift_data[8..108]);
			next if $before < $RNASeqRCThreshold;
			print OUT join("\t",@shift_data),"\n";
		}
	}
}




sub TrimmedMean{
	my @data = @_;
	my $sum = 0;
	my $count = 0;
	foreach my $ele (@data){
		if($ele>0){
			$sum += $ele;
			$count++;
		}
	}
	my $ave = $count>0 ? $sum/$count : 0;
	return $ave;
}
