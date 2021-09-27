from pyfaidx import Fasta
import os
genes = Fasta('/home/longy/cnda/ensembl/Homo_sapiens.GRCh38.dna.primary_assembly.fa')

print(genes['2'][150000:150020])

root_dir="THLE2_Control_data2"
os.system('rm %s/*.wig'%root_dir)
