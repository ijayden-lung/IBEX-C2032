#!/bin/bash

#python generate_windows.py --input_file="STAR/K562_Chen/Signal.Unique.str2.out.chr11.wig" --root_dir="test_data" --ens_file="/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.103.gtf.gz" --fa_file="/home/longy/cnda/ensembl/oneLine/hg38.11.fa" 

#python extract_coverage_from_scanGenome.py --pas_file="/home/longy/workspace/apa_predict/pas_dataset/hg38.pAs.tianbin.txt" --scan_file="test_data/chr11_+_0"
python extract_coverage_from_scanGenome.py --pas_file="/home/longy/cnda/gencode/gencode.v38.annotation.gtf.gz" --scan_file="test_data/chr11_+_0" --file_type="gencode"



#python change_all.py --pre_file="maxSum/Finetune_k562Tothle2.thle2_control_aug8_SC_p1r0.03u0.05_4-0002.chrX_+_1.txt.bidirection.12.1.txt" --scan="../Split_BL6/thle2_control_data/chrX_+_1" --output="test" --spe="hg38"



