
import pybedtools as pb

pb.BedTool('tus_merged/tus_merged.annot.temp.sort').merge(c='6,4', o='distinct,distinct', delim=',', s=True).saveas('tus_merged/tus_merged.annot.temp.sort.merged.temp')
