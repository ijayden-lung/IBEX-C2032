#!/usr/bin/perl -w

use TrimmedMean;
use ReadGene;
use Assign;

my $window = 24;
my $polya_db = "/home/longy/project/Split_BL6_PolyARead/usage_data/K562_Chen.pAs.coverage.txt";
my $ens_db = "/home/longy/project/Split_BL6_PolyARead/usage_data/K562_Chen.pAs.ens.coverage.txt";
my $all_db = "/home/longy/project/Split_BL6_PolyARead/usage_data/K562_Chen.pAs.coverage.all.txt";

sub binary_search{
	my ($sort_ref,$chr,$max_pos,$strand) = @_;
	my $pas_array_ref = $sort_ref->{"$chr:$strand"};
	my $index1 = 0;
	my $index2 = @$pas_array_ref-1;
	my $status = "None";
	if($index2 ==-1){
		print "$chr,$max_pos,$strand";
		return ($max_pos,$status);
	}
	if($pas_array_ref->[$index1] > $max_pos){
		return ($max_pos,$status);
	}
	if($pas_array_ref->[$index2] < $max_pos){
		return ($max_pos,$status);
	}
	while($index2-$index1>1){
		my $mid_index = int(($index1+$index2)/2);
		if($pas_array_ref->[$mid_index] > $max_pos){
			$index2 = $mid_index;
		}
		elsif($pas_array_ref->[$mid_index] < $max_pos){
			$index1 = $mid_index;
		}
		else{
			$index1 = $mid_index;
			$index2 = $mid_index;
		}
	}
	my $pos1 = $pas_array_ref->[$index1];
	my $pos2 = $pas_array_ref->[$index2];
	my $pos;
	if(($pos1-$max_pos)<abs($pos2-$max_pos)){
		$pos = $pos1;
	}
	else{
		$pos = $pos2;
	}
	if(abs($pos-$max_pos)<=$window){
		$status = $pos-$max_pos;
		$max_pos = $pos;
	}
	return ($max_pos,$status);
}

sub get_pas{
	my ($file) = @_;
	my %pas;
	my %sort_pas;
	open COV,"$file";
	while(<COV>){
		next if $_ =~ /^pas_id/;
		my ($pas_id,$pas_type,$chr,$pos,$strand,$symbol,$motif) = split;
		my @data = split;
		my $length = int((@data-8)/2);
		my $before = &TrimmedMean(@data[8..8+$length]);
		next if $before <=0;
		my $after = &TrimmedMean(reverse (@data[9+$length..$#data]));
		my $ave = ($before+$after)/2;
		my $diff = $before-$after;
		my $ave_diff = $diff/$ave;
		$pas{$pas_id} = "$motif\t$ave_diff\t$before";
		push @{$sort_pas{"$chr:$strand"}},$pos;
	}
	return \%pas,\%sort_pas;
}


sub forward{
	my ($j,$data_ref,$max_pos,$max_readCount,$max_status,$db_pas_ref,$ens_pas_ref) = @_;
	return $max_readCount,$max_pos,$max_status,$j if $j >=@$data_ref;
	my $total_readCount = $max_readCount;
	my $pos = $max_pos;
	my $forward_line = $data_ref->[$j];
	chomp $forward_line;
	my ($chr,$forward_pos,undef,$forward_readCount,undef,$strand) = split /\t/,$forward_line;
	while($forward_pos-$pos<=$window && $forward_pos-$max_pos<=2*$window){
		$total_readCount += $forward_readCount;
		my $potential_max_readCount = $forward_readCount;
		my $potential_max_pos = $forward_pos;
		my $potential_max_pas_id = "$chr:$potential_max_pos:$strand";
		my $potential_max_status = &get_max_status($potential_max_pas_id,$db_pas_ref,$ens_pas_ref);
		if($potential_max_status ne "None"){
			if($max_status eq "None"){
				$max_pos = $potential_max_pos;
				$max_readCount = $potential_max_readCount;
				$max_status = $potential_max_status;
			}
			elsif($max_readCount<$potential_max_readCount){
				$max_pos = $potential_max_pos;
				$max_readCount = $potential_max_readCount;
				$max_status = $potential_max_status;
			}
		}
		elsif($max_readCount<$potential_max_readCount){
			$max_pos = $potential_max_pos;
			$max_readCount = $potential_max_readCount;
			$max_status = $potential_max_status;
		}
		$j++;
		last if $j >= @$data_ref;
		$forward_line = $data_ref->[$j];
		chomp $forward_line;
		$pos = $forward_pos;
		(undef,$forward_pos,undef,$forward_readCount) = split /\t/,$forward_line;
	}
	return $total_readCount,$max_pos,$max_status,$j;
}

sub get_max_status{
	my ($max_pas_id,$db_pas_ref,$ens_pas_ref) = @_;
	my $max_status = "None";
	if(exists $db_pas_ref->{$max_pas_id} && exists $ens_pas_ref->{$max_pas_id}){
		$max_status = "ens_db";
	}
	elsif(exists $db_pas_ref->{$max_pas_id}){
		$max_status = "db";
	}
	elsif(exists $ens_pas_ref->{$max_pas_id}){
		$max_status = "ens";
	}
	return $max_status;
}


my ($db_pas_ref,$db_sort_ref) = &get_pas($polya_db);
print "Finished get polyA_DB\n";
my ($ens_pas_ref,$ens_sort_ref) = &get_pas($ens_db);
print "Finished get ensembl PAS\n";
my ($all_pas_ref,$all_sort_ref) = &get_pas($all_db);
print "Finished get ensembl PAS\n";


#open FILE,"head -n 140 stackK562_Chen.bed |";
open FILE,"stackK562_Chen.bed";
my @data = <FILE>;
open OUT,">callPeakK562_Chen.bed";
my $count = 0;
for(my$i=0;$i<@data;){
	my $line = $data[$i];
	chomp $line;
	my ($chr,$pos,$pos2,$readCount,$quality,$strand) = split /\t/,$line;
	my $total_readCount = $readCount;
	my $max_pos = $pos;
	my $max_pas_id = "$chr:$max_pos:$strand";
	my $max_status = &get_max_status($max_pas_id,$db_pas_ref,$ens_pas_ref);
	($total_readCount,$max_pos,$max_status,$i) = &forward($i+1,\@data,$pos,$readCount,$max_status,$db_pas_ref,$ens_pas_ref);
	$count++;
	if($count %10000 == 0){
		print "Processing $count PAS\n";
	}
	my $pas_id = "$chr:$max_pos:$strand";
	my $motif_coverage = "None\tNone\tNone";
	if($max_status =~ /db/){
		$motif_coverage = $db_pas_ref->{$pas_id};
	}
	elsif($max_status =~ /ens/){
		$motif_coverage = $ens_pas_ref->{$pas_id};
	}
	else{
		my ($map_pos,$map_status) = &binary_search($db_sort_ref,$chr,$max_pos,$strand);
		$pas_id = "$chr:$map_pos:$strand";
		$max_pos = $map_pos;
		$max_status = $map_status;
		if($max_status eq "None"){
			($map_pos,$map_status) = &binary_search($ens_sort_ref,$chr,$max_pos,$strand);
			$pas_id = "$chr:$map_pos:$strand";
			$max_pos = $map_pos;
			$max_status = $map_status;
			if($max_status ne "None"){
				$max_status = "ENS$map_status";
				$motif_coverage = $ens_pas_ref->{$pas_id};
			}
			else{
				$motif_coverage = $all_pas_ref->{$pas_id};
				if(!defined $motif_coverage){
					next;
				}

			}
		}
		else{
			$max_status = "DB$map_status";
			$motif_coverage = $db_pas_ref->{$pas_id};
		}
	}

	print OUT "$pas_id\tpas_type\t$chr\t$max_pos\t$strand\tsymbol\tusage\t$total_readCount\t$motif_coverage\t$max_status\n";
}
