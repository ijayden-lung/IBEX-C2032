
library(ggplot2)

data = read.table('gencode.vM17.transcript.true.pas.seq.nor.poscov')
data[1:10,]  ##plot top 10 line

lineNum = 1
df =  data.frame(position = 1:207,coverage = as.vector(as.matrix(data[lineNum,4:210])))

pdf('coverage_2.pdf')

a = ggplot(data=df,aes(x=position,y=coverage))+
geom_line()+
theme_bw()+
theme(axis.title=element_text(size=12),
      axis.text=element_text(size=12,vjust=0.5,hjust=0.5,angle=0),
      legend.title=element_blank(),
      plot.title = element_text(size=15,face = "bold",hjust = 0.5),
      legend.text=element_text(size=11,color="black",face="bold"))

print(a)

dev.off()
