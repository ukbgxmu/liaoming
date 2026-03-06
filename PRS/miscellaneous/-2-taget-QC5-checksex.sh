#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22418"
geno_file_dir="/Bulk/Genotype Results/Genotype calls/"
in_file_dir="/PRS/RPL/input/"
out_file_dir="/PRS/RPL/output/"

## qc5

for chr in $(seq 22 22 ); do
    run_plink="plink --bfile ${data_field}_c${chr}_b0_v2  \
        --extract ${data_field}_base_a_c${chr}.QC.prune.in  \
		--keep ${data_field}_base_a_c${chr}.valid.sample \
        --check-sex \
        --out ${data_field}_base_a_c${chr}.QC"

    dx run swiss-army-knife -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bed" \
         -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bim" \
		 -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.fam" \
		 -iin="${out_file_dir}/${data_field}_base_a_c${chr}.QC.prune.in" \
		 -iin="${in_file_dir}/${data_field}_base_a_c${chr}.valid.sample" \
         -icmd="${run_plink}"  --tag="test__qc5" \
         --destination="${in_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done
