# 耗材异常使用检测分析
# 创建者：GitHub Copilot
# 创建时间：2025-08-22

#我在统计耗材使用，想知道哪些是异常使用的耗材，该用什么方法怎么处理？这是数据：耗材名称，耗材单价，耗材使用数量，耗材可替代性3个级别，耗材权重ABC三级。
library(dplyr)
library(ggplot2)
library(VIM)  # 用于异常值检测
library(plotly)
library(readxl)

# 设置工作目录
setwd("C:/Users/Administrator/Nutstore/2/data/日常办公/质控数据")

# 示例数据结构（请替换为您的实际数据）
# data <- read_excel("耗材使用数据.xlsx")

# 创建示例数据用于演示
set.seed(123)
data <- data.frame(
  耗材名称 = paste0("耗材", 1:100),
  耗材单价 = runif(100, 10, 1000),
  耗材使用数量 = rpois(100, 50),
  耗材可替代性 = sample(c("高", "中", "低"), 100, replace = TRUE),
  耗材权重ABC = sample(c("A", "B", "C"), 100, replace = TRUE, prob = c(0.2, 0.3, 0.5)),
  stringsAsFactors = FALSE
)

# 添加一些异常值用于演示
data[1:5, "耗材使用数量"] <- c(200, 180, 220, 190, 210)  # 异常高使用量
data[96:100, "耗材使用数量"] <- c(2, 1, 3, 1, 2)        # 异常低使用量

# 计算总成本
data$总成本 <- data$耗材单价 * data$耗材使用数量

print("=== 耗材异常使用检测分析 ===")

# 方法1: 基于四分位距(IQR)的异常值检测
detect_outliers_iqr <- function(x) {
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  return(x < lower_bound | x > upper_bound)
}

# 方法2: 基于Z分数的异常值检测
detect_outliers_zscore <- function(x, threshold = 2.5) {
  z_scores <- abs(scale(x))
  return(z_scores > threshold)
}

# 方法3: 基于修正Z分数的异常值检测（对异常值更稳健）
detect_outliers_modified_zscore <- function(x, threshold = 3.5) {
  median_x <- median(x, na.rm = TRUE)
  mad_x <- mad(x, na.rm = TRUE)
  modified_z_scores <- 0.6745 * (x - median_x) / mad_x
  return(abs(modified_z_scores) > threshold)
}

# 对使用数量进行异常检测
data$异常_IQR_数量 <- detect_outliers_iqr(data$耗材使用数量)
data$异常_Z分数_数量 <- detect_outliers_zscore(data$耗材使用数量)
data$异常_修正Z分数_数量 <- detect_outliers_modified_zscore(data$耗材使用数量)

# 对总成本进行异常检测
data$异常_IQR_成本 <- detect_outliers_iqr(data$总成本)
data$异常_Z分数_成本 <- detect_outliers_zscore(data$总成本)
data$异常_修正Z分数_成本 <- detect_outliers_modified_zscore(data$总成本)

# 综合异常判断（任一方法检测为异常即为异常）
data$综合异常 <- data$异常_IQR_数量 | data$异常_Z分数_数量 | data$异常_修正Z分数_数量 |
                  data$异常_IQR_成本 | data$异常_Z分数_成本 | data$异常_修正Z分数_成本

# 输出异常统计
cat("\n=== 异常耗材统计 ===\n")
cat("总耗材数量:", nrow(data), "\n")
cat("检测到异常耗材数量:", sum(data$综合异常), "\n")
cat("异常比例:", round(sum(data$综合异常) / nrow(data) * 100, 2), "%\n")

# 按权重分类的异常统计
cat("\n=== 按权重分类的异常统计 ===\n")
abnormal_by_weight <- data %>%
  filter(综合异常 == TRUE) %>%
  group_by(耗材权重ABC) %>%
  summarise(
    异常数量 = n(),
    平均使用量 = round(mean(耗材使用数量), 2),
    平均成本 = round(mean(总成本), 2),
    .groups = 'drop'
  )
print(abnormal_by_weight)

# 按可替代性分类的异常统计
cat("\n=== 按可替代性分类的异常统计 ===\n")
abnormal_by_substitutability <- data %>%
  filter(综合异常 == TRUE) %>%
  group_by(耗材可替代性) %>%
  summarise(
    异常数量 = n(),
    平均使用量 = round(mean(耗材使用数量), 2),
    平均成本 = round(mean(总成本), 2),
    .groups = 'drop'
  )
print(abnormal_by_substitutability)

# 输出最异常的耗材清单
cat("\n=== 最异常的耗材（按总成本排序）===\n")
most_abnormal <- data %>%
  filter(综合异常 == TRUE) %>%
  arrange(desc(总成本)) %>%
  select(耗材名称, 耗材单价, 耗材使用数量, 总成本, 耗材权重ABC, 耗材可替代性) %>%
  head(10)
print(most_abnormal)

# 可视化1: 耗材使用量分布图
p1 <- ggplot(data, aes(x = 耗材使用数量, fill = 综合异常)) +
  geom_histogram(alpha = 0.7, bins = 20) +
  scale_fill_manual(values = c("FALSE" = "skyblue", "TRUE" = "red"),
                    labels = c("正常", "异常")) +
  labs(title = "耗材使用数量分布", 
       x = "使用数量", 
       y = "频数",
       fill = "状态") +
  theme_minimal() +
  theme(text = element_text(family = "SimSun"))

print(p1)

# 可视化2: 散点图 - 单价 vs 使用数量
p2 <- ggplot(data, aes(x = 耗材单价, y = 耗材使用数量, color = 综合异常, shape = 耗材权重ABC)) +
  geom_point(size = 3, alpha = 0.7) +
  scale_color_manual(values = c("FALSE" = "blue", "TRUE" = "red"),
                     labels = c("正常", "异常")) +
  facet_wrap(~耗材可替代性) +
  labs(title = "耗材单价与使用数量关系", 
       x = "单价（元）", 
       y = "使用数量",
       color = "状态",
       shape = "权重") +
  theme_minimal() +
  theme(text = element_text(family = "SimSun"))

print(p2)

# 可视化3: 箱线图 - 按权重分组的使用量分布
p3 <- ggplot(data, aes(x = 耗材权重ABC, y = 耗材使用数量, fill = 耗材权重ABC)) +
  geom_boxplot(alpha = 0.7) +
  geom_point(data = filter(data, 综合异常 == TRUE), 
             aes(color = "异常"), size = 2) +
  scale_color_manual(values = c("异常" = "red")) +
  labs(title = "不同权重耗材使用量分布", 
       x = "耗材权重", 
       y = "使用数量",
       fill = "权重",
       color = "") +
  theme_minimal() +
  theme(text = element_text(family = "SimSun"))

print(p3)

# 高级分析：考虑业务逻辑的异常检测
cat("\n=== 业务逻辑异常检测 ===\n")

# 规则1: A类高价值耗材使用量过高
high_value_overuse <- data %>%
  filter(耗材权重ABC == "A" & 耗材使用数量 > quantile(data$耗材使用数量, 0.9)) %>%
  select(耗材名称, 耗材使用数量, 总成本, 耗材可替代性)

cat("A类高价值耗材过度使用:\n")
print(high_value_overuse)

# 规则2: 高可替代性但高成本的耗材
substitutable_high_cost <- data %>%
  filter(耗材可替代性 == "高" & 总成本 > quantile(data$总成本, 0.8)) %>%
  select(耗材名称, 耗材单价, 耗材使用数量, 总成本)

cat("\n高可替代性但高成本耗材:\n")
print(substitutable_high_cost)

# 规则3: C类低价值但使用量异常高的耗材
low_value_overuse <- data %>%
  filter(耗材权重ABC == "C" & 耗材使用数量 > quantile(data$耗材使用数量, 0.9)) %>%
  select(耗材名称, 耗材使用数量, 耗材单价, 总成本)

cat("\nC类低价值但使用量异常高的耗材:\n")
print(low_value_overuse)

# 保存异常耗材清单
abnormal_materials <- data %>%
  filter(综合异常 == TRUE) %>%
  select(耗材名称, 耗材单价, 耗材使用数量, 总成本, 耗材权重ABC, 耗材可替代性,
         异常_IQR_数量, 异常_Z分数_数量, 异常_修正Z分数_数量,
         异常_IQR_成本, 异常_Z分数_成本, 异常_修正Z分数_成本)

# write.csv(abnormal_materials, "异常耗材清单.csv", row.names = FALSE, fileEncoding = "UTF-8")

cat("\n=== 处理建议 ===\n")
cat("1. 对异常使用的A类耗材进行重点关注，审查使用必要性\n")
cat("2. 高可替代性且高成本的耗材考虑替换为低成本替代品\n")
cat("3. C类低价值但使用量异常高的耗材需要审查使用规范\n")
cat("4. 建立耗材使用的动态监控机制\n")
cat("5. 定期分析使用趋势，及时发现异常模式\n")
