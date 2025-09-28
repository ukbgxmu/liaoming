setwd("E:/朱瓦力") #from liaoming's dell
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