# from liaoming's Dell
setwd("D:/2-postDR/mo/osteocalcinGWAS20241024/data/Gudjonsson")

library(yaml)
library(readr)
library(dplyr)

tsv_gz_file<-"GCST90089192/harmonised/35078996-GCST90089192-EFO_0010232.h.tsv.gz" #Build37
#35078996-GCST90089192-EFO_0010232-Build37.f.tsv.gz
yaml_file<-"GCST90089192/harmonised/35078996-GCST90089192-EFO_0010232.h.tsv.gz-meta.yaml"

tsv_gz_file<-"GCST90086529/harmonised/35078996-GCST90086529-EFO_0010232.h.tsv.gz" #Build37
#35078996-GCST90086529-EFO_0010232-Build37.f.tsv.gz
yaml_file<-"GCST90086529/harmonised/35078996-GCST90086529-EFO_0010232.h.tsv.gz-meta.yaml" #selected

a<-read_tsv(tsv_gz_file)
a<-as.data.frame(a)
# 读取YAML元数据
yaml_data <- read_yaml(yaml_file)
# 查看数据结构
str(a)

#https://genome.ucsc.edu/cgi-bin/hgSearch?search=BGLAP&db=hg19
#Search Results on hg19 (Human Feb. 2009 (GRCh37/hg19))
#HUGO Gene Nomenclature:
#  BGLAP - chr1:156211975-156213108

#lead snp
a1<-subset(a,hm_chrom=="1" & hm_pos >= 156211975  & hm_pos <= 156213108 )
a2<-subset(a,hm_chrom=="1" & hm_pos >= 156211975  & hm_pos <= 156213108 ) 
a1[,c( "hm_rsid" ,"hm_beta" , "p_value"   )]
a2[,c( "hm_rsid" ,"hm_beta" , "p_value"   )]


#cis-acting pQTLs located in the vicinity of the encoding gene 
#(defined as ≤500 kb from the leading pQTL of the test protein in this study) 
a1<-subset(a,hm_chrom=="1" & hm_pos >= 156211975 - 500000 & hm_pos <= 156213108 + 500000)
a2<-subset(a,hm_chrom=="1" & hm_pos >= 156211975 - 500000 & hm_pos <= 156213108 + 500000) #selected

#compare
mean(abs(a1$hm_beta));mean(abs(a2$hm_beta))
range(a1$p_value);range(a2$p_value)
sum(a1$p_value<0.05);sum(a2$p_value<0.05)
sum(a1$p_value<0.01);sum(a2$p_value<0.01)

a1[a1$p_value<0.01,c( "hm_rsid" ,"hm_beta" , "p_value"   )]
a2[a2$p_value<0.01,c( "hm_rsid" ,"hm_beta" , "p_value"   )]

par(mfrow=c(1,2))
plot(a1$hm_pos, -log10(a1$p_value))
plot(a2$hm_pos, -log10(a2$p_value))

########## ploting1 ########## 
library(ggplot2)
library(ggpubr)

# 假设combined数据已准备好
combined <- rbind(
  data.frame(hm_pos=a1$hm_pos, p_value=a1$p_value, group="a1"),
  data.frame(hm_pos=a2$hm_pos, p_value=a2$p_value, group="a2")
)

# 计算效应量（Pearson相关系数）
cor_test <- cor.test(combined$hm_pos, -log10(combined$p_value))
effect_size <- cor_test$estimate
p_value <- cor_test$p.value

# 绘制图形
ggplot(combined, aes(hm_pos, -log10(p_value), color=group)) + 
  geom_point(alpha=0.6) +
  geom_smooth(method="lm", se=TRUE, aes(fill=group)) +  # 分组线性回归
  stat_cor(aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")), 
           label.x.npc = "left", label.y.npc = "top") +  # 添加R²和p值
  labs(title = "基因组位置与显著性水平关系",
       subtitle = paste("总体效应量 r =", round(effect_size, 3), 
                        ifelse(p_value < 0.001, "p < 0.001", 
                               paste("p =", round(p_value, 3)))),
       x = "基因组位置", 
       y = "-log10(p-value)") +
  theme_minimal() +
  theme(legend.position = "top")

########## ploting2 ########## 
library(ggplot2)
library(patchwork)

# 创建第一个图形（a1数据集）
p1 <- ggplot(a1, aes(hm_pos, -log10(p_value))) +
  geom_point(color="#1f77b4", alpha=0.7) +
  geom_smooth(method="lm", color="#1f77b4", fill="#1f77b4", alpha=0.2) +
  stat_cor(label.x.npc = 0.05, label.y.npc = 0.95) +
  labs(title = "数据集A1", 
       x = "基因组位置", 
       y = "-log10(p-value)") +
  theme_minimal()

# 创建第二个图形（a2数据集）
p2 <- ggplot(a2, aes(hm_pos, -log10(p_value))) +
  geom_point(color="#ff7f0e", alpha=0.7) +
  geom_smooth(method="lm", color="#ff7f0e", fill="#ff7f0e", alpha=0.2) +
  stat_cor(label.x.npc = 0.05, label.y.npc = 0.95) +
  labs(title = "数据集A2",
       x = "基因组位置", 
       y = "-log10(p-value)") +
  theme_minimal()

# 使用patchwork合并图形
combined_plot <- p1 + p2 + 
  plot_annotation(title = "基因组位置与显著性水平关系对比",
                  theme = theme(plot.title = element_text(hjust = 0.5, size=14)))

print(combined_plot)


