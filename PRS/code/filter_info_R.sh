#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22828"
file_dir="/Bulk/Imputation/UKB imputation from genotype"
code_dir="/PRS/code/"
out_file_dir="/PRS/RPL/input/"


## qc0

for chr in $(seq 1 21); do
    run_R="Rscript filter_info.R ${data_field}_c${chr}_b0_v3.mfi.txt c${chr}_imp.snplist.txt 0.8"

    dx run swiss-army-knife -iin="${code_dir}/filter_info.R" \
	     -iin="${file_dir}/${data_field}_c${chr}_b0_v3.mfi.txt" \
         -icmd="${run_R}"  --tag="chr${chr}-test_qc0" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done
 
