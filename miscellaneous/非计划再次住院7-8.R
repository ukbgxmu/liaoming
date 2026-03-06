setwd("C:/Users/Ming/Nutstore/1/data/日常办公/非预期再住院") #from liaoming's dell
setwd("C:/Users/Administrator/Nutstore/2/data/日常办公/非预期再住院") #from Yiwubu
library(readxl)

# 住院患者出院后31天内非预期再住院上次和本次住院科室对比分析
# 原因分析那里只要修改文件名即可再次计算新的结果。

######## 1. 读入数据 #################
data05 <- read_excel("7月住院患者出院后31天内非预期再住院信息表.xls")
data06 <- read_excel("8月住院患者出院后31天内非预期再住院信息表.xls")
# 还需要修改“非计划重返手术室再手术率”的分子

#table(data05$原因分析)
#此次只要修改文件名即可再次计算新的结果:   data05<-data06
nrow(data05) 

sum(grepl("前次住院收治科室未能准确填写病案首页“是否有" ,data05$原因分析) |
      grepl( "病案首页填写错误",data05$原因分析))
data005<-data05[!(grepl("前次住院收治科室未能准确填写病案首页“是否有",data05$原因分析) |
                 grepl( "病案首页填写错误",data05$原因分析) ),]
sum(data005$本次住院科室 == data005$上次住院科室);sum(data005$本次住院科室 == data005$上次住院科室)/nrow(data005)
sum(data005$本次住院科室 != data005$上次住院科室);sum(data005$本次住院科室 != data005$上次住院科室)/nrow(data005)

nrow(data005)

table(data005$上次住院有无手术操作);table(data005$上次住院有无手术操作)/nrow(data005)
table(data005$主要诊断疗效);table(data005$主要诊断疗效)/nrow(data005)


#table(data005$原因分析)%>%sort()



#table(data06$原因分析)
nrow(data06)
sum(grepl("前次住院收治科室未能准确填写病案首页“是否有" ,data06$原因分析) |
      grepl( "病案首页填写错误",data06$原因分析))
data006<-data06[!(grepl("前次住院收治科室未能准确填写病案首页“是否有",data06$原因分析) |
                    grepl( "病案首页填写错误",data06$原因分析) ),]
sum(data006$本次住院科室 == data006$上次住院科室)
sum(data006$本次住院科室 != data006$上次住院科室)
nrow(data006)

table(data006$上次住院有无手术操作)
table(data006$主要诊断疗效)
#table(data006$原因分析)%>%sort()

####### 1.1 7月统计表格 ##################

分母 <- 14912

data05$住院间隔分组 <- cut(
    data05$住院间隔,
    breaks = c(-Inf, 0, 1, 15, 31),
    labels = c(NA, "当天", "2-15天", "16-31天"),
    right = TRUE
)
# 0-31天分组
data05$住院间隔分组_0_31 <- ifelse(data05$住院间隔 >= 0 & data05$住院间隔 <= 31, "0-31天", NA)

# 各组分子
table_group <- table(data05$住院间隔分组, useNA = "no")
num_group <- as.vector(table_group)
prop_group <- round(100 * num_group / 分母, 2)
ratio_group <- paste0(num_group, "/", 分母)

table_0_31 <- sum(!is.na(data05$住院间隔分组_0_31))
prop_0_31 <- round(100 * table_0_31 / 分母, 2)
ratio_0_31 <- paste0(table_0_31, "/", 分母)

result_table <- rbind(
    data.frame(
        分组 = c(names(table_group), "0-31天"),
        分子分母 = c(ratio_group, ratio_0_31),
        百分比 = c(prop_group, prop_0_31)
    ),
    data.frame(
        分组 = "非计划重返手术室再手术率",
        分子分母 = paste0(21, "/", 分母),
        百分比 = round(100 * 21 / 分母, 2)
    )
)

print(result_table)

######### 1.2 7月作图 #####################
table_current <- as.data.frame(table(data05$`本次住院科室`))
colnames(table_current) <- c("科室名称", "本次住院次数")

table_previous <- as.data.frame(table(data05$`上次住院科室`))
colnames(table_previous) <- c("科室名称", "上次住院次数")

result <- merge(table_current, table_previous, by = "科室名称", all = TRUE)
result[is.na(result)] <- 0

library(ggplot2) 

# 排序
result <- result[order(result$本次住院次数, decreasing = TRUE), ]
result$科室名称 <- factor(result$科室名称, levels = result$科室名称)
# 只选取住院次数最多的前20个科室
top20 <- head(result, 20)

# 转为长数据
library(tidyr)
result_long <- pivot_longer(top20, cols = c("本次住院次数", "上次住院次数"),
                            names_to = "住院类型", values_to = "住院次数")
# 画图
ggplot(result_long, aes(x = 科室名称, y = 住院次数, fill = 住院类型)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = c("本次住院次数" = "grey60", "上次住院次数" = "lightblue")) +
    geom_text(aes(label = 住院次数), 
              position = position_dodge(width = 0.9), 
              vjust = -0.3, size = 3) +
    labs(x = "", y = "住院次数", fill = "住院类型") +
  ggtitle("2025年7月住院患者出院后31天内非预期再住院上次和本次住院科室对比分析")+
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))






    ####### 1.3 8月统计表格 ##################

    分母_06 <- 13964  # 请根据实际分母填写

    data06$住院间隔分组 <- cut(
        data06$住院间隔,
        breaks = c(-Inf, 0, 1, 15, 31),
        labels = c(NA, "当天", "2-15天", "16-31天"),
        right = TRUE
    )
    data06$住院间隔分组_0_31 <- ifelse(data06$住院间隔 >= 0 & data06$住院间隔 <= 31, "0-31天", NA)

    table_group_06 <- table(data06$住院间隔分组, useNA = "no")
    num_group_06 <- as.vector(table_group_06)
    prop_group_06 <- round(100 * num_group_06 / 分母_06, 2)
    ratio_group_06 <- paste0(num_group_06, "/", 分母_06)

    table_0_31_06 <- sum(!is.na(data06$住院间隔分组_0_31))
    prop_0_31_06 <- round(100 * table_0_31_06 / 分母_06, 2)
    ratio_0_31_06 <- paste0(table_0_31_06, "/", 分母_06)

    result_table <- rbind(
      data.frame(
        分组 = c(names(table_group_06), "0-31天"),
        分子分母 = c(ratio_group_06, ratio_0_31_06),
        百分比 = c(prop_group_06, prop_0_31_06)
      ),
      data.frame(
        分组 = "非计划重返手术室再手术率",
        分子分母 = paste0(12, "/", 分母_06),
        百分比 = round(100 * 12 / 分母_06, 2)
      )
    )
    
    print(result_table)

    ######### 1.4 8月作图 #####################
    table_current_06 <- as.data.frame(table(data06$`本次住院科室`))
    colnames(table_current_06) <- c("科室名称", "本次住院次数")

    table_previous_06 <- as.data.frame(table(data06$`上次住院科室`))
    colnames(table_previous_06) <- c("科室名称", "上次住院次数")

    result_06 <- merge(table_current_06, table_previous_06, by = "科室名称", all = TRUE)
    result_06[is.na(result_06)] <- 0

    result_06 <- result_06[order(result_06$本次住院次数, decreasing = TRUE), ]
    result_06$科室名称 <- factor(result_06$科室名称, levels = result_06$科室名称)
    top20_06 <- head(result_06, 20)

    library(tidyr)
    result_long_06 <- pivot_longer(top20_06, cols = c("本次住院次数", "上次住院次数"),
                                   names_to = "住院类型", values_to = "住院次数")
    ggplot(result_long_06, aes(x = 科室名称, y = 住院次数, fill = 住院类型)) +
        geom_bar(stat = "identity", position = "dodge") +
        scale_fill_manual(values = c("本次住院次数" = "grey60", "上次住院次数" = "lightblue")) +
        geom_text(aes(label = 住院次数), 
                  position = position_dodge(width = 0.9), 
                  vjust = -0.3, size = 3) +
        labs(x = "", y = "住院次数", fill = "住院类型") +
      ggtitle("2025年8月住院患者出院后31天内非预期再住院上次和本次住院科室对比分析")+
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))