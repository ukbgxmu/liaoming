# 加载必要的库
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

# 读取数据
tmp <- read_excel("./每日入院8小时.xls")

# 查看数据结构，确认列名
cat("数据结构信息：\n")
print(str(tmp))
print(head(tmp))

# 假设数据中包含以下列名，如有不同请用户根据实际情况修改
# 年度列名
year_col <- "年度"
# 总入院人数列名
total_patients_col <- "同期入院患者总人次数"
# 8小时内开具医嘱人数列名
within_8h_orders_col <- "入院 8 小时内开具医嘱的患者人次数"
# 8小时内查房率列名
within_8h_round_rate_col <- "患者入院 8 小时内查房率"

# 确保列名存在
if (!(year_col %in% colnames(tmp)) || 
    !(total_patients_col %in% colnames(tmp)) || 
    !(within_8h_orders_col %in% colnames(tmp)) || 
    !(within_8h_round_rate_col %in% colnames(tmp))) {
  stop("必要的列名不存在，请检查数据列名并修改脚本中的列名定义")
}

# 处理数据，确保只有2个年度的数据
years_data <- tmp %>%
  group_by(!!sym(year_col)) %>%
  summarise(
    !!total_patients_col := sum(!!sym(total_patients_col), na.rm = TRUE),
    !!within_8h_orders_col := sum(!!sym(within_8h_orders_col), na.rm = TRUE),
    !!within_8h_round_rate_col := mean(!!sym(within_8h_round_rate_col), na.rm = TRUE)
  )

# 确保只有2个年度的数据
if (nrow(years_data) > 2) {
  warning("数据中包含超过2个年度，将仅使用前2个年度的数据")
  years_data <- years_data[1:2, ]
}

# 计算非8小时内开具医嘱的人数（用于堆积图的另一部分）
years_data <- years_data %>%
  mutate(
    非8小时内开具医嘱人数 = !!sym(total_patients_col) - !!sym(within_8h_orders_col)
  )

# 重塑数据用于堆积图
stack_data <- years_data %>%
  pivot_longer(
    cols = c(!!sym(within_8h_orders_col), 非8小时内开具医嘱人数),
    names_to = "类别",
    values_to = "人数"
  )

# 创建组合图
# 先创建基础图（堆积图）
g <- ggplot() +
  # 添加堆积图
  geom_col(
    data = stack_data,
    aes(x = !!sym(year_col), y = 人数, fill = 类别),
    position = "stack",
    width = 0.6  # 调整柱状图粗细
  ) +
  # 设置左侧y轴（人数）
  scale_y_continuous(
    name = "人数",
    sec.axis = sec_axis(
      trans = ~.,
      name = "查房率 (%)",
      labels = function(x) scales::percent(x, scale = 1)
    )
  ) +
  # 设置填充颜色
  scale_fill_manual(
    values = c(
      within_8h_orders_col = "lightblue",
      "非8小时内开具医嘱人数" = "lightgrey"
    ),
    labels = c(
      within_8h_orders_col = "8小时内开具医嘱",
      "非8小时内开具医嘱人数" = "非8小时内开具医嘱"
    )
  ) +
  # 添加折线图（使用右侧y轴）
  geom_line(
    data = years_data,
    aes(x = !!sym(year_col), y = !!sym(within_8h_round_rate_col) * max(stack_data$人数), group = 1),
    color = "red",
    size = 1.2
  ) +
  # 添加折线图数据点
  geom_point(
    data = years_data,
    aes(x = !!sym(year_col), y = !!sym(within_8h_round_rate_col) * max(stack_data$人数)),
    color = "red",
    size = 3
  ) +
  # 在折线图数据点上添加百分比标签
  geom_text(
    data = years_data,
    aes(
      x = !!sym(year_col), 
      y = !!sym(within_8h_round_rate_col) * max(stack_data$人数),
      label = scales::percent(!!sym(within_8h_round_rate_col), accuracy = 0.01)  # 保留2位小数
    ),
    vjust = -1,
    color = "red"
  ) +
  # 设置主题
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "red")
  ) +
  # 设置标题和坐标轴标签
  labs(
    title = "年度入院患者8小时内医疗行为分析",
    x = "年度"
  )

# 显示图表
print(g)

# 保存图表
ggsave("堆积图折线图.png", plot = g, width = 10, height = 6, dpi = 300)

cat("图表已生成并保存为'堆积图折线图.png'\n")
cat("如果需要修改列名，请调整脚本中year_col、total_patients_col、within_8h_orders_col和within_8h_round_rate_col的定义\n")