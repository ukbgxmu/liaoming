#!/usr/bin/env Rscript

# filter_samples.R - 过滤样本的通用R脚本
# 用法: Rscript filter_samples.R [输入文件] [输出文件]

args <- commandArgs(trailingOnly = TRUE)

# 检查参数
if (length(args) < 2) {
  cat("用法: Rscript filter_samples.R <输入文件> <输出文件>\n")
  cat("示例: Rscript filter_samples.R EUR.QC.het EUR.valid.sample\n")
  quit(status = 1)
}

input_file <- args[1]
output_file <- args[2]

# 检查文件是否存在
if (!file.exists(input_file)) {
  cat("错误: 输入文件", input_file, "不存在\n")
  quit(status = 1)
}

cat("正在处理文件:", input_file, "\n")

# 读取数据
dat <- read.table(input_file, header = TRUE)

# 检查必要的列是否存在
if (!"F" %in% colnames(dat)) {
  cat("错误: 输入文件必须包含 'F' 列\n")
  quit(status = 1)
}

if (!all(c("FID", "IID") %in% colnames(dat))) {
  cat("错误: 输入文件必须包含 'FID' 和 'IID' 列\n")
  quit(status = 1)
}

# 计算统计量
m <- mean(dat$F)
s <- sd(dat$F)

cat("F值的平均值:", round(m, 6), "\n")
cat("F值的标准差:", round(s, 6), "\n")
cat("有效范围:", round(m - 3*s, 6), "到", round(m + 3*s, 6), "\n")

# 筛选有效样本
valid <- subset(dat, F <= m + 3*s & F >= m - 3*s)

cat("总样本数:", nrow(dat), "\n")
cat("有效样本数:", nrow(valid), "\n")
cat("排除样本数:", nrow(dat) - nrow(valid), "\n")

# 写入有效样本
write.table(valid[, c("FID", "IID")], output_file, quote = FALSE, row.names = FALSE, col.names = TRUE)

cat("结果已保存到:", output_file, "\n")
cat("处理完成!\n")