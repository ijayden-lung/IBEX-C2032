#!/usr/bin/perl -w

open FILE,"K562_Chen.pAs.coverage.txt";
my @DB = <FILE>;

open FILE,"K562_Chen.pAs.ens.coverage.txt";
my @ENS = <FILE>;

for(my$i=0;$i<@DB;$i++){



