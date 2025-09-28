# 科室排名直方图生成脚本
# 此脚本用于读取Excel文件中的科室排名数据，提取前10名并生成直方图

# 加载必要的库
library(readxl)
library(ggplot2)
library(dplyr)

# 设置工作目录（请根据实际情况修改）
setwd("E:/朱瓦力") # 可以根据需要修改为实际的文件路径

# 提示用户输入Excel文件路径
cat("请输入Excel文件的完整路径（例如：E:/朱瓦力/科室排名.xlsx）：")
excel_file <- readline()

# 提示用户输入图表标题
cat("请输入图表标题：")
chart_title <- readline()

# 读取Excel文件
# 假设Excel文件中第一列是科室名称，第二列是排名数值
# 如果实际列名不同，用户可以修改以下代码
rank_data <- read_excel(excel_file)

# 查看数据结构，帮助用户了解如何调整代码
cat("\nExcel文件数据结构：\n")
print(str(rank_data))
cat("\n请确认数据结构是否符合预期。如果不符合，请根据实际情况修改脚本中的列名。\n")

# 默认使用第一列为科室名称，第二列为排名数值
# 用户可以根据实际情况修改以下列名
# 例如：如果科室列名为"科室"，数值列名为"数值"，则修改为：
# department_col <- "科室"
# value_col <- "数值"
department_col <- colnames(rank_data)[1]
value_col <- colnames(rank_data)[2]

cat(paste0("\n当前使用：\n科室列: ", department_col, "\n数值列: ", value_col, "\n"))
cat("如果需要修改列名，请在脚本中直接修改department_col和value_col的值。\n")

# 排序数据并选择前10名
# 假设数值越大排名越靠前
# 如果需要按数值升序排序（数值越小排名越靠前），请将desc()删除
top_10_depts <- rank_data %>%
  arrange(desc(!!sym(value_col))) %>%
  head(10)

# 将科室名称转换为因子，保持排序顺序
top_10_depts[[department_col]] <- factor(top_10_depts[[department_col]], 
                                         levels = top_10_depts[[department_col]])

# 创建直方图
plot <- ggplot(top_10_depts, aes_string(x = department_col, y = value_col, fill = department_col)) +
  geom_col() +
  # 在柱子上添加数值标签，保留2位小数
  geom_text(aes_string(label = sprintf("%.2f", !!sym(value_col))), 
            vjust = -0.5, size = 3) +
  # 设置标题和坐标轴标签
  labs(title = chart_title,
       x = "科室",
       y = value_col) +
  # 设置主题，旋转x轴标签以避免重叠
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none") # 移除图例，因为科室名称已经在x轴上显示

# 显示图表
print(plot)

# 提示用户是否保存图表
cat("\n是否保存图表？(y/n): ")
save_chart <- readline()

if (tolower(save_chart) == "y") {
  cat("请输入保存的文件名（例如：科室排名直方图.png）：")
save_file <- readline()
  # 保存图表
  ggsave(save_file, plot = plot, width = 12, height = 8, dpi = 300)
  cat(paste0("图表已保存至：", save_file, "\n"))
}

cat("\n脚本执行完成！\n")