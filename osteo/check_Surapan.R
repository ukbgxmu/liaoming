# from liaoming's Dell
setwd("D:/2-postDR/mo/osteocalcinGWAS20241024/data/Surapaneni-AfricaAmerican")

library(yaml)
library(readr)
library(dplyr)

tsv_gz_file<-"GCST90233051/harmonised/GCST90233051.h.tsv.gz" 
tbi_file<-"GCST90233051/harmonised/GCST90233051.h.tsv.gz.tbi"
yaml_file<-"GCST90233051/harmonised/GCST90233051.h.tsv.gz-meta.yaml"  #selected

tsv_gz_file<-"GCST90238078/harmonised/GCST90238078.h.tsv.gz" 
tbi_file<- "GCST90238078/harmonised/GCST90238078.h.tsv.gz.tbi"
yaml_file<-"GCST90238078/harmonised/GCST90238078.h.tsv.gz-meta.yaml"


#a<-read_tsv(tsv_gz_file)
#a<-as.data.frame(a)
# 读取YAML元数据
yaml_data <- read_yaml(yaml_file)     #check GRCh38 build
# 查看数据结构
#str(a)

#https://genome.ucsc.edu/cgi-bin/hgSearch?search=BGLAP&db=hg38
#Search Results on hg38 (Human Dec. 2013 (GRCh38/hg38))
#MANE Select Plus Clinical: Representative transcript from RefSeq & GENCODE:
#  BGLAP - chr1:156242184-156243317

library(Rsamtools)
#lead snp
target_range <- "1:156242184-156243317"  # 替换成你感兴趣的染色体区域
#cis-acting pQTLs
156242184 - 500000
156243317 + 500000
target_range <- "1:155742184-156743317"  # 替换成你感兴趣的染色体区域
# 使用Tabix提取数据
tabix_file <- TabixFile(tsv_gz_file,
                        index = tbi_file)
result <- scanTabix(tabix_file, param = GRanges(target_range)) #
# 读取文件前几行检查列名
file_lines <- readLines(tsv_gz_file, n = 5)
#print(file_lines)
# 使用您从readLines获取的列名
col_names <- unlist(strsplit(sub("^#", "", file_lines[1]), "\t"))
# 读取数据并修改列名
data <- read.delim(textConnection(result[[1]]), header = FALSE)
colnames(data) <- col_names
head(data)
# 读取数据并应用列名，这一步性能优化：对于大型文件，考虑使用data.table包：
library(data.table)
data <- fread(text = result[[1]], header = FALSE)
setnames(data, col_names)

a1<-data
a2<-data

#View
a1[,c( "rsid" ,"beta" , "p_value"   )] %>% head()
a2[,c( "rsid" ,"beta" , "p_value"   )] %>% head()

#compare
mean(abs(a1$beta));mean(abs(a2$beta))
range(a1$p_value);range(a2$p_value)
sum(a1$p_value<0.05);sum(a2$p_value<0.05)
sum(a1$p_value<0.01);sum(a2$p_value<0.01)

sum(a1$p_value<0.001);sum(a2$p_value<0.001)
a1[a1$p_value<0.001,c( "rsid" ,"beta" , "p_value"   )]
a2[a2$p_value<0.001,c( "rsid" ,"beta" , "p_value"   )]

par(mfrow=c(1,2))
plot(a1$base_pair_location, -log10(a1$p_value))
plot(a2$base_pair_location, -log10(a2$p_value))

########## ploting1 ########## 
library(ggplot2)
library(ggpubr)

# 假设combined数据已准备好
combined <- rbind(
  data.frame(hm_pos=a1$base_pair_location, p_value=a1$p_value, group="a1"),
  data.frame(hm_pos=a2$base_pair_location, p_value=a2$p_value, group="a2")
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
p1 <- ggplot(a1, aes(base_pair_location, -log10(p_value))) +
  geom_point(color="#1f77b4", alpha=0.7) +
  geom_smooth(method="lm", color="#1f77b4", fill="#1f77b4", alpha=0.2) +
  stat_cor(label.x.npc = 0.05, label.y.npc = 0.95) +
  labs(title = "数据集A1", 
       x = "基因组位置", 
       y = "-log10(p-value)") +
  theme_minimal()

# 创建第二个图形（a2数据集）
p2 <- ggplot(a2, aes(base_pair_location, -log10(p_value))) +
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


