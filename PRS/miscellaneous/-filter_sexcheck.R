#!/usr/bin/env Rscript

# filter_sexcheck.R - 基于性别检查结果过滤样本的通用R脚本
# 用法: Rscript filter_sexcheck.R [有效样本文件] [性别检查文件] [输出文件]

args <- commandArgs(trailingOnly = TRUE)

# 检查参数
if (length(args) < 3) {
  cat("用法: Rscript filter_sexcheck.R <有效样本文件> <性别检查文件> <输出文件>\n")
  cat("示例: Rscript filter_sexcheck.R EUR.valid.sample EUR.QC.sexcheck EUR.QC.valid\n")
  quit(status = 1)
}

valid_sample_file <- args[1]
sexcheck_file <- args[2]
output_file <- args[3]

# 检查文件是否存在
if (!file.exists(valid_sample_file)) {
  cat("错误: 有效样本文件", valid_sample_file, "不存在\n")
  quit(status = 1)
}

if (!file.exists(sexcheck_file)) {
  cat("错误: 性别检查文件", sexcheck_file, "不存在\n")
  quit(status = 1)
}

cat("正在处理文件...\n")
cat("有效样本文件:", valid_sample_file, "\n")
cat("性别检查文件:", sexcheck_file, "\n")
cat("输出文件:", output_file, "\n")

# 读取有效样本文件
cat("读取有效样本文件...\n")
valid_samples <- read.table(valid_sample_file, header = TRUE)

# 检查有效样本文件的列
if (!all(c("FID", "IID") %in% colnames(valid_samples))) {
  cat("错误: 有效样本文件必须包含 'FID' 和 'IID' 列\n")
  quit(status = 1)
}

# 读取性别检查文件
cat("读取性别检查文件...\n")
sexcheck_data <- read.table(sexcheck_file, header = TRUE)

# 检查性别检查文件的列
required_cols <- c("FID", "IID", "STATUS")
if (!all(required_cols %in% colnames(sexcheck_data))) {
  cat("错误: 性别检查文件必须包含以下列:", paste(required_cols, collapse = ", "), "\n")
  quit(status = 1)
}

cat("有效样本数:", nrow(valid_samples), "\n")
cat("性别检查样本数:", nrow(sexcheck_data), "\n")

# 筛选STATUS为"OK"且在有效样本中的样本
cat("筛选STATUS为'OK'的样本...\n")
valid_sexcheck <- subset(sexcheck_data, STATUS == "OK" & FID %in% valid_samples$FID)

cat("通过性别检查的有效样本数:", nrow(valid_sexcheck), "\n")

# 统计STATUS状态
status_counts <- table(sexcheck_data$STATUS)
cat("性别检查状态统计:\n")
for (status in names(status_counts)) {
  cat("  ", status, ":", status_counts[status], "\n")
}

# 写入结果
cat("写入结果文件...\n")
write.table(valid_sexcheck[, c("FID", "IID")], 
            output_file, 
            row.names = FALSE, 
            col.names = FALSE, 
            sep = "\t", 
            quote = FALSE)

cat("处理完成! 结果已保存到:", output_file, "\n")
cat("最终保留样本数:", nrow(valid_sexcheck), "\n")