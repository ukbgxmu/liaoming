## 第一步先修改工作目录，为导入数据所在的目录
setwd("D:/2-postDR/mo/osteocalcinGWAS20241024/data/RPL/GCST/2025/harmonised")  # from liaoming's Dell

#https://choishingwan.github.io/PRS-Tutorial/base/

#The first step in Polygenic Risk Score (PRS) analyses is to generate or obtain the base data (GWAS summary statistics).

library(dplyr)
library(data.table)

a<-read_tsv("GCST90454222.h.tsv.gz")

colnames(a)
## the colnanmes are as follows:
#[1] "chromosome"               "base_pair_location"       "effect_allele"            "other_allele"             "beta"                    
#[6] "standard_error"           "effect_allele_frequency"  "p_value"                  "rsid"                     "rs_id"                   
#[11] "n_studies"                "effects"                  "hm_coordinate_conversion" "hm_code"                  "variant_id" 

## 1. Standard GWAS QC
#We recommend removing SNPs with MAF < 1% and INFO < 0.8
#(with very large base sample sizes these thresholds could be reduced if sensitivity checks indicate reliable results)
range(a$effect_allele_frequency) # 0.00002 0.99998
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

a<-a[,c("rs_id","chromosome","base_pair_location","effect_allele","other_allele", "standard_error","p_value","beta","effect_allele_frequency")]
colnames(a)<-c("SNP","CHR","BP","A1","A2", "SE","P","beta","MAF")

## 2. Duplicate SNPs
# Remove duplicate rows based on SNP column 
duplicated(a$SNP) %>% sum()
a_nodup <- a[!duplicated(a$SNP), ]


## 3. Ambiguous SNPs
# Remove ambiguous SNPs (A/T, T/A, G/C, C/G) 
ambiguous <- (a_nodup$A1 == "A" & a_nodup$A2 == "T") |
  (a_nodup$A1 == "T" & a_nodup$A2 == "A") |
  (a_nodup$A1 == "G" & a_nodup$A2 == "C") |
  (a_nodup$A1 == "C" & a_nodup$A2 == "G")
sum(ambiguous)
a_qc <- a_nodup[!ambiguous, ]

table(a_qc$CHR)

# write to gzipped file
# fwrite(a_qc, "base_GCST90454222.QC.gz", sep = "\t")


## 4. change beta(se) to OR(se) 
colnames(a_qc)

a_qc1<-a_qc

# 计算 OR 和 SE
a_qc1$OR <- exp(a_qc1$beta)
se_logOR <- a_qc1$SE
a_qc1$se_OR <- a_qc1$OR * se_logOR

colnames(a_qc1)[ncol(a_qc1)]<-"se"

a_qc1$BP = as.integer(a_qc1$BP)

## 5. write to gzipped file
fwrite(a_qc1[,c("SNP","CHR","BP","A1",
                "A2","P","OR","se")], "base_OR_GCST90454222.QC.gz", sep = "\t")

#PRSice-2 accepts:
  
#A base data file *.assoc containing GWAS summary statistics. This file should contain the following columns (please note that the exact header names given below are expected by the app):
#SNP: SNP ID, usually in the form of rs-ID.
#CHR: The chromosome in which the SNP resides.
#BP: Chromosomal co-ordinate of the SNP.
#A1: The effect allele of the SNP.
#A2: The non-effect allele of the SNP.
#P: The P-value of association between the SNP genotypes and the base phenotype.
#OR: The effect size estimate of the SNP, if the outcome is binary/case-control. If the outcome is continuous or treated as continuous then this will be the BETA.


