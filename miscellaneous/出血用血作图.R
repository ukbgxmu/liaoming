setwd("E:/朱瓦力") #from Yiwubu
library(readxl)

#近2年住院手术台均用血量

######## 1. 读入数据 #################
data <- read_excel("术中出血量监测明细1_9.xlsx")
View(subset(data,住院科室=="儿科三病区"))
# 选择与data1和data2相同的列
data <- data[,c("住院科室","手术等级","出血量","RBC")]
# 确保加载必要的包
library(dplyr)
library(ggplot2)
library(tidyr)  

# 1-2 #
# 移除data中包含NA的行
data <- na.omit(data)
data$手术等级=as.numeric(data$手术等级)
data$出血量=as.numeric(data$出血量)
data$RBC=as.numeric(data$RBC)
# 仅筛选手术等级为1和2的数据
filtered_data <- data %>% filter(手术等级 %in% 1:2)
# 按住院科室和手术等级分组计算平均用血量，也就每个科室1级手术平均用血量多少，2级平均用血量多少，如果没有这个级别手术，那用这级的平均用血量就是0
grouped_data <- filtered_data %>%
  group_by(住院科室, 手术等级) %>%
  summarise(平均用血量 = mean(RBC, na.rm = TRUE), .groups = "drop") %>%
  complete(住院科室, 手术等级 = 1:2, fill = list(平均用血量 = 0))
# 检查并移除住院科室为NA的数据，避免绘图时出现NA情况
grouped_data_no_na <- grouped_data[!is.na(grouped_data$住院科室), ]

# 将手术等级转换为因子，便于指定颜色
grouped_data_no_na$手术等级 <- factor(grouped_data_no_na$手术等级, levels = c(1, 2))

# 筛选出手术等级为1的数据（注释与代码保持一致）
level_1_data <- grouped_data_no_na %>%
  filter(手术等级 == 1)

# 按1级手术平均用血量排序，确保只取前10个科室
top_10_depts <- level_1_data %>%
  arrange(desc(平均用血量)) %>%
  head(10) %>%  # 使用head(10)确保只取前10个科室，即使有平局
  pull(住院科室)

# 筛选出前10科室的数据
top_10_data <- grouped_data_no_na %>%
  filter(住院科室 %in% top_10_depts)

# 将住院科室转换为因子，并按1级手术平均用血量从高到低排序
level_1_for_order <- level_1_data %>% 
  filter(住院科室 %in% top_10_depts) %>%
  arrange(desc(平均用血量))
top_10_data$住院科室 <- factor(top_10_data$住院科室, levels = level_1_for_order$住院科室)

plot <- ggplot(top_10_data, aes(x = 住院科室, y = 平均用血量, fill = 手术等级)) +
  geom_col(position = "dodge") +
  # 在柱子上添加用血具体数字，保留1位小数
  geom_text(aes(label = sprintf("%.1f", 平均用血量)), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3) +ylim(0,8)+
  scale_fill_manual(values = c("1" = "lightblue", "2" = "lightcoral")) +
  labs(title = "手术等级1和2级手术平均用血量前10的住院科室(2025年1-8月)",
       x = "住院科室",
       y = "平均用血量",
       fill = "手术等级") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 6))
# 显示图表
print(plot)


# 3-4 #
# 仅筛选手术等级为3和4的数据
filtered_data_34 <- data %>% filter(手术等级 %in% 3:4)

# 按住院科室和手术等级分组计算平均用血量，也就每个科室3级手术平均用血量多少，4级平均用血量多少，如果没有这个级别手术，那用这级的平均用血量就是0
grouped_data_34 <- filtered_data_34 %>%
  group_by(住院科室, 手术等级) %>%
  summarise(平均用血量 = mean(RBC, na.rm = TRUE), .groups = "drop") %>%
  complete(住院科室, 手术等级 = 3:4, fill = list(平均用血量 = 0))

# 检查并移除住院科室为NA的数据，避免绘图时出现NA情况
grouped_data_34_no_na <- grouped_data_34[!is.na(grouped_data_34$住院科室), ]

# 将手术等级转换为因子，便于指定颜色
grouped_data_34_no_na$手术等级 <- factor(grouped_data_34_no_na$手术等级, levels = c(3, 4))

# 筛选出手术等级为3的数据（注释与代码保持一致）
level_3_data <- grouped_data_34_no_na %>%
  filter(手术等级 == 3)

# 按3级手术平均用血量排序，确保只取前10个科室
top_10_depts_34 <- level_3_data %>%
  arrange(desc(平均用血量)) %>%
  head(10) %>%  # 使用head(10)确保只取前10个科室，即使有平局
  pull(住院科室)

# 筛选出前10科室的数据
top_10_data_34 <- grouped_data_34_no_na %>%
  filter(住院科室 %in% top_10_depts_34)

# 将住院科室转换为因子，并按3级手术平均用血量从高到低排序
level_3_for_order <- level_3_data %>% 
  filter(住院科室 %in% top_10_depts_34) %>%
  arrange(desc(平均用血量))
top_10_data_34$住院科室 <- factor(top_10_data_34$住院科室, levels = level_3_for_order$住院科室)

plot_34 <- ggplot(top_10_data_34, aes(x = 住院科室, y = 平均用血量, fill = 手术等级)) +
  geom_col(position = "dodge") +
  # 在柱子上添加用血具体数字，保留1位小数
  geom_text(aes(label = sprintf("%.1f", 平均用血量)), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3) +  ylim(0, 18)+
  scale_fill_manual(values = c("3" = "lightblue", "4" = "lightcoral")) +
  labs(title = "手术等级3和4级手术平均用血量前10的住院科室(2025年1-8月)",
       x = "住院科室",
       y = "平均用血量",
       fill = "手术等级") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 6))

# 显示图表
print(plot_34)


grid.arrange(plot, plot_34, nrow = 2, heights = c(1, 1))
