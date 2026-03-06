#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22418"
file_dir="/PRS/RPL/output"
code_dir="/PRS"
out_file_dir="/PRS/RPL/input"

## qc4

for chr in $(seq 22 22 ); do
    run_R="Rscript filter_samples.R ${data_field}_base_a_c${chr}.QC.het ${data_field}_base_a_c${chr}.valid.sample"

    job_id=$(dx run swiss-army-knife -iin="${code_dir}/filter_samples.R" \
	     -iin="${file_dir}/${data_field}_base_a_c${chr}.QC.het" \
         -icmd="${run_R}"  --tag="chr${chr}-test_qc4" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8")
		 
    job_ids_qc4="${job_ids_qc4} ${job_id}"
done
 
# Wait for qc4 to complete
dx wait ${job_ids_qc4}
