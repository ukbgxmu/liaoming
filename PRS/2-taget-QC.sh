#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

data_field="ukb22418"
geno_file_dir="/Bulk/Genotype Results/Genotype calls/"
in_file_dir="/PRS/RPL/input/"
out_file_dir="/PRS/RPL/output/"

## qc1

for chr in $(seq 21 22 ); do
    run_plink_geno1="plink2 --bfile ${data_field}_c${chr}_b0_v2  \  
        --chr ${chr} \
        --maf 0.01 --geno 0.01 --mind 0.01 --hwe 1e-6 \  #--mac 100 
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



## qc2

for chr in $(seq 21 22 ); do
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

# This will generate two files 
# 1) *.QC.prune.in and 
# 2) *.QC.prune.out. All SNPs within *.QC.prune.in have a pairwise r2<0.25. 





## qc3

for chr in $(seq 21 22 ); do
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

# This will generate the EUR.QC.het file, which contains F coefficient estimates for assessing heterozygosity. 
# We will remove individuals with F coefficients that are more than 3 standard deviation (SD) units from the mean, 
# which can be performed using the next R script.