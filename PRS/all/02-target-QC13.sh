#!/bin/sh

## cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS # from liaoming's Dell
## cd /mnt/c/Users、Administrator/Documents/GitHub/liaoming/PRS/code  # from liaoming's YiWuBu

data_field="ukb22828"
file_dir="/Bulk/Imputation/UKB imputation from genotype"
snp_file_dir="/PRS/RPL/input"
in_file_dir="/PRS/input"
out_file_dir="/PRS/output"

## qc13
job_ids_qc13=""
for chr in $(seq 1 22); do
    run_plink="plink2 --bgen ${data_field}_c${chr}_b0_v3.bgen ref-first \
        --sample ${data_field}_c${chr}_b0_v3.sample \
        --maf 0.01 --geno 0.01 --hwe 1e-6 \
        --rm-dup exclude-mismatch \
        --extract c${chr}_imp.snplist.txt \
        --keep qc_check_all.txt \
        --make-bed \
        --out imp_QC13_c${chr}"

    job_id=$(dx run swiss-army-knife -iin="${file_dir}/${data_field}_c${chr}_b0_v3.bgen" \
         -iin="${file_dir}/${data_field}_c${chr}_b0_v3.sample" \
         -iin="${snp_file_dir}/c${chr}_imp.snplist.txt" \
         -iin="${in_file_dir}/qc_check_all.txt" \
         -icmd="${run_plink}"  --tag="all_chr${chr}" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8")
    job_ids_qc13="${job_ids_qc13} ${job_id}"
done

# Wait for qc13 to complete
dx wait ${job_ids_qc13}