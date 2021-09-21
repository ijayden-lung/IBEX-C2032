#!/usr/bin/perl

use strict;
use Data::Dumper;

sub mean {
    my $data = shift;
    my $sum = 0;
    my $mean_val = 0;
    for my $item (@$data) {
        $sum += $item;
    }
    $mean_val = $sum / (scalar @$data) if @$data;
    return $mean_val;
}

sub variance {
    my $data = shift;
    my $variance_val = 0;
    my $mean_val = mean($data);
    my $sum = 0;
    for my $item (@$data) {
        $sum += ($item - $mean_val)**2;
    }
    $variance_val = $sum / (scalar @$data) if @$data;
    return $variance_val;
}

sub std {
    my $data = shift;
    my $variance_val = variance($data);
    return sqrt($variance_val);
}

# @param y - The input vector to analyze
# @parameter lag - The lag of the moving window
# @parameter threshold - The z-score at which the algorithm signals
# @parameter influence - The influence (between 0 and 1) of new signals on the mean and standard deviation
sub thresholding_algo {
    my ($y, $lag, $threshold, $influence) = @_;

    my @signals = (0) x @$y;
    my @filteredY = @$y;
    my @avgFilter = (0) x @$y;
    my @stdFilter = (0) x @$y;

    $avgFilter[$lag - 1] = mean([@$y[0..$lag-1]]);
    $stdFilter[$lag - 1] = std([@$y[0..$lag-1]]);

    for (my $i=$lag; $i <= @$y - 1; $i++) {
        if (abs($y->[$i] - $avgFilter[$i-1]) > $threshold * $stdFilter[$i-1]) {
            if ($y->[$i] > $avgFilter[$i-1]) {
                $signals[$i] = 1;
            } else {
                $signals[$i] = -1;
            }

            $filteredY[$i] = $influence * $y->[$i] + (1 - $influence) * $filteredY[$i-1];
            $avgFilter[$i] = mean([@filteredY[($i-$lag)..($i-1)]]);
            $stdFilter[$i] = std([@filteredY[($i-$lag)..($i-1)]]);
        }
        else {
            $signals[$i] = 0;
            $filteredY[$i] = $y->[$i];
            $avgFilter[$i] = mean([@filteredY[($i-$lag)..($i-1)]]);
            $stdFilter[$i] = std([@filteredY[($i-$lag)..($i-1)]]);
        }
    }

    return {
        signals => \@signals,
        avgFilter => \@avgFilter,
        stdFilter => \@stdFilter
    };
}

my $y = [1,1,1.1,1,0.9,1,1,1.1,1,0.9,1,1.1,1,1,0.9,1,1,1.1,1,1,1,1,1.1,0.9,1,1.1,1,1,0.9,
       1,1.1,1,1,1.1,1,0.8,0.9,1,1.2,0.9,1,1,1.1,1.2,1,1.5,1,3,2,5,3,2,1,1,1,0.9,1,1,3,
       2.6,4,3,3.2,2,1,1,0.8,4,4,2,2.5,1,1,1];

my $lag = 30;
my $threshold = 5;
my $influence = 0;

my $result = thresholding_algo($y, $lag, $threshold, $influence);

print Dumper $result;
