 # 加载所需的包
   # survival 包用于生存分析相关功能
library(survival)
 # cmprsk 包包含 cuminc 函数用于竞争风险分析
library(tidycmprsk)
 # dplyr 包用于数据处理操作
library(dplyr)
# 读取数据集，这里假设文件路径正确，你可根据实际情况修改
#data <- read.csv("D:/莹珺/肥胖/肥胖与RPL/Obese_SA.csv")
data <- read.csv("E:/nas/ukbA/data/liaoming/Obese_SA.csv")

   # 步骤1：数据清洗
   # 去除招募时 BMI 为空值的数据以及第 1 次随访中流产次数和 BMI 为空值的数据
   cleaned_data <- data %>%
       filter(!is.na(participant.p21001_i0),
                       !is.na(participant.p3839_i1),
                       !is.na(participant.p21001_i1))
   
   # 去除招募时 BMI 为空值的数据以及第 1 次随访中流产次数和 BMI 为负值的数据
   cleaned_data <- cleaned_data %>%
     filter(participant.p21001_i0>=0,
            participant.p3839_i1>=0,
            participant.p21001_i1>=0)
   
     # 步骤2：进一步筛选数据
     # 去除第 1 次随访流产次数小于招募时流产次数的人员信息
     cleaned_data <- cleaned_data %>%
        filter(participant.p3839_i1 >= participant.p3839_i0)
     
       # 步骤3：计算第 1 次随访时长
       # 将招募时间和第 1 次随访时间转换为日期格式
       cleaned_data$participant.p53_i0 <- as.Date(cleaned_data$participant.p53_i0)
       cleaned_data$participant.p53_i1 <- as.Date(cleaned_data$participant.p53_i1)
       
         # 计算随访时长（以天为单位）并添加为新列
         cleaned_data$follow_up_duration <- as.numeric(cleaned_data$participant.p53_i1 - cleaned_data$participant.p53_i0)
         
           # 步骤4：创建体重增加和流产增加的指标变量
           # 体重增加指标：如果第 1 次随访 BMI 大于招募时 BMI，则为 1，否则为 0
           cleaned_data$bmi_increase <- ifelse(cleaned_data$participant.p21001_i1>cleaned_data$participant.p21001_i0, 1, 0)
           
             # 流产增加指标：如果第 1 次随访流产次数大于招募时流产次数，则为 1，否则为 0
             cleaned_data$sa_increase <- ifelse(cleaned_data$participant.p3839_i1>cleaned_data$participant.p3839_i0, 1, 0)
             
               # 步骤5：使用 cuminc 函数进行竞争风险分析
               # ftime 是随访时间，fstatus 是事件状态（这里是流产是否增加），group 是分组变量（这里是体重是否增加）
              # fit <- cuminc(ftime = cleaned_data$follow_up_duration,
               #                              fstatus = cleaned_data$sa_increase,
                #                           group = cleaned_data$bmi_increase)
               
               table(cleaned_data$bmi_increase)
               cleaned_data$bmi_increase<-as.factor(cleaned_data$bmi_increase)
               
               cleaned_data$sa_increase<-as.factor(cleaned_data$sa_increase)
               table(cleaned_data$bmi_increase,cleaned_data$sa_increase)
               fisher.test(cleaned_data$bmi_increase,cleaned_data$sa_increase)
               
               cleaned_data$follow_up_year<-cleaned_data$follow_up_duration/365
               
               cuminc(Surv(follow_up_year, sa_increase) ~ bmi_increase, cleaned_data)
               
               library(survminer)
               library(ggsurvfit)
               cuminc(Surv(follow_up_year, sa_increase) ~ bmi_increase, cleaned_data) %>%
                 ggcuminc(outcome = "1") +  # 指定目标事件类型
                 scale_ggsurvfit() +        # 优化坐标轴和标签
                 labs(title = "BMI增加对流产次数增加的累积发病率影响")  
               
               ### 作图：定义超过6年为censored数据
               new<-cleaned_data %>% mutate(new=ifelse(follow_up_year>6,NA,sa_increase))
               new$new<-as.factor(new$new)
               table(new$bmi_increase,new$new)
               levels(new$new)<-c(0,1)
               cuminc(Surv(follow_up_year, new) ~ bmi_increase, new)   
               cuminc(Surv(follow_up_year, new) ~ bmi_increase, new[!is.na(new$new),]) %>%
                 ggcuminc(outcome = "1") +  # 指定目标事件类型
                 scale_ggsurvfit() +        # 优化坐标轴和标签
                 labs(title = "BMI增加对流产次数增加的累积发病率影响") 
               