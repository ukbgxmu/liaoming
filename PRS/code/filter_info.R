#!/usr/bin/env Rscript

# 获取命令行参数
args <- commandArgs(trailingOnly = TRUE)

# 检查参数数量
if (length(args) < 2) {
  stop("Usage: Rscript filter_info.R <input_file> <output_file> [info_threshold]")
}

# 解析参数
input_file <- args[1]
output_file <- args[2]
info_threshold <- ifelse(length(args) > 2, as.numeric(args[3]), 0.8)

# 读取数据，假设没有表头
data <- read.table(input_file, header = FALSE, sep = "")

# 筛选 INFO 分数 > 阈值的行
high_info_data <- data[data$V8 > info_threshold, ]

# 提取 SNP ID（第2列）并保存
high_info_snps <- high_info_data$V2
write.table(high_info_snps, output_file, row.names = FALSE, col.names = FALSE, quote = FALSE)

# 输出处理信息
message("Processed ", nrow(data), " SNPs from ", input_file)
message("Saved ", length(high_info_snps), " high-quality SNPs (INFO > ", info_threshold, ") to ", output_file)