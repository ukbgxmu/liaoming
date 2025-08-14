#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22418"
geno_file_dir="/Bulk/Genotype Results/Genotype calls/"
in_file_dir="/PRS/RPL/input/"
out_file_dir="/PRS/RPL/output/"


## qc2
for chr in $(seq 21 20); do
    run_plink_geno2="plink2 --bfile ${data_field}_c${chr}_b0_v2  \
    --keep ${data_field}_base_a_c${chr}.QC.fam \
    --extract ${data_field}_base_a_c${chr}.QC.snplist \
    --indep-pairwise 200 50 0.25 \
    --out ${data_field}_base_a_c${chr}.QC"

    dx run swiss-army-knife -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bed" \
         -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bim" \
         -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.fam" \
         -icmd="${run_plink_geno2}"  --tag="chr${chr}-RPL-PRS_base-a_qc2" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done

# Wait for qc2 to complete
wait

## qc3
for chr in $(seq 21 20); do
    run_plink_geno3="plink2 --bfile ${data_field}_c${chr}_b0_v2  \
    --extract ${data_field}_base_a_c${chr}.QC.prune.in \
    --keep ${data_field}_base_a_c${chr}.QC.fam \
    --het \
    --out ${data_field}_base_a_c${chr}.QC"

    dx run swiss-army-knife -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bed" \
         -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bim" \
         -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.fam" \
         -icmd="${run_plink_geno3}"  --tag="chr${chr}-RPL-PRS_base-a_qc3" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done

# Wait for qc3 to complete
wait