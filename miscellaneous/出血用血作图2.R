setwd("E:/朱瓦力") #from Yiwubu
library(readxl) #台均用血量

#近2年住院手术台均用血量

######## 1. 读入数据 #################
# 确保加载必要的包
library(dplyr)
library(ggplot2)
library(tidyr)
library(gridExtra)  
data1 <- read_excel("./术中出血量监测明细2024上.xlsx")
data2 <- read_excel("./术中出血量监测明细2024下.xlsx")
colnames(data1)
data1<-data1[,c("住院科室","手术等级","出血量","RBC")]
data1$手术等级=as.numeric(data1$手术等级)
data1$出血量=as.numeric(data1$出血量)
data1$RBC=as.numeric(data1$RBC)
data2<-data2[,c("住院科室","手术等级","出血量","RBC")]
data2$手术等级=as.numeric(data2$手术等级)
data2$出血量=as.numeric(data2$出血量)
data2$RBC=as.numeric(data2$RBC)

# 合并数据并添加时间标识
data1$时间 <- "2024上半年"
data2$时间 <- "2024下半年"
combined_data <- rbind(data1, data2)

# 按手术等级和时间分组，计算台均用血量
avg_blood_usage <- combined_data %>%
  group_by(手术等级, 时间) %>%
  summarise(台均用血量 = mean(RBC, na.rm = TRUE)) %>%
  ungroup()

# 确保手术等级为因子类型
avg_blood_usage$手术等级 <- as.factor(avg_blood_usage$手术等级)

# 加载必要的包（虽然前面已加载，但为代码完整性保留）
library(ggplot2)

# 绘制直方图展示2024上半年和下半年的台均用血量
plot2024<- ggplot(avg_blood_usage, aes(x = 手术等级, y = 台均用血量, fill = 时间)) +
  geom_col(position = "dodge") +ylim(0,0.5)+
  scale_fill_manual(values = c("2024上半年" = "lightblue", "2024下半年" = "lightcoral")) +
  geom_text(aes(label = round(台均用血量, 2)), position = position_dodge(width = 0.9), vjust = -0.5) +
  labs(
    title = "2024上半年和下半年按手术等级的台均用血量",
    x = "手术等级",
    y = "台均用血量",
    fill = "时间"
  ) +
  theme_minimal()
print(plot2024)
#################################
data <- read_excel("术中出血量监测明细（1-9）.xls")
# 选择与data1和data2相同的列
data <- data[,c("住院科室","手术等级","出血量","RBC")]
data$手术等级=as.numeric(data$手术等级)
data$出血量=as.numeric(data$出血量)
data$RBC=as.numeric(data$RBC)

# 添加时间标识（1-8月）
data$时间 <- "2025年1-8月"

# 创建9-12月的数据框架（NA数据）
# 提取唯一的手术等级
unique_levels <- unique(data$手术等级)
data_10_12 <- data.frame(
  住院科室 = NA,
  手术等级 = unique_levels,
  出血量 = NA,
  RBC = NA,
  时间 = "2025年9-12月"
)

# 合并数据
combined_2025_data <- rbind(data, data_10_12)

# 按手术等级和时间分组计算台均用血量
avg_blood_by_period <- combined_2025_data %>%
  group_by(手术等级, 时间) %>%
  summarise(台均用血量 = mean(RBC, na.rm = TRUE))

# 确保手术等级为因子类型
avg_blood_by_period$手术等级 <- as.factor(avg_blood_by_period$手术等级)

# 绘制2025年的数据，分1-8月和9-12月
hist_plot <- ggplot(avg_blood_by_period, aes(x = 手术等级, y = 台均用血量, fill = 时间)) +
  geom_col(position = "dodge") +ylim(0,2.5)+
  scale_fill_manual(values = c("2025年1-8月" = "lightblue", "2025年9-12月" = "lightgrey")) +
  geom_text(aes(label = ifelse(is.na(台均用血量), "NA", round(台均用血量, 2))), 
            position = position_dodge(width = 0.9), vjust = -0.5) +
  labs(
    title = "2025年1-8月按手术等级的台均用血量",
    x = "手术等级",
    y = "台均用血量",
    fill = "时间"
  ) +
  theme_minimal()

# 使用grid.arrange将两个图上下排列在同一个图中
grid.arrange(plot2024, hist_plot, nrow = 2, heights = c(1, 1))

# 可选：保存合并后的图表
ggsave("合并图表.png", width = 12, height = 10, dpi = 300)
