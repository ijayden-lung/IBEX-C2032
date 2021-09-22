#!/usr/bin/perl -w
#
#
#Update 2020/12/22 Yongkang Long

my ($PAS,$file,$round,$polyASeqRCThreshold,$RNASeqRCThreshold,$augmentation,$Shift) = @ARGV;
print "$file\n";

my %pas_shift; ####shift of the pas
my %pas_origin; ####origin pasid of the shifted pas;
#my $Shift = 24;

open FILE,"$PAS";
<FILE>;
while(<FILE>){
	chomp;
	my ($pas_id,$pas_type,$chr,$end,$srd,$symbol,$usage,$polyASeqRC,undef,undef,$RNASeqRC) = split;
	next if $polyASeqRC < $polyASeqRCThreshold;
	next if $RNASeqRC   < $RNASeqRCThreshold;
	my $pos = $end;
	$pas_shift{"$chr:$pos:$srd"}  .= 'Origin';
	$pas_origin{"$chr:$pos:$srd"}  = $pas_id;
	for (my $i=1;$i<=$Shift;$i++){
		if($srd eq "+"){
			$pos = $end-$i;
		}
		elsif($srd eq "-"){
			$pos = $end+$i;
		}
		else{
			print "Warning. Invalid stranding $srd at pas $pas_id\n";
		}
		$pas_shift{"$chr:$pos:$srd"} .= "Up$i";
		$pas_origin{"$chr:$pos:$srd"}  = $pas_id;

		if($srd eq "+"){
			$pos = $end+$i;
		}
		elsif($srd eq "-"){
			$pos = $end-$i;
		}
		$pas_shift{"$chr:$pos:$srd"} .= "Dn$i";
		$pas_origin{"$chr:$pos:$srd"}  = $pas_id;
	}
}


open FILE,"$file";
my $header = <FILE>;
($baseName) = (split /\//,$file)[-1];
$out = "data/positive/$round/$baseName";
open OUT,">$out";
while(<FILE>){
	chomp;
	my @data = split /\t/;
	my $pas_id = $data[0];
	if(exists $pas_shift{$pas_id}){
		my $before = &TrimmedMean(@data[8..108]);
		next if $before < $RNASeqRCThreshold;
		my $val = $pas_shift{$pas_id};
		$data[5] = $val;
		$data[6] = $pas_origin{$pas_id};
		print OUT join("\t",@data),"\n";
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