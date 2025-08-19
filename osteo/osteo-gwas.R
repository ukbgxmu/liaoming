#D:\R\ubuntu\code

### osteo from Zhengjie

Ins<-readxl::read_excel("D:/study/ouyingmei/epigraphdb-pqtl-master/data/Instruments.xlsx",1)
Ins[grep("BGLAP",Ins$Phenotype),]



## MR1
b<-read.table("D:/2-postDR/mo/osteocalcinGWAS20241024/data/pcos/GCST90077795/harmonised/34662886-GCST90077795-EFO_0000660.h.tsv/harmonised.qc.tsv",header =T)
colnames(b)
b$Phenotype="PCOS"
range(b$beta)
range(b$odds_ratio) #OR = exp(beta) 
b$beta<-log(b$odds_ratio)
outcome_dat<- format_data(b, type = "outcome", header = TRUE,
                          phenotype_col = "Phenotype", 
                          snp_col = "variant_id", beta_col = "beta",
                          se_col = "standard_error", 
                          eaf_col = "effect_allele_frequency", 
                          effect_allele_col = "effect_allele",
                          other_allele_col = "other_allele", pval_col = "p_value")


# harmonise the exposure and outcome data
dat <- harmonise_data(exposure_dat = Ins,outcome_dat = outcome_dat,action = 1)

# run the MR analyses and calculate OR
mr_results <- mr(dat) #此步耗时很长 # main MR analysis # method_list=c("mr_wald_ratio", "mr_ivw")
#saveRDS(mr_results,"./sun-pQTL-PCOS.rds")
#mr_results<-readRDS("./sun-pQTL-PCOS.rds")

ivw<- mr(dat, method_list=c( "mr_ivw")) #这一步很快
ivwOR<-generate_odds_ratios(ivw)



### MR2
Ins1$F1<-(Ins1$beta/Ins1$se)^2

# read in the outcome data
outcome_dat<- extract_outcome_data(snps = Ins1$SNP, proxies = TRUE, # notes:Extracting 1562 SNP(s) from 1 GWAS(s),proxies 123 SNP(s)
                                   outcomes =  "finn-b-E4_OVARFAIL")  
# harmonise the exposure and outcome data
Ins1$exposure<-"grn-ukb"
colnames(Ins1)[grep("beta",colnames(Ins1))]<-"beta.exposure"
colnames(Ins1)[grep("se",colnames(Ins1))]<-"se.exposure"
colnames(Ins1)[grep("effect_allele",colnames(Ins1))]<-"effect_allele.exposure"
colnames(Ins1)[grep("other_allele",colnames(Ins1))]<-"other_allele.exposure"
colnames(Ins1)[grep("eaf",colnames(Ins1))]<-"eaf.exposure"
dat1 <- harmonise_data(exposure_dat = Ins1,outcome_dat = outcome_dat) 
mr_results2 <- mr(dat1) #此步耗时很长 # main MR analysis # method_list=c("mr_wald_ratio", "mr_ivw")
ivw<- mr(dat1, method_list=c( "mr_ivw")) #这一步很快
ivwOR<-generate_odds_ratios(ivw)


