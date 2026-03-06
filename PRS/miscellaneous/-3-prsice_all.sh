#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

## data_field="ukb22418"
code_dir="/PRS/code"
in_file_dir="/PRS/input"
out_file_dir="/PRS/output"

## PRS
run_PRSice="Rscript PRSice.R \
    --prsice PRSice_linux \
    --base base_a.QC.gz \
    --target merged_QC3 \
    --binary-target T \
    --maf 0.01 \
    --geno 0.01 \
    --pheno pheno.txt \
    --cov covar.txt \
    --stat beta \
    --or \
    --out RPL"

#--clump-kb 250kb --clump-p 1.000000 --clump-r2 0.100000

dx run swiss-army-knife -iin="${code_dir}/PRSice.R" \
	     -iin="${code_dir}/PRSice_linux" \
	     -iin="${in_file_dir}/base_a.QC.gz" \
	     -iin="${out_file_dir}/merged_QC3.bed" \
	     -iin="${out_file_dir}/merged_QC3.bim" \
         -iin="${out_file_dir}/merged_QC3.fam" \
         -iin="${in_file_dir}/pheno.txt" \
	     -iin="${in_file_dir}/covar.txt" \
         -icmd="${run_PRSice}"  --tag="PRSice" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
		 
	 

 
