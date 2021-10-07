#!/sur/bin/perl -w

my %hash;
#foreach $file (glob "out_dir/chr/maxSum/*"){
#foreach $file (glob "out_dir/chr2/maxSum/*"){
foreach $file (glob "out_dir/block4/maxSum/*"){
	my $block = (split /\/|\./,$file)[4];
	$hash{"$block"} = '';
}

#open FILE,"LOG/log.17523261";
#open FILE,"LOG/log.17524296";
open FILE,"LOG/log.17528654";
while(<FILE>){
	chomp;
	if($.>6 && $.<=385){
		my ($block) = split;
		$block = (split /\./,$block)[1];
		if (!exists $hash{$block}){
			print "$block\n";
		}
	}
}
