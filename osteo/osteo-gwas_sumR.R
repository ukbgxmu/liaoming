### from liaoming's dell
setwd("D:/2-postDR/mo/osteocalcinGWAS20241024/data/Sun/GCST90242175/harmonised")

a<-read_tsv("D:/2-postDR/mo/osteocalcinGWAS20241024/data/Sun/GCST90242175/harmonised/GCST90242175.h.tsv/BGLAP.11067.13.3.tsv")
a1<-read.table("D:/2-postDR/mo/osteocalcinGWAS20241024/data/Gudjonsson/GCST90089192/harmonised/35078996-GCST90089192-EFO_0010232.h.tsv/harmonised.qc.tsv",header =T)
a2<-read.table("D:/2-postDR/mo/osteocalcinGWAS20241024/data/Gudjonsson/GCST90086529/harmonised/35078996-GCST90086529-EFO_0010232.h.tsv/harmonised.qc.tsv",header =T)


tsv_gz_file<-"GCST90242175.h.tsv.gz"
yaml_file<-"GCST90242175.h.tsv.gz-meta.yaml"

library(yaml)
library(readr)
library(dplyr)

a<-read_tsv(tsv_gz_file)
a<-as.data.frame(a)
# 读取YAML元数据
yaml_data <- read_yaml(yaml_file)
# 查看数据结构
str(a)

### from liaoming's dell
setwd("D:/2-postDR/mo/osteocalcinGWAS20241024/data/Sun/GCST90242175") 
tsv_gz_file<-"GCST90242175_GRCh37.tsv.gz"
yaml_file<-"GCST90242175_GRCh37.tsv.gz-meta.yaml"
b<-read_tsv(tsv_gz_file)
b<-as.data.frame(b)
# 读取YAML元数据
yaml_data <- read_yaml(yaml_file)
# 查看数据结构
str(b)
