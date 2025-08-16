setwd("/Users/maoyan/Library/CloudStorage/SynologyDrive-ukbB/data/wenjingyu")
#from liaoming's macbook Pro


##
library(dplyr)
library(stringr)

## 1.导入诊断的数据（含 ICD9,ICD10）

a <- read.csv("41202.csv", row.names = 1) 
#计算"41202.csv"含有6011的行数
a %>% filter(str_detect(participant.p41202, "N411")) %>% nrow() #782
# 提取a$participant.p41202里含有 "N411" 的行并查看
a_filtered <- a %>% filter(str_detect(participant.p41202, "N411"))
head(a_filtered$participant.p41202)

a <- read.csv("41203.csv", row.names = 1) 
#计算"41203.csv"含有6011的行数
a %>% filter(str_detect(participant.p41203, "6011")) %>% nrow() #12

a <- read.csv("41204.csv", row.names = 1) 
#计算"41204.csv"含有6011的行数
a %>% filter(str_detect(participant.p41204, "N411")) %>% nrow() #1045

a <- read.csv("41205.csv", row.names = 1) 
#计算"41205.csv"含有6011的行数
a %>% filter(str_detect(participant.p41205, "6011")) %>% nrow() #3

a <- read.csv("41270.csv", row.names = 1) 
#计算"41270.csv"含有N411的行数
a %>% filter(str_detect(participant.p41270, "N411")) %>% nrow() #1724

a <- read.csv("41271.csv", row.names = 1) 
#计算"41271.csv"含有6011的行数
a %>% filter(str_detect(participant.p41271, "6011")) %>% nrow() #15

# 导入所有文件
files <- list("41202.csv", "41203.csv", "41204.csv", "41205.csv", "41270.csv", "41271.csv")
data_list <- lapply(files, function(file) read.csv(file, row.names = 1))

# 合并所有文件
merged_data <- Reduce(function(x, y) {
    merged <- merge(x, y, by = "row.names", all = TRUE)
    rownames(merged) <- merged$Row.names
    merged$Row.names <- NULL
    return(merged)
}, data_list)

# 创建cpps列，标识来源
merged_data$cpps <- apply(merged_data, 1, function(row) {
    sources <- c()
    if (any(str_detect(row["participant.p41202"], "N411"), na.rm = TRUE)) sources <- c(sources, "41202")
    if (any(str_detect(row["participant.p41203"], "6011"), na.rm = TRUE)) sources <- c(sources, "41203")
    if (any(str_detect(row["participant.p41204"], "N411"), na.rm = TRUE)) sources <- c(sources, "41204")
    if (any(str_detect(row["participant.p41205"], "6011"), na.rm = TRUE)) sources <- c(sources, "41205")
    if (any(str_detect(row["participant.p41270"], "N411"), na.rm = TRUE)) sources <- c(sources, "41270")
    if (any(str_detect(row["participant.p41271"], "6011"), na.rm = TRUE)) sources <- c(sources, "41271")
    paste(sources, collapse = ",")
})

write.csv(merged_data, "1_merged_data.csv", row.names = TRUE)

#统计所有诊断cpps的样本
sum(merged_data$cpps!="") #1739

#统计所有诊断全是“”的样本  
sum(merged_data$participant.p41202 =="" &
    merged_data$participant.p41203 =="" & 
    merged_data$participant.p41204 =="" & 
    merged_data$participant.p41205 =="" &
    merged_data$participant.p41270 =="" &
    merged_data$participant.p41271 ==""
    )  #26022

nrow(merged_data) #228913

#未患前列腺炎的对照组样本数 
nrow(merged_data) -26022-1739  #201152


1739/201152
