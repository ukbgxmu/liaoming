setwd("C:/Users/Administrator/Nutstore/2/data/日常办公/质控数据") #from Yiwubu

library(readxl)

##2024##
data <- read_excel("2024上-指标11完成率汇总.xlsx")

library(ggplot2)
library(dplyr)
library(lubridate)
# 转换出院日期为Date类型，并提取月份
data <- data %>%
    mutate(
        出院日期 = as.Date(出院日期),
        月份 = format(出院日期, "%Y-%m")
    )

# 获取每个月的第一个和最后一个日期用于背景色
month_ranges <- data %>%
    group_by(月份) %>%
    summarise(
        start = min(出院日期),
        end = max(出院日期)
    ) %>%
    arrange(start)

# 用每个月的中间日期作为标记日期
month_marks <- month_ranges %>%
    mutate(
        标记日期 = start + as.integer((end - start) / 2)
    ) %>%
    select(月份, 标记日期)

ggplot(data, aes(x = 出院日期, y = 完成率)) +
    # 添加每月背景色
    geom_rect(
        data = month_ranges,
        aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf, fill = 月份),
        inherit.aes = FALSE,
        alpha = 0.2,
        show.legend = FALSE
    ) +
    geom_line(aes(group = 1), color = "black") +
    geom_point(aes(color = 月份), size = 2, show.legend = FALSE) +
    scale_x_date(
        breaks = month_marks$标记日期,
        labels = month_marks$月份
    ) +
    scale_fill_manual(values = rep(c("#FFEBEE", "#E3F2FD", "#E8F5E9", "#FFFDE7", "#F3E5F5"), length.out = nrow(month_ranges))) +
    theme_minimal() +
    theme(
        strip.text = element_text(face = "bold")
    ) +
    labs(title = "2024年上半年完成率", x = "出院日期（按月标识）", y = "完成率")


##2025##
data <- read_excel("2025上-指标11完成率汇总.xlsx")

# 转换出院日期为Date类型，并提取月份
data <- data %>%
  mutate(
    出院日期 = as.Date(出院日期),
    月份 = format(出院日期, "%Y-%m")
  )

# 获取每个月的第一个和最后一个日期用于背景色
month_ranges <- data %>%
  group_by(月份) %>%
  summarise(
    start = min(出院日期),
    end = max(出院日期)
  ) %>%
  arrange(start)

# 用每个月的中间日期作为标记日期
month_marks <- month_ranges %>%
  mutate(
    标记日期 = start + as.integer((end - start) / 2)
  ) %>%
  select(月份, 标记日期)

ggplot(data, aes(x = 出院日期, y = 完成率)) +
  # 添加每月背景色
  geom_rect(
    data = month_ranges,
    aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf, fill = 月份),
    inherit.aes = FALSE,
    alpha = 0.2,
    show.legend = FALSE
  ) +
  geom_line(aes(group = 1), color = "black") +
  geom_point(aes(color = 月份), size = 2, show.legend = FALSE) +
  scale_x_date(
    breaks = month_marks$标记日期,
    labels = month_marks$月份
  ) +
  scale_fill_manual(values = rep(c("#FFEBEE", "#E3F2FD", "#E8F5E9", "#FFFDE7", "#F3E5F5"), length.out = nrow(month_ranges))) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold")
  ) +
  labs(title = "2025年上半年完成率", x = "出院日期（按月标识）", y = "完成率")

