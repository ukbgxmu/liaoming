#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22418"
geno_file_dir="/Bulk/Genotype Results/Genotype calls/"
in_file_dir="/PRS/RPL/input/"
out_file_dir="/PRS/RPL/output/"

## qc1

for chr in $(seq 21 22 ); do
    run_plink_geno1="plink --bfile ${data_field}_c${chr}_b0_v2  \  
        --maf 0.01 --geno 0.01 --mind 0.01 --hwe 1e-6 \  
		--write-snplist \
        --make-just-fam \
        --out ${data_field}_base_a_c${chr}.QC"

    dx run swiss-army-knife -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bed" \
         -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.bim" \
		 -iin="${geno_file_dir}/${data_field}_c${chr}_b0_v2.fam" \
         -icmd="${run_plink_geno1}"  --tag="chr${chr}-RPL-PRS_base-a_qc1" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
done
 
# ref-first
# make-just-fam 	- 	Informs plink to only generate the QC'ed sample name to avoid generating the .bed file.
# write-snplist 	- 	Informs plink to only generate the QC'ed SNP list to avoid generating the .bed file.

plink --bfile ukb22418_c22_b0_v2 --maf 0.01 --geno 0.01 --mind 0.01 --hwe 1e-6  --write-snplist  --make-just-fam  --out ukb22418_base_a_qc1.QC