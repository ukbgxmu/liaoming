#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22418"
file_dir="/PRS/RPL/output"
out_file_dir="/PRS/RPL/input"
code_dir="/code"

## qc4

for chr in $(seq 22 22 ); do
    run_R="Rscript filter_sexcheck.R ${data_field}_base_a_c${chr}.valid.sample ${data_field}_base_a_c${chr}.QC.sexcheck ${data_field}_base_a_c${chr}.QC.valid"
	EUR.valid.sample EUR.QC.sexcheck EUR.QC.valid

    dx run swiss-army-knife -iin="${code_dir}/filter_sexcheck.R" \
	     -iin="${file_dir}/${data_field}_base_a_c${chr}.QC.het" \ #1待修改
		 -iin="${file_dir}/${data_field}_base_a_c${chr}.QC.het" \ #2待修改
		 -iin="${file_dir}/${data_field}_base_a_c${chr}.QC.het" \ #3待修改
         -icmd="${run_R}"  --tag="chr${chr}-test_qc4" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done
 
