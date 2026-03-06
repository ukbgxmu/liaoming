setwd("D:/0-dell-NAS/ukbA/data/suqin/RPL and CVD原始数据/2025.8.30") #from liaoming's dell
setwd("D:/0-dell-NAS/ukbA/data/liaoming/PRS/RPL") #from liaoming's dell

co<-read.csv("merged_all_Data1-9_innerjoin.csv")

#p21022	Age at recruitment
#p22000	Genotype measurement batch
#p22001	Genetic sex
#p22009_a1	Genetic principal components | Array 1
#p22009_a2	Genetic principal components | Array 2
#p22009_a3	Genetic principal components | Array 3
#3p22009_a4	Genetic principal components | Array 4
#p22009_a5	Genetic principal components | Array 5
#p22009_a6	Genetic principal components | Array 6
#p22009_a7	Genetic principal components | Array 7
#p22009_a8	Genetic principal components | Array 8
#p22009_a9	Genetic principal components | Array 9
#p22009_a10	Genetic principal components | Array 10
#p22189	Townsend deprivation index at recruitment
#p41267_a0	Number of previous pregnancies | Array 0

# 提取需要的列名
cols <- c(
  "participant.eid",
  "participant.p21022",
  "participant.p22000",
  "participant.p22001",
  "participant.p22009_a1",
  "participant.p22009_a2",
  "participant.p22009_a3",
  "participant.p22009_a4",
  "participant.p22009_a5",
  "participant.p22009_a6",
  "participant.p22009_a7",
  "participant.p22009_a8",
  "participant.p22009_a9",
  "participant.p22009_a10",
  "participant.p22189",
  "participant.p41267_a0"
)

co_var <- co[, cols]
ph <- data.frame(
  FID = co_var$participant.eid,
  IID = co_var$participant.eid,
  RPL = ifelse(is.na(co_var$participant.p41267_a0) | co_var$participant.p41267_a0 < 3, 0, 1)
)

table(ph$RPL)

co_new <- data.frame(
  FID = co_var$participant.eid,
  IID = co_var$participant.eid,
  Sex = co_var$participant.p22001,
  PC1 = co_var$participant.p22009_a1,
  PC2 = co_var$participant.p22009_a2,
  PC3 = co_var$participant.p22009_a3,
  PC4 = co_var$participant.p22009_a4,
  PC5 = co_var$participant.p22009_a5,
  PC6 = co_var$participant.p22009_a6,
  PC7 = co_var$participant.p22009_a7,
  PC8 = co_var$participant.p22009_a8,
  PC9 = co_var$participant.p22009_a9,
  PC10 = co_var$participant.p22009_a10
)
summarise(co_new[,-1:-2])

write.table(ph, file = "pheno.txt", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(co_new, file = "covar.txt", sep = "\t", row.names = FALSE, quote = FALSE)

