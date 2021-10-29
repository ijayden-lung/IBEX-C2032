package Assign;
require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/Assign_pAs_To_Gene/;

use Upstream;

sub Assign_pAs_To_Gene{
	my ($exon_loc_ref,$count,$sign,$pos,$Extend_info,$utr_ref,$val,$val2,$biotype_ref,$sort_genes_ref,$intergene_length_ref) = @_;
	my ($Extend,$Inter_extend,$Window) = @$Extend_info;
	my $new_pas_type = "intergenic";
	my $new_symbol = "na";
	my $extend_length = "No";
	my $between_gene = "before_$sort_genes_ref->[0]";

	for(my $i=$count;$i<@$sort_genes_ref;$i++){
	#for(my $i=0;$i<@$sort_genes_ref;$i++){
		my $gene_name = $sort_genes_ref->[$i];
		my $start = $val->{$gene_name};
		my $end =  $val2->{$gene_name};
		my $ext_start = $start;
		my $ext_end   = $end;
		my $extend  = $Extend;
		$extend = $intergene_length_ref->{$gene_name} if  $extend > $intergene_length_ref->{$gene_name};
		$extend = $Window if $extend < $Window;
		$ext_end += $sign*$extend;
		print "$ext_start,$ext_end\n" if $gene_name eq "RPL22";
		if($ext_start*$sign > $pos*$sign){
			last;
		}
		elsif($ext_end*$sign >= $pos*$sign){
			$count = $i;
			$new_symbol = $gene_name;
			my ($utr_start,$utr_end) = split /\-/,$utr_ref->{$gene_name};
			if($utr_start*$sign <= $pos*$sign){
				$new_pas_type = "LE";
				if (($pos-$end)*$sign>0){
					$extend_length = ($pos - $end)*$sign;
					$new_pas_type = "Extend";
				}
			}
			else{
				$new_pas_type = "UR";
				for(my $j=$i+1;$j<$i+60 && $j < @$sort_genes_ref;$j++){
					my $new_gene_name = $sort_genes_ref->[$j];
					next if $biotype_ref->{$new_gene_name} ne "protein_coding" && $new_gene_name !~ /\-AS/;;
					my ($new_utr_start,$new_utr_end) = split /\-/,$utr_ref->{$new_gene_name};
					my $new_start = $val->{$new_gene_name};
					my $new_extend = $intergene_length_ref->{$new_gene_name};
					$new_extend = ($utr_start-$new_utr_end)*$sign if $new_extend>($utr_start-$new_utr_end)*$sign;
					$new_extend = $Inter_extend if $new_extend > $Inter_extend;
					$new_extend = $Window if $new_extend < $Window;
					$utr_ext_end = $new_utr_end +  $new_extend*$sign;
					if($new_utr_start*$sign <= $pos*$sign && $utr_ext_end*$sign >= $pos*$sign){
						$new_pas_type = "LE";
						$new_symbol = $new_gene_name;
						if (($pos-$end)*$sign>0){
							$extend_length = ($pos - $end)*$sign;
							$new_pas_type = "Extend";
						}
						last;
					}
					elsif($new_start*$sign <= $pos*$sign && $new_utr_start*$sign > $pos*$sign && $new_utr_end*$sign <= $utr_start*$sign){
						$new_symbol = $new_gene_name;
						$new_pas_type = "UR";
						last;
					}
					elsif($new_utr_end*$sign > $utr_start*$sign){
						last;
					}
				}
			}
			last;
		}
	}
	if($count+1 < @$sort_genes_ref){
		$between_gene = "inter_$sort_genes_ref->[$count]_$sort_genes_ref->[$count+1]";
	}
	else{
		$between_gene = "After_$sort_genes_ref->[$count]";
	}
	$biotype_ref->{$between_gene} = 'intergenic';
	if($new_symbol eq 'na'){
		$new_symbol = $between_gene;
	}
	elsif($biotype_ref->{$new_symbol} ne "protein_coding"){
		$new_pas_type = "ncRNA";
		if($new_symbol =~ /\-AS/){
			$new_pas_type = "antisense";
		}
	}
	$new_pas_type = &Determine($exon_loc_ref->{$new_symbol},$pos) if $new_pas_type eq "UR";
	return ($count,$new_pas_type,$new_symbol,$extend_length,$between_gene);
}

