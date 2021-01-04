#$string = 'AAATTATTACCGAMMMMNNN';
#my $count = () = $string =~ /A/g;
#print "$count\n";

use Bio::Cigar;
my $cigar = Bio::Cigar->new("12S83M200N5M10S");
my $a = $cigar->query_length;
my $b = $cigar->reference_length;
print "Query length is  $a\n";
print "Reference length is $b\n";
 
my ($qpos, $op) = $cigar->rpos_to_qpos(3);



