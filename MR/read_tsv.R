#library(readr)
#a<-read_tsv("/Users/maoyan/Library/CloudStorage/SynologyDrive-ukbA/data/liaoming/MR/meta_analysis_ukbb_summary_stats_filtered_finngen_R11_E4_OBESITY_meta_out_filtered.tsv.tsv")
#直接读入tsv太占内存
#library(rtracklayer) 或 library(VariantAnnotation)

setwd("~/Downloads")

#测试的SNP：
#rs671
#12:111803962 (GRCh38)
#12:112241766 (GRCh37)

library(Rsamtools)
# 定义要查询的基因组区域
target_range <- "12:123450000-123456789"  # 替换成你感兴趣的染色体区域

# 使用Tabix提取数据
tabix_file <- TabixFile("meta_analysis_ukbb_summary_stats_filtered_finngen_R11_C_STROKE_meta_out_filtered.tsv.tsv",
                        index = "meta_analysis_ukbb_summary_stats_filtered_finngen_R11_C_STROKE_meta_out_filtered.tsv.gz.tbi")
result <- scanTabix(tabix_file, param = GRanges(target_range)) #


# 读取文件前几行检查列名
file_lines <- readLines("meta_analysis_ukbb_summary_stats_filtered_finngen_R11_C_STROKE_meta_out_filtered.tsv.tsv", n = 5)
#print(file_lines)
# 使用您从readLines获取的列名
col_names <- unlist(strsplit(sub("^#", "", file_lines[1]), "\t"))

# 读取数据并修改列名
data <- read.delim(textConnection(result[[1]]), header = FALSE)
colnames(data) <- col_names
head(data)
# 读取数据并应用列名，这一步性能优化：对于大型文件，考虑使用data.table包：
library(data.table)
data <- fread(text = result[[1]], header = FALSE)
setnames(data, col_names)

#CHR 	染色体号
#POS 	基因组位置
#REF 	参考等位基因
#ALT 	变异等位基因
#SNP 	SNP标识符
#FINNGEN_beta 	FinnGen研究的效应值
#FINNGEN_sebeta 	FinnGen研究的标准误
#FINNGEN_pval 	FinnGen研究的p值
#FINNGEN_af_alt 	FinnGen研究的变异等位基因频率
#UKBB_beta 	UK Biobank研究的效应值
#UKBB_sebeta 	UK Biobank研究的标准误
#UKBB_pval 	UK Biobank研究的p值
#UKBB_af_alt 	UK Biobank研究的变异等位基因频率
#all_meta_N 	元分析总样本量
#all_inv_var_meta_beta 	逆方差加权元分析效应值
#all_inv_var_meta_sebeta 	逆方差加权元分析标准误
#all_inv_var_meta_p 	逆方差加权元分析p值
#rsid 	rs标识符

#数据验证：读取后使用以下命令检查数据结构：
#str(data)
#(data)

#处理缺失值：基因组数据常有缺失值，
data <- na.omit(data)  # 或使用其他缺失值处理策略

#数据分析：如需进行元分析，确保效应值方向一致：
# 检查效应值方向一致性
# cor(data$FINNGEN_beta, data$UKBB_beta, use = "complete.obs")

#通过以上方法，您应该能够正确读取包含列名的基因组数据，并进行后续分析。


#查看是否有染色体X
result_test <- scanTabix(tabix_file, 
                    param = GRanges(seqnames = 23, ranges = IRanges(start = 123456788, end = 259000000))) #




















library(Rsamtools)
library(GenomicRanges)
library(dplyr)

### 0. 先测试能否按染色体导入 ### （结果：此步太占内存，改成按染色体分区间）
# 设置文件
#tabix_file <- TabixFile("meta_analysis_ukbb_summary_stats_filtered_finngen_R11_C_STROKE_meta_out_filtered.tsv.tsv")

# 获取染色体列表（假设1-22号染色体）
chromosomes <- 23:1 # 或者直接1:22，根据文件中的染色体命名

# 初始化一个空数据框存储显著SNP
# 各列的属性与data相同
significant_snps <- data[0, ] #significant_snps <- data.frame()


# 循环每个染色体
for (chr in chromosomes) {
  # 定义整个染色体的范围
  gr <- GRanges(seqnames = chr, ranges = IRanges(start = 1, end = 250000000))
  
  # 提取该染色体所有SNP
  chr_data <- scanTabix(tabix_file, param = gr) %>% 
    lapply(function(x) {
      # 将文本行转换为数据框
      df <- read.delim(text = x, header = FALSE, stringsAsFactors = FALSE)
      colnames(df) <- col_names
      # Ensure consistent column types
      df <- type.convert(df, as.is = TRUE)
      return(df)
    }) %>% 
    bind_rows()
  
  # 过滤显著SNP (pval < 5e-8)
  sig_chr <- chr_data %>% filter(all_inv_var_meta_p < 5e-8)
  
  # 添加到总表
  significant_snps <- bind_rows(significant_snps, sig_chr)
  
  # 打印进度
  message(sprintf("Chromosome %s: extracted %d significant SNPs", chr, nrow(sig_chr)))
}

# 现在significant_snps包含了全基因组所有显著SNP

# 查看结果
print(significant_snps)




### 1. 先统计数目 ###

# 设置文件
chromosomes <- 23:1  # 假设1-23号染色体

# 初始化一个空数据框存储结果
chromosome_stats <- data.frame(
  Chromosome = integer(),
  Max_Pos = numeric(),
  Min_P_Value = numeric(),
  SNPs_P_Less_5e_8 = integer(),
  SNPs_P_Less_5e_7 = integer(),
  SNPs_P_Less_5e_6 = integer(),
  stringsAsFactors = FALSE
)

# 循环每个染色体
for (chr in chromosomes) {
  # 定义整个染色体的范围
  gr <- GRanges(seqnames = chr, ranges = IRanges(start = 1, end = 250000000))
  
  # 提取该染色体所有SNP
  chr_data <- scanTabix(tabix_file, param = gr) %>% 
    lapply(function(x) {
      # 将文本行转换为数据框
      df <- read.delim(text = x, header = FALSE, stringsAsFactors = FALSE)
      colnames(df) <- col_names
      # Ensure consistent column types
      df <- type.convert(df, as.is = TRUE)
      return(df)
    }) %>% 
    bind_rows()
  
  # 统计最小all_inv_var_meta_p
  min_p_value <- min(chr_data$all_inv_var_meta_p, na.rm = TRUE)
  
  # 统计最大POS
  max_pos <- max(chr_data$POS, na.rm = TRUE)
  
  # 统计不同p值阈值下的SNP数量
  snps_p_less_5e_8 <- sum(chr_data$all_inv_var_meta_p < 5e-8, na.rm = TRUE)
  snps_p_less_5e_7 <- sum(chr_data$all_inv_var_meta_p < 5e-7, na.rm = TRUE)
  snps_p_less_5e_6 <- sum(chr_data$all_inv_var_meta_p < 5e-6, na.rm = TRUE)
  
  # 添加到结果数据框
  chromosome_stats <- rbind(chromosome_stats, data.frame(
    Chromosome = chr,
    Min_P_Value = min_p_value,
    Max_Pos = max_pos,
    SNPs_P_Less_5e_8 = snps_p_less_5e_8,
    SNPs_P_Less_5e_7 = snps_p_less_5e_7,
    SNPs_P_Less_5e_6 = snps_p_less_5e_6
  ))
  
  # 打印进度
  message(sprintf("Chromosome %s: Max Pos = %d, Min P = %g, SNPs < 5e-8 = %d, < 5e-7 = %d, < 5e-6 = %d", 
                  chr, max_pos, min_p_value, snps_p_less_5e_8, snps_p_less_5e_7, snps_p_less_5e_6))
}

# 查看结果
print(chromosome_stats)








#### 2. 按染色体分区间 ######

# 定义染色体和区间
chromosomes <- 23:1
chunk_size <- 1000000  # 1Mb区间

# 初始化,直接创建新空数据框
significant_snps <- data[0, ] #significant_snps <- data.frame()

for (chr in chromosomes) {
  # 假设染色体长度（单位bp）
  chr_length <- chromosome_stats %>% 
    filter(Chromosome == chr) %>% 
    pull(Max_Pos)
  #chr_length <- 250000000
  
  # 计算区间数
  starts <- seq(1, chr_length, by = chunk_size)
  ends <- starts + chunk_size - 1
  ends[length(ends)] <- chr_length  # 最后一个区间到染色体末尾
  
  for (i in seq_along(starts)) {
    gr <- GRanges(seqnames = chr, 
                  ranges = IRanges(start = starts[i], end = ends[i]))
    
    # 提取该区间
    chunk_data <- scanTabix(tabix_file, param = gr) %>% 
      lapply(function(x) {
        if (length(x)==0) return(NULL)
        df <- read.delim(text = x, header = FALSE, stringsAsFactors = FALSE)
        colnames(df) <- col_names
        # Ensure consistent column types
        df <- type.convert(df, as.is = TRUE)  ### ???
        return(df)
      }) %>% 
      bind_rows()
    
    if (nrow(chunk_data) == 0) next
    
    # 过滤显著SNP
    sig_chunk <- chunk_data %>% filter(all_inv_var_meta_p < 5e-8)
    
    # 添加到总表
    significant_snps <- bind_rows(significant_snps, sig_chunk)
  }
  message(sprintf("Chromosome %s done.", chr))
}
