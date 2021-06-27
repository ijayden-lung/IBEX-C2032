#!/usr/bin/perl -w

my ($input,$output,$end) = @ARGV; 

if($end eq "pair"){
	&changePairEnd($input,$output);
}
else{
	&changeR1($input,$output);
}

sub changePairEnd{
	my ($input,$output) = @_;
	open FILE,"$input";
	open OUT,">$output.tmp";
	my %hash;
	while(<FILE>){
		chomp;
		my @data = split;
		if($data[0] !~ /chr/){
			$data[0] = "chr$data[0]";
		}
		next if $data[0] =~ "chrM";
		next if $data[0] eq "chrY";
		my ($readid,$pair) = split /\//,$data[3];
		if($pair eq "1"){
			if($data[5] eq "+"){
				$data[2] = $data[1]-1;   ###Two reads cut
				$data[1] = $data[1]-2;
			}
			elsif($data[5] eq "-"){
				$data[1] = $data[2]+1;  ###Two reads cut
				$data[2] = $data[2]+2;
			}
			print OUT join("\t",@data),"\n";
		}
	}
	system("sort -k1,1 -k2,2n -S 30G $output.tmp -o $output");
	system("rm $output.tmp");
}

sub changeR1{
	my ($input,$output) = @_;
	open FILE,"$input";
	open OUT,">$output.tmp";
	while(<FILE>){
		chomp;
		my @data = split;
		if($data[0] !~ /chr/){
			$data[0] = "chr$data[0]";
		}
		next if $data[0] =~ "chrM";
		next if $data[0] eq "chrY";
		if($data[5] eq "+"){
			$data[2] = $data[1]-1;
			$data[1] = $data[1]-2;
		}
		else{
			$data[1] = $data[2]+1; 
			$data[2] = $data[2]+2;
		}
		print OUT join("\t",@data),"\n";
	}
	system("sort -k1,1 -k2,2n -S 30G $output.tmp -o $output");
	system("rm $output.tmp");
}

