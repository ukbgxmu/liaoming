#!/bin/bash

# code_dir="/PRS/code" #    -iin="${code_dir}/merge_list.txt" \
# plink2 合并命令
# plink_cmd="plink2 --bfile c1.QC3 --pmerge-list merge_list.txt --make-bed --out target"

in_file_dir="/PRS/input"
out_file_dir="/PRS/RPL/output"

# SAK 提交任务
dx run swiss-army-knife \
    -iin="${in_file_dir}/c1.QC3.bed" \
    -iin="${in_file_dir}/c1.QC3.bim" \
    -iin="${in_file_dir}/c1.QC3.fam" \
    $(for chr in $(seq 2 22); do \
        echo -n "-iin=${in_file_dir}/c${chr}.QC3.bed "; \
        echo -n "-iin=${in_file_dir}/c${chr}.QC3.bim "; \
        echo -n "-iin=${in_file_dir}/c${chr}.QC3.fam "; \
    done) \
    -icmd="for chr in \$(seq 2 22); do \
    echo c\$chr.QC3.bed c\$chr.QC3.bim c\$chr.QC3.fam >> /tmp/merge_list.txt; \
done; \
plink2 --bfile c1.QC3 --pmerge-list /tmp/merge_list.txt --make-bed --out merged_QC3" \
    --tag="plink2-merged-QC3" \
    --destination="${out_file_dir}" --brief --yes --instance-type "mem2_ssd2_v2_x8"

 
