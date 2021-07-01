#!/bin/bash

#python generate_windows.py --input_file="STAR/K562_Chen/Signal.Unique.str2.out.chr11.wig" --root_dir="test_data" --ens_file="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz" --fa_file="/home/longy/cnda/ensembl/oneLine/hg38.11.fa" 

#python extract_coverage_from_scanGenome.py --pas_file="/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt" --scan_file="test_data/chr11_+_0"
python extract_coverage_from_scanGenome.py --pas_file="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz" --scan_file="test_data/chr11_+_5" --file_type="ensembl"


