#!/usr/bin/perl -w
#
#Yongkang Long 2020/12/27 Change to Block version
#
#
use List::Util qw(first max maxstr min minstr reduce shuffle sum shuffle) ;

my ($input,$PAS,$scanTranscriptome,$negative,$out,$round,$polyASeqRCThreshold, $RNASeqRCThreshold,$Shift) = @ARGV;
my $Threshold  = 50;
my ($baseName) = (split /\//,$scanTranscriptome)[-1];
my ($CHR,$SRD) = split /\_/,$baseName;
open FILE,"$input";
<FILE>;
my %fp_pas;
while(<FILE>){
	chomp;
	my ($pos,$id,$diff,$chr,$srd,$gt_id,$gt_diff) = split;
	next if (abs($gt_diff) <= $Threshold);
	my $end = sprintf("%.0f",$pos);
	$fp_pas{"$chr:$end:$srd"} = '';
}

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


my %pas;
open FILE,"$scanTranscriptome";
my $header=<FILE>;
my @lines = <FILE>;
my $index = 0;
my $aug_count = 0;
my $parent_pasid = '';
my %new_negative;
for (my $i=0;$i<@lines;$i++){
	chomp $lines[$i];
	my @data = split /\t/,$lines[$i];
	my $pas_id = $data[0];
	my ($chr,$pos,$srd) =  @data[2..4];
	if(exists $fp_pas{$pas_id}){
		#my $trimMean = &TrimmedMean(@data[8..108]);
		#next if $trimMean < $RNASeqRCThreshold;
		$data[5] = "Origin$round";
		$data[6] = $pas_id;
		$pas{$pas_id}->{$pas_id} = join("\t",@data);
		&Augmentation($i,\@lines,$srd,$pos,$pas_id);
	}
	elsif(rand() < 0.001){
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
				$data[5] = 'NewOrigin';
				$data[6] = $parent_pasid;
				$new_negative{$parent_pasid}->{$pas_id} = join("\t",@data);
			}
			else{
				my $shift = $aug_count % (2*$Shift+1) ;
				$data[5] = "NewShift$shift";
				$data[6] = $parent_pasid;
				$new_negative{$parent_pasid}->{$pas_id} = join("\t",@data);
			}
			$aug_count++;
		}
	}
}


foreach my $pas_id (keys %fp_pas){
	if (!exists $pas{$pas_id}){
		print "Warning. predicted PAS $pas_id not in scan transcriptome file\n";
	}
}


my @shuffle = keys %pas;
my @shuffle2 = keys %new_negative;
open FILE,"$negative";
my %negative;
while(<FILE>){
	chomp;
	my @data = split;
	$negative{$data[6]}->{$data[0]} = $_;
}
	

my $i=0;
open OUT,">$out";
while (my ($key,$val) = each %negative){
	if(rand()<0.5){
		my $number1 = @shuffle;
		my $number2 = @shuffle2;
		if ($i<$number1){
			my $pas_data_ref = $pas{$shuffle[$i]};
			while (my ($shift_pas_id,$shift_line) = each %$pas_data_ref){
				print OUT "$shift_line\n";
			}
			$i++;
		}
		elsif ($i<$number1+$number2){
			my $pas_data_ref = $new_negative{$shuffle2[$i-$number1]};
			while (my ($shift_pas_id,$shift_line) = each %$pas_data_ref){
				print OUT "$shift_line\n";
			}
			$i++;
		}
		else{
			while (my ($shift_pas_id,$shift_line) = each %$val){
				print OUT "$shift_line\n";
			}
		}
	}
	else{
		while (my ($shift_pas_id,$shift_line) = each %$val){
			print OUT "$shift_line\n";
		}
	}
}

sub Augmentation{
	my ($i,$lines_ref,$srd,$pos,$pas_id) = @_;
	my @lines = @$lines_ref;
	for (my $j=$i-$Shift;$j<=$i+$Shift;$j++){
		next if $j==$i;
		chomp $lines[$j];
		my @shift_data = split /\t/,$lines[$j];
		my $shift_pos = $shift_data[3];
		my $shift_diff = $pos-$shift_pos;
		if (abs($shift_diff) <= $Shift){
			my $before = &TrimmedMean(@shift_data[8..108]);
			next if $before < $RNASeqRCThreshold;
			$shift_data[6] = $pas_id;
			if($shift_diff<0){
				if ($srd eq "+"){
					$shift_data[5] = "Up".abs($shift_diff).$round;
				}
				else{
					$shift_data[5] = "Dn".abs($shift_diff).$round;
				}
			}
			else{
				if ($srd eq "+"){
					$shift_data[5] = "Dn".abs($shift_diff).$round;
				}
				else{
					$shift_data[5] = "Up".abs($shift_diff).$round;
				}
			}
			$pas{$pas_id}->{$shift_data[0]} = join("\t",@shift_data);
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
