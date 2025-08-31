setwd("D:/0-dell-NAS/ukbA/data/liaoming/PRS/RPL") #from liaoming's dell

qc<-read.csv("Data10.csv")
table(qc$participant.p22001) 
table(qc$participant.p22006)
table(qc$participant.p22001,qc$participant.p22006)

#name	title
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

## 1. select the Caucasian female 
qc1<-subset(qc, participant.p22001==0 & participant.p22006 ==1)

## 2. Recommended genomic analysis exclusions
table(qc1$participant.p22010)
qc2<-subset(qc1,is.na(participant.p22010))

## 3. Genetic relatedness exclusions
table(qc2$participant.p22018)
qc3<-subset(qc2,is.na(participant.p22010))

## 4. remove Sex chromosome aneuploidy
table(qc3$participant.p22019)
qc4<-subset(qc3,is.na(participant.p22019))

## 5. remove Genetic kinship to other participants
table(qc4$participant.p22021)
qc5<-subset(qc4,participant.p22021==0)

## 6. remove Outliers for heterozygosity or missing rate
table(qc5$participant.p22027)

qc_check_sample <- data.frame(FID = qc5[,1], IID = qc5[,1])
write.table(qc_check_sample, file = "qc_check_samle.txt", quote = FALSE, sep = "\t", row.names = FALSE)













