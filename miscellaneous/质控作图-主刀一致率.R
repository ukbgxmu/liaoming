setwd("C:/Users/Administrator/Nutstore/2/data/日常办公/质控数据") #from Yiwubu

library(readxl)
data <- read_excel("2025上-指标18，手术计划一致率.xlsx", col_names = TRUE)

library(ggplot2)
library(dplyr)
library(lubridate)

##data第1列是“手术日期”（格式是2025-01-01到2025-06-30），第3列是“主刀一致率”，按手术日期把主刀一致率做点线图展示，
##并把点用线连起来；同时把手术日期分成6个月份，用间断的颜色作为背景，并附上具体月份图示。
##注意纵坐标尽量展示数据变动，不用从0开始


# 将手术日期转换为月份
data <- data %>%
    mutate(月份 = format(as.Date(手术日期), "%Y-%m"))

# 按月份分组，计算每月主刀一致率均值
monthly_data <- data %>%
    group_by(月份) %>%
    summarise(主刀一致率 = mean(主刀一致率, na.rm = TRUE))

# 设置每个月的背景颜色
bg_colors <- c("lightblue", "lightgreen", "lightpink", "lavender", "mistyrose", "honeydew")

# 绘图
ggplot(monthly_data, aes(x = 月份, y = 主刀一致率, group = 1)) +
    geom_line(color = "steelblue", size = 1) +
    geom_point(color = "darkorange", size = 3) +
    # 添加每个月的背景色
    geom_rect(data = monthly_data, aes(xmin = as.numeric(factor(月份)) - 0.5,
                                       xmax = as.numeric(factor(月份)) + 0.5,
                                       ymin = -Inf, ymax = Inf,
                                       fill = 月份), alpha = 0.1, inherit.aes = FALSE) +
    geom_text(aes(label = scales::percent(主刀一致率, accuracy = 0.1)), vjust = -1, size = 5) +
    scale_fill_manual(values = bg_colors, guide = "none") +
    scale_x_discrete(labels = monthly_data$月份) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                       expand = expansion(mult = c(0.05, 0.05)),
                       limits = c(min(monthly_data$主刀一致率) * 0.98, max(monthly_data$主刀一致率) * 1.02)) +
    labs(title = "2025年上半年主刀一致率按月份点线图", x = "月份", y = "主刀一致率 (%)") +
    theme_minimal() +
    theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()
    )


data2 <- read_excel("2025上-指标18，一致率明细.xlsx", col_names = TRUE)
colnames(data2)[4]<-"科室名称"
# 去除科室名称为NA的行
data2 <- data2 %>% filter(!is.na(科室名称))

# 添加月份列
data2 <- data2 %>% mutate(月份 = format(as.Date(手术日期), "%Y-%m"))

# 按月份统计不同科室的个数
dept_count <- data2 %>%
    group_by(月份) %>%
    summarise(科室数 = n_distinct(科室名称))

# 绘制直方图1
ggplot(dept_count, aes(x = 月份, y = 科室数, group = 1)) +
    # 每个月份不同背景色
    geom_rect(data = dept_count, aes(xmin = as.numeric(factor(月份)) - 0.5,
                                     xmax = as.numeric(factor(月份)) + 0.5,
                                     ymin = -Inf, ymax = Inf,
                                     fill = 月份), alpha = 0.1, inherit.aes = FALSE) +
    geom_bar(stat = "identity", color = "steelblue", fill = "skyblue", width = 0.6) +
    # 连线
    geom_line(color = "orange", size = 1) +
    geom_point(color = "darkorange", size = 3) +
    geom_text(aes(label = 科室数), vjust = -0.5, size = 5) +
    scale_fill_manual(values = bg_colors, guide = "none") +
    scale_x_discrete(labels = dept_count$月份) +
    scale_y_continuous(
        limits = c(0, 45),
        breaks = c(0, 10, 20, 30, 40, 45),
        labels = function(x) ifelse(x == 0 | x == 45, x, paste0(x, "\n——"))
    ) +
    labs(title = "2025年上半年各月科室主刀不一致的科室数统计", x = "月份", y = "科室数") +
    theme_minimal() +
    theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()
    )

# 绘制直方图2
# 按月份和科室统计每月各科室的手术数
dept_month_count <- data2 %>%
    group_by(月份, 科室名称) %>%
    summarise(手术数 = n(), .groups = "drop")

# 只保留每个月手术数最多的前5个科室
dept_month_top5 <- dept_month_count %>%
    group_by(月份) %>%
    arrange(desc(手术数)) %>%
    slice_head(n = 5) %>%
    mutate(科室名称 = factor(科室名称, levels = unique(科室名称))) %>%
    ungroup()

# 绘制每个月独立的直方图（facets），背景分色
ggplot(dept_month_top5, aes(x = 科室名称, y = 手术数, fill = 月份)) +
    geom_rect(data = dept_month_top5 %>% distinct(月份),
              aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, fill = 月份),
              alpha = 0.12, inherit.aes = FALSE) +
    geom_bar(stat = "identity", color = "steelblue", width = 0.7) +
    geom_text(aes(label = 手术数), vjust = -0.5, size = 4) +
    scale_fill_manual(values = bg_colors, guide = "none") +
    facet_wrap(~月份, scales = "free_x") +
    scale_y_continuous(limits = c(0, 90)) +
    labs(title = "2025年上半年各月科室主刀不一致的手术数统计（Top 5）", x = "科室名称", y = "手术数") +
    theme_minimal(base_size = 14) +
    theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 6), # 科室名称字号更小
        strip.background = element_rect(fill = "grey90", color = NA),
        strip.text = element_text(face = "bold")
    )
