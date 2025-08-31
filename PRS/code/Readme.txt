1.  本地处理base data

input：GWAS catalog下载的 summary data，

code：01-base-RPL-GCST90454222.R

output: 生成用于PRSice的base data "base_OR_GCST90454222.QC.gz"


2.  线上处理target data

2.1 基于ukb的imputation结构，筛选INFO>0.8的位点

input：ukb的RAP系统里/Bulk/Imputation/UKB imputation from genotype/的 “*.mfi.txt”文件 (按染色体），

code：filter_info.R 和 filter_info_R.sh

output: 生成质控需要的“*.imp.snplist.txt”(按染色体）


2.2 基于ukb的imputation结构，进行位点和样本的质控

input：ukb的RAP系统里/Bulk/Imputation/UKB imputation from genotype/的 “*.bgen”和“*.bsample”文件 (按染色体），

code：02-target-QC123.sh 和 qc_var.R

output:  生成用于PRSice的target data“*.bed”和“*.bim”和“*.fam”(按染色体）


2.3  把按染色体生成的文件合成一个文件

input：上一步生成的“*.bed”和“*.bim”和“*.fam”(按染色体）

code：03-merge_bed.sh  和 co_var.R

output:  生成用于PRSice的target data“*.bed”和“*.bim”和“*.fam”(所有染色体合在一起）



3. 本地计算PRS

input：下载线上target data三个文件“*.bed”和“*.bim”和“*.fam”(所有染色体合在一起）

code：PRSice-merged_QC3.sh

output:  生成PRS结果


############### details #################

1. 读取base数据后质控的步骤有以下
## 1. Standard GWAS QC
#We recommend removing SNPs with MAF < 1% and INFO < 0.8
## 2. Duplicate SNPs
# Remove duplicate rows based on SNP column 
## 3. Ambiguous SNPs
# Remove ambiguous SNPs (A/T, T/A, G/C, C/G) 
## 4. change beta(se) to OR(se) 
## 5. write to gzipped file

2.1 利用 filter_info.R 按染色体读入info数据，并按照0.8阈值筛选

"Usage: Rscript filter_info.R <input_file> <output_file> [info_threshold]"
# 筛选 INFO 分数 > 阈值的行
# 提取 SNP ID（第2列）并保存

2. 2 利用 02-target-QC123.sh对ukb数据进行位点和样本的质控

备注：在RAP线上系统的project目录，新建/PRS/RPL/output作为存储质控过程产生的中间文件，
新建/PRS/input作为存储结果文件。

data_field="ukb22828"
file_dir="/Bulk/Imputation/UKB imputation from genotype"
out_file_dir="/PRS/RPL/output"
in_file_dir="/PRS/input"

## qc1 ## 位点筛选
        --maf 0.01 --geno 0.01 --hwe 1e-6 \
        --rm-dup exclude-mismatch \
        --write-snplist \
        --make-just-fam \
        --out c${chr}.QC1"
 --destination="${out_file_dir}" 

## qc2 ## 位点筛选
    --keep c${chr}.QC1.fam \
    --extract c${chr}.QC1.snplist \
    --indep-pairwise 200 50 0.25 \
    --out c${chr}.QC2"
 --destination="${out_file_dir}" 

## qc3 ## 样本筛选
    --extract c${chr}.QC2.prune.in \
    --keep qc_check_sample.txt \
    --make-bed \
    --out c${chr}.QC3"
--destination="${in_file_dir}" 

其中，qc3中的“qc_check_sample.txt”出自 data文件夹的“qc_var.R”（涉及文件为苏琴2025.08.30上传到synology的"Data10.csv"）

2.3 利用 03-merge_bed.sh 把质控后的ukb数据合并

in_file_dir="/PRS/input"
out_file_dir="/PRS/RPL/output"

  --bfile c1.QC3  --pmerge-list /tmp/merge_list.txt  \
  --make-bed --out merged_QC3" \
--destination="${out_file_dir}"

3.  本地计算PRS

利用第1步生成的“base_OR_GCST90454222.QC.gz”，以及第2步合成的"merged_QC3.bed"，"merged_QC3.bim", "merged_QC3.fam"三个文件。

备注：下载RAP线上系统/PRS/RPL/output里的"merged_QC3.bed"，"merged_QC3.bim", "merged_QC3.fam"三个文件到本地新建的文件夹“PRS”，
该文件夹中还下载有两个运行程序“PRSice.R”和“PRSice_linux”(来源：https://choishingwan.github.io/PRS-Tutorial/prsice/），
并在该文件夹中新建/RPL存储结果文件。

Rscript PRSice.R \
--prsice PRSice_linux \
--base /mnt/d/2-postDR/mo/osteocalcinGWAS20241024/data/RPL/GCST/2025/harmonised/base_OR_GCST90454222.QC.gz \
--target merged_QC3 \
--binary-target T \
--pheno /mnt/d/0-dell-NAS/ukbA/data/liaoming/PRS/RPL/pheno.txt \
--cov /mnt/d/0-dell-NAS/ukbA/data/liaoming/PRS/RPL/covar.txt \
--stat OR \
--or \
--out ./RPL/merged_QC3

其中，“pheno.txt”和“covar.txt”出自 data文件夹的“co_var.R”（涉及文件为苏琴2025.08.30上传到synology的"merged_all_Data1-9_innerjoin.csv"）
