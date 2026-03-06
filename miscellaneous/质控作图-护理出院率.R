setwd("C:/Users/Administrator/Nutstore/2/data/日常办公/质控数据") #from Yiwubu

library(readxl)
data2024 <- read_excel("./2024上-指标9汇总.xlsx", col_names = TRUE)
data2025 <- read_excel("./2025上-指标9汇总.xlsx", col_names = TRUE)

library(ggplot2)
library(dplyr)
library(lubridate)

#data2024第一列的列名是“出院日期”（格式2024-01-01到2024-06-30），最后一列的列名是“一级特级护理出院率”，用这2列作点线图，横坐标只用按6个月份标出即可，每个月份的背景用不同颜色间隔。

##2024##
data2024$出院日期 <- as.Date(data2024$出院日期)

# 提取月份标签
month_labels <- format(seq(as.Date("2024-01-01"), as.Date("2024-06-01"), by = "month"), "%Y-%m")

# 创建月份分组
data2024$month <- format(data2024$出院日期, "%Y-%m")

# 生成每个月的背景区间
month_ranges <- data.frame(
    xmin = as.Date(paste0(month_labels, "-01")),
    xmax = as.Date(paste0(month_labels, "-01")) + months(1) - days(1),
    month = month_labels
)

# 选择背景色
bg_colors <- rep(c("#F0F8FF", "#FFE4E1"), length.out = nrow(month_ranges))

ggplot(data2024, aes(x = 出院日期, y = `一级特级护理出院率`)) +
    # 添加每个月的背景色
    geom_rect(data = month_ranges, aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = month), 
                        inherit.aes = FALSE, alpha = 0.3, show.legend = FALSE) +
    scale_fill_manual(values = bg_colors) +
    geom_line(color = "blue") +
    geom_point(color = "darkblue") +
    scale_x_date(breaks = as.Date(paste0(month_labels, "-15")), labels = month_labels) +
    labs(x = "月份", y = "一级特级护理出院率", title = "2024年上半年一级特级护理出院率") +
    theme_minimal()

    # 按月份汇总一级特级护理出院率的均值
    monthly_summary <- data2024 %>%
        group_by(month) %>%
        summarise(avg_rate = mean(`一级特级护理出院率`, na.rm = TRUE))
    
        # 绘制直方图并添加数值标签和连线
        ggplot(monthly_summary, aes(x = month, y = avg_rate, fill = month, group = 1)) +
            geom_col(show.legend = FALSE, width = 0.6) +
            geom_text(aes(label = scales::percent(avg_rate, accuracy = 0.1)), vjust = -0.5, size = 4) +
            geom_line(color = "blue", size = 1) +
            geom_point(color = "darkblue", size = 2) +
            scale_fill_manual(values = bg_colors, guide = "none") +
            scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 0.05)) +
            labs(x = "月份", y = "一级特级护理出院率均值",size=4, title = "2024年上半年各月一级特级护理出院率") +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 45, hjust = 1))

##2025##
data2025$出院日期 <- as.Date(data2025$出院日期)
data2025$month <- format(data2025$出院日期, "%Y-%m")

# 重新生成2025年的月份标签和背景区间
month_labels_2025 <- format(seq(as.Date("2025-01-01"), as.Date("2025-06-01"), by = "month"), "%Y-%m")
month_ranges_2025 <- data.frame(
    xmin = as.Date(paste0(month_labels_2025, "-01")),
    xmax = as.Date(paste0(month_labels_2025, "-01")) + months(1) - days(1),
    month = month_labels_2025
)
bg_colors_2025 <- rep(c("#F0F8FF", "#FFE4E1"), length.out = nrow(month_ranges_2025))

ggplot(data2025, aes(x = 出院日期, y = `一级特级护理出院率`)) +
    geom_rect(data = month_ranges_2025, aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = month), 
              inherit.aes = FALSE, alpha = 0.3, show.legend = FALSE) +
    scale_fill_manual(values = bg_colors_2025) +
    geom_line(color = "red") +
    geom_point(color = "darkred") +
    scale_x_date(breaks = as.Date(paste0(month_labels_2025, "-15")), labels = month_labels_2025, limits = c(min(month_ranges_2025$xmin), max(month_ranges_2025$xmax))) +
    labs(x = "月份", y = "一级特级护理出院率", title = "2025年上半年一级特级护理出院率") +
    theme_minimal()

monthly_summary_2025 <- data2025 %>%
    group_by(month) %>%
    summarise(avg_rate = mean(`一级特级护理出院率`, na.rm = TRUE))

    ggplot(monthly_summary_2025, aes(x = month, y = avg_rate, fill = month, group = 1)) +
        geom_col(show.legend = FALSE, width = 0.6) +
        geom_text(aes(label = scales::percent(avg_rate, accuracy = 0.1)), vjust = -0.5, size = 4) +
        geom_line(color = "red", size = 1) +
        geom_point(color = "darkred", size = 2) +
        scale_fill_manual(values = bg_colors_2025, guide = "none") +
        scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 0.05)) +
        labs(x = "月份", y = "一级特级护理出院率均值",size=4, title = "2025年上半年各月一级特级护理出院率") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
