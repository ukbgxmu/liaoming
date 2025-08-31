#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22828"
file_dir="/Bulk/Imputation/UKB imputation from genotype"
out_file_dir="/PRS/RPL/output"
in_file_dir="/PRS/input"


## qc1
for chr in $(seq 1 22); do
    run_plink_qc1="plink2 --bgen ${data_field}_c${chr}_b0_v3.bgen ref-first \
        --sample ${data_field}_c${chr}_b0_v3.sample \
        --maf 0.01 --geno 0.01 --hwe 1e-6 \
        --rm-dup exclude-mismatch \
        --write-snplist \
        --make-just-fam \
        --out c${chr}.QC1"

    job_id=$(dx run swiss-army-knife -iin="${file_dir}/${data_field}_c${chr}_b0_v3.bgen" \
         -iin="${file_dir}/${data_field}_c${chr}_b0_v3.sample" \
         -icmd="${run_plink_qc1}"  --tag="chr${chr}_qc1" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8")
    job_ids_qc1="${job_ids_qc1} ${job_id}"
done

# Wait for qc1 to complete
dx wait ${job_ids_qc1}

## qc2
for chr in $(seq 1 22); do
    run_plink_qc2="plink2 --bgen ${data_field}_c${chr}_b0_v3.bgen ref-first  \
	--sample ${data_field}_c${chr}_b0_v3.sample \
    --keep c${chr}.QC1.fam \
    --extract c${chr}.QC1.snplist \
    --indep-pairwise 200 50 0.25 \
    --out c${chr}.QC2"

    job_id=$(dx run swiss-army-knife -iin="${file_dir}/${data_field}_c${chr}_b0_v3.bgen" \
         -iin="${file_dir}/${data_field}_c${chr}_b0_v3.sample" \
         -iin="${out_file_dir}/c${chr}.QC1.fam" \
         -iin="${out_file_dir}/c${chr}.QC1.snplist" \
         -icmd="${run_plink_qc2}"  --tag="chr${chr}_qc2" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8")
    job_ids_qc2="${job_ids_qc2} ${job_id}"
done

# Wait for qc2 to complete
dx wait ${job_ids_qc2}

## qc3
for chr in $(seq 1 22); do
    run_plink_qc3="plink2 --bgen ${data_field}_c${chr}_b0_v3.bgen ref-first  \
	--sample ${data_field}_c${chr}_b0_v3.sample \
    --extract c${chr}.QC2.prune.in \
    --keep qc_check_sample.txt \
    --make-bed \
    --out c${chr}.QC3"

    dx run swiss-army-knife -iin="${file_dir}/${data_field}_c${chr}_b0_v3.bgen" \
         -iin="${file_dir}/${data_field}_c${chr}_b0_v3.sample" \
         -iin="${out_file_dir}/c${chr}.QC2.prune.in" \
         -iin="${in_file_dir}/qc_check_sample.txt" \
         -icmd="${run_plink_qc3}"  --tag="chr${chr}_qc3" \
         --destination="${in_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done

# Wait for qc3 to complete
wait