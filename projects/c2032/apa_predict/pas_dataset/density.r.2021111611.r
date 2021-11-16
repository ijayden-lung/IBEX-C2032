#!/usr/bin/env Rscript
library(ggplot2)
library(scales)
library(grid)
args<-commandArgs(T)
data = read.table(args[1],header=TRUE)
pdf(args[2])

### for altLastExon length
#ggplot(data,aes(x=log10(length)))+geom_density()+theme_bw()


### for intronic pas length
ggplot(data,aes(x=log10(distance)))+geom_density()+theme_bw()

### for pas distance
#ggplot(data,aes(x=log10(dist)))+geom_density()+theme_bw()+
#theme(plot.title = element_text(size=30,hjust = 0.5)) 

#data = subset(data,data$dist<1000)
#ggplot(data,aes(x=dist))+geom_density()+theme_bw()
