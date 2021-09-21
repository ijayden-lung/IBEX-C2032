#!/usr/bin/perl -w

my $polyASeqThreshold = 3;
open FILE,"/home/longy/project/Split_BL6/polyA_seq/K562_Chen.pAs.predict.aug8_SC_p3r9u0.05_4-0072.12.1.usage.txt";
#open FILE,"/home/longy/project/Split_BL6/polyA_seq/BL6_REP1.pAs.predict.aug8_SC_p5r10u0.05_4-0026.12.2.usage.txt";
#open FILE,"/home/longy/project/Split_BL6/polyA_seq/HepG2_Control.pAs.predict.aug8_SC_p1r5u0.05_3-0060.12.1.usage.txt";
<FILE>;
my %high_usage;
my %polyASeq;
while(<FILE>){
	chomp;
	my ($pas_id,$usage,$polyASeq) = (split /\t/)[0,6,7];
	$high_usage{$pas_id} = '' if $usage>0.05;
	$polyASeq{$pas_id} = $polyASeq if $polyASeq > $polyASeqThreshold;
}

my $file =  "K562_Chen.pAs.predict.aug8_SC_p3r9u0.05_4-0072.12.1.txt";
#my $file =  "BL6_REP1.pAs.predict.aug8_SC_p5r10u0.05_4-0026.12.2.txt";
open FILE,$file;
#open FILE,"HepG2_Control.pAs.predict.aug8_SC_p1r5u0.05_3-0060.12.1.txt";
my %gene_count;
my $total_pas;
while(<FILE>){
	chomp;
	my ($pas_id,$motif_pastype_gene,$near_pas) = (split /\t/)[0,1,6];
	my ($gt_pas,$gt_diff,$db_pas,$db_diff)  = split /,/,$near_pas;
	#next if !exists $high_usage{$pas_id};
	my ($motif,$pastype,$gene) = split /\_/,$motif_pastype_gene;
	$gene_count{$gene}++;
	$total_pas++;
}
open FILE,$file;
my $multi = 0;
my $multi_true = 0;
my $multi_polyatrue = 0;
my $single = 0;
my $single_true = 0;
my $single_polyatrue = 0;
while(<FILE>){
	chomp;
	my ($pas_id,$motif_pastype_gene,$near_pas) = (split /\t/)[0,1,6];
	my ($gt_pas,$gt_diff,$db_pas,$db_diff)  = split /,/,$near_pas;
	my ($motif,$pastype,$gene) = split /\_/,$motif_pastype_gene;
	if($gene_count{$gene}>1){
		$multi++;
		if(abs($gt_diff)<25 || exists $polyASeq{$pas_id}){
			$multi_polyatrue++;
		}
		if(abs($gt_diff)<25){
			$multi_true++;
		}
	}
	else{
		$single++;
		if(abs($gt_diff)<25 || exists $polyASeq{$pas_id} ){
			$single_polyatrue++;
		}
		if(abs($gt_diff)<25){
			$single_true++;
		}
	}
}
my $multi_precision = $multi_true/$multi;
my $multi_polyaprecision = $multi_polyatrue/$multi;
my $single_precision = $single_true/$single;
my $single_polyaprecision = $single_polyatrue/$single;

my $total_true = $multi_true+$single_true;
my $total_polyatrue = $multi_polyatrue+$single_polyatrue;
my $total_precision  = $total_true/$total_pas;
my $total_polyaprecision = $total_polyatrue/$total_pas;
print "totalpas:$total_true,$total_precision\t$total_polyatrue,$total_polyaprecision\t$total_pas\n";
print "multiple:$multi_true,$multi_precision\t$multi_polyatrue,$multi_polyaprecision\t$multi\n";
print "single:$single_true,$single_precision\t$single_polyatrue,$single_polyaprecision\t$single\n";


my $total = 0;
my $multi_pas = 0;
my $more_than_2pas = 0;
while(my ($key,$val) = each %gene_count){
	if($val>1){
		$multi_pas++;
		if($val>2){
			$more_than_2pas++;
		}
	}
	$total++;
}
my $per = $multi_pas/$total;
print "morethan2pasgene:$more_than_2pas,multipasgene:$multi_pas,totalgene:$total,percentage:$per\n";
my $per2 = $multi_true/$total_true;
print "percentaage pas: $per2\n";
my $paspergene = $total_pas/$total;
print "pasgene:$paspergene\n";
