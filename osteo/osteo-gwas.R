#### prepare the exposure data of osteocalcin for MR #####

### 1.osteo from Zhengjie

## input file
# from liaoming's dell
Ins<-readxl::read_excel("D:/study/ouyingmei/epigraphdb-pqtl-master/data/Instruments.xlsx",1)
Ins[grep("BGLAP",Ins$Phenotype),]

# frome liaoming macbook Pro
setwd("~/Documents/GitHub/liaoming/osteo")
Ins<-readxl::read_excel("output/Instruments.xlsx",1)

## prepare file
# select osteocalcin
osteo<-Ins[grep("BGLAP",Ins$Phenotype),]
(osteo$beta/osteo$se)^2
colnames(osteo)

osteo$Phenotype="osteo"
exposure_dat<- format_data(osteo, type = "exposure", header = TRUE,
                          phenotype_col = "Phenotype", 
                          snp_col = "SNP", beta_col = "beta",
                          se_col = "se", 
                          eaf_col = "eaf",  
                          effect_allele_col = "effect_allele",
                          other_allele_col = "other_allele", pval_col = "pval")


#rs5030062  rs5030062 - chr3:186736291-186736491 hg38 (Human Dec. 2013 (GRCh38/hg38))
#rs4253254 
#rs62143194 

library(TwoSampleMR)  #remotes::install_github("MRCIEU/TwoSampleMR")
library(Rsamtools)
library(data.table)

## MR1
setwd("/Users/maoyan/Library/CloudStorage/SynologyDrive-ukbA/data/liaoming/MR")

#obesity
file_tsv<-"meta_analysis_ukbb_summary_stats_filtered_finngen_R11_E4_OBESITY_meta_out_filtered.tsv.tsv"
file_tbi<-"meta_analysis_ukbb_summary_stats_filtered_finngen_R11_E4_OBESITY_meta_out_filtered.tsv.gz.tbi"
pheno_name<-"obesity"

target_range <- "3:186736291-186736491"  # 替换成你感兴趣的染色体区域
# 使用Tabix提取数据
tabix_file <- TabixFile(file_tsv,index = file_tbi)
result <- scanTabix(tabix_file, param = GRanges(target_range)) #
# 读取文件前几行检查列名
file_lines <- readLines(file_tsv, n = 5)
col_names <- unlist(strsplit(sub("^#", "", file_lines[1]), "\t"))
data <- fread(text = result[[1]], header = FALSE)
setnames(data, col_names)

data$Phenotype=pheno_name
outcome_dat<- format_data(data.frame(data), type = "outcome", header = TRUE,
                          phenotype_col = "Phenotype", 
                          snp_col = "rsid", beta_col = "all_inv_var_meta_beta",
                          se_col = "all_inv_var_meta_sebeta", 
                         # eaf_col = "FINNGEN_af_alt", 
                          eaf_col = "UKBB_af_alt",  
                          effect_allele_col = "ALT",
                          other_allele_col = "REF", pval_col = "all_inv_var_meta_p")
# harmonise the exposure and outcome data
dat <- harmonise_data(exposure_dat = exposure_dat,outcome_dat = outcome_dat,action = 1)

# run the MR analyses and calculate OR
mr_results <- mr(dat) 
ivw<- mr(dat, method_list=c( "mr_ivw")) 
ivwOR<-generate_odds_ratios(ivw)


### 2. steo from our meta
a<-read.table("D:/R/ubuntu/code/ocn.meta-results5e8.txt",head=T) #
a$Phenotype="osteocalcin"
Ins<-format_data(a, type = "exposure", header = TRUE,
                 phenotype_col = "Phenotype", snp_col = "SNP", beta_col = "beta",
                 se_col = "se", 
                 #eaf_col = "effect_allele_frequency", 
                 effect_allele_col = "other_allele",
                 other_allele_col = "reference_allele", pval_col = "p.value")
Inss<-clump_data(
  Ins,
  clump_kb = 10000,
  clump_r2 = 0.001,
  clump_p1 = 5e-08,
  clump_p2 = 5e-08,
  pop = "EUR", #Options are "EUR", "SAS", "EAS", "AFR", "AMR".
  bfile = NULL,
  plink_bin = NULL
)
head(Inss)
(Inss$beta.exposure/Inss$se.exposure)^2

Inss$Phenotype="osteo"
exposure_dat<- format_data(Inss, type = "exposure", header = TRUE,
                           phenotype_col = "Phenotype", 
                           snp_col = "SNP", beta_col = "beta.exposure",
                           se_col = "se.exposure", 
                          # eaf_col = "eaf",  
                           effect_allele_col = "effect_allele.exposure",
                           other_allele_col = "other_allele.exposure", pval_col = "pval.exposure")

