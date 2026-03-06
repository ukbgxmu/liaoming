setwd("D:/0-dell-NAS/ukbA/data/liaoming/PRS/RPL") #from liaoming's dell
setwd("D:/R/ubuntu/ukb/all") #from liaoming's dell

all<-read_csv("co-ccdc.tsv")
table(all$participant.p22001) 
table(all$participant.p22006) 
table(all$participant.p22006,all$participant.p22001) 

#name	title
#participant.eid
#participant.p22000
#participant.p22001 Genetic sex
#participant.p22006 Genetic ethnic grouping
#participant.p21022
#participant.p22009_a1 Genetic principal components | Array 1
#participant.p23104_i0
#participant.p20160_i0

#p22001	Genetic sex
#p22003	Heterozygosity
#p22004	Heterozygosity, PCA corrected
#p22005	Missingness
#p22006	Genetic ethnic grouping
#p22009_a1	Genetic principal components | Array 1
#p22010	Recommended genomic analysis exclusions
#p22011_a0	Genetic relatedness pairing | Array 0
#p22012_a0	Genetic relatedness factor | Array 0
#p22013_a0	Genetic relatedness IBS0 | Array 0
#p22018	Genetic relatedness exclusions
#p22019	Sex chromosome aneuploidy
#p22020	Used in genetic principal components
#p22021	Genetic kinship to other participants
#p22027	Outliers for heterozygosity or missing rate

## 1. select the Caucasian male 
qc1<-subset(all, participant.p22001==1 & participant.p22006 ==1)

## 1. select the male 
qc1<-subset(all, participant.p22001==1)

## 1. select the female 
qc1<-subset(all, participant.p22001==0)

qc_check_male <- data.frame(FID = qc1[,1], IID = qc1[,1])
write.table(qc_check_male, file = "qc_check_male.txt", quote = FALSE, sep = "\t", row.names = FALSE)


qc_check_female <- data.frame(FID = qc1[,1], IID = qc1[,1])
write.table(qc_check_female, file = "qc_check_female.txt", quote = FALSE, sep = "\t", row.names = FALSE)













