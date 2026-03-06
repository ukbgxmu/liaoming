prs <- read.table("G:/Downloads/PRS/RPL/merged_QC3.best", header=T) #number 146998
head(prs)

rpl <- read.table("D:/0-dell-NAS/ukbA/data/liaoming/PRS/RPL/pheno.txt", header=T) #number 273045
head(rpl)

all<-merge(prs,rpl,by="FID")
head(all)

#单因素
kruskal.test(all$PRS,all$RPL)

library(dplyr)
glm(RPL~PRS,family=binomial(link="logit"),data=all)%>%summary()

#多因素
rpl.co <- read.table("D:/0-dell-NAS/ukbA/data/liaoming/PRS/RPL/covar.txt", header=T) #number 273045
head(rpl.co)

co<-read.csv("D:/0-dell-NAS/ukbA/data/liaoming/PRS/RPL/merged_all_Data1-9_innerjoin.csv")
head(co)

## .... ##