#setwd("/Users/maoyan/SynologyDrive")
#setwd("E:/nas/ukbA/data/liaoming/post_qc")
setwd("E:/nas/ukbA/data/yangchao")

#https://choishingwan.github.io/PRS-Tutorial/base/

library(dplyr)
library(data.table)

#The first step in Polygenic Risk Score (PRS) analyses is to generate or obtain the base data (GWAS summary statistics).

## a<-read.table("N96_meta_finnest_22062022.tsv",head=1)
## the colnanmes are as follows:
## chromosome	base_pair_location	effect_allele	other_allele	beta	standard_error	
## effect_allele_frequency	p_value	rs_id	n_studies	effects

a<-read.table("GCST90454222.h.tsv",head=1)

colnames(a)
## the colnanmes are as follows:
## chromosome	base_pair_location	effect_allele	other_allele	beta	standard_error	
## effect_allele_frequency	p_value	rsid	rs_id	n_studies	effects	hm_coordinate_conversion	hm_code	variant_id

is.na(a$effect_allele_frequency)%>%sum()
a<-a[!is.na(a$effect_allele_frequency),]

range(a$effect_allele_frequency)
a<-a[a$effect_allele_frequency >0.01,]

# SNP 	A1 	A2 	N 	SE 	P 	OR 	INFO 	MAF
#CHR: The chromosome in which the SNP resides
#BP: Chromosomal co-ordinate of the SNP
#SNP: SNP ID, usually in the form of rs-ID
#A1: The effect allele of the SNP
#A2: The non-effect allele of the SNP
#N: Number of samples used to obtain the effect size estimate
#SE: The standard error (SE) of the effect size esimate
#P: The P-value of association between the SNP genotypes and the base phenotype
#OR: The effect size estimate of the SNP, if the outcome is binary/case-control. If the outcome is continuous or treated as continuous then this will usually be BETA
#INFO: The imputation information score
#MAF: The minor allele frequency (MAF) of the SNP

a<-a[,c("rs_id","effect_allele","other_allele", "standard_error","p_value","beta","effect_allele_frequency")]
colnames(a)<-c("SNP","A1","A2", "SE","P","beta","MAF")
# Output the gz file
#fwrite(a, "a.gz", sep="\t")

# Remove duplicate rows based on SNP column and write to gzipped file
a_nodup <- a[!duplicated(a$SNP), ]
#fwrite(a_nodup, "a.nodup.gz", sep = "\t")

# Remove ambiguous SNPs (A/T, T/A, G/C, C/G) and write to gzipped file
ambiguous <- (a_nodup$A1 == "A" & a_nodup$A2 == "T") |
             (a_nodup$A1 == "T" & a_nodup$A2 == "A") |
             (a_nodup$A1 == "G" & a_nodup$A2 == "C") |
             (a_nodup$A1 == "C" & a_nodup$A2 == "G")
a_qc <- a_nodup[!ambiguous, ]
fwrite(a_qc, "base_a.QC.gz", sep = "\t")


