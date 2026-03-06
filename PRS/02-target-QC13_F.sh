#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22828"
file_dir="/Bulk/Imputation/UKB imputation from genotype"
out_file_dir="/PRS/RPL/output"
in_file_dir="/PRS/input"


## qc3
for chr in $(seq 1 22); do
    run_plink_qc3="plink2 --bgen ${data_field}_c${chr}_b0_v3.bgen ref-first  \
	--sample ${data_field}_c${chr}_b0_v3.sample \
    --extract c${chr}.QC1.snplist \
    --keep qc_check_sample.txt \
    --make-bed \
    --out c${chr}.QC3"

    dx run swiss-army-knife -iin="${file_dir}/${data_field}_c${chr}_b0_v3.bgen" \
         -iin="${file_dir}/${data_field}_c${chr}_b0_v3.sample" \
         -iin="${out_file_dir}/c${chr}.QC1.snplist" \
         -iin="${in_file_dir}/qc_check_female.txt" \
         -icmd="${run_plink_qc3}"  --tag="Female_chr${chr}_qc3" \
         --destination="${in_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done

