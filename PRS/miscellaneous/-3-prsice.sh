#!/bin/sh

##  cd /mnt/c/Users/Ming/Documents/GitHub/liaoming/PRS

## data_field="ukb22418"
code_dir="/PRS/code"
in_file_dir="/PRS/input"
out_file_dir="/PRS/output"

## PRS
run_PRSice="Rscript PRSice.R \
    --prsice PRSice_linux \
    --base base_GCST90454222.QC.gz \
    --target c22.QC3 \
    --binary-target T \
    --pheno pheno.txt \
    --cov covar.txt \
    --stat OR \
    --or \
    --out RPL_chr22"

#Rscript PRSice.R --prsice PRSice_linux --base base_GCST90454222.QC.gz --target c22.QC3 --binary-target T --pheno pheno.txt --cov covar.txt --stat OR --or --out RPL_chr22
#--clump-kb 250kb --clump-p 1.000000 --clump-r2 0.100000

dx run swiss-army-knife -iin="${code_dir}/PRSice.R" \
	     -iin="${code_dir}/PRSice_linux" \
	     -iin="${in_file_dir}/base_GCST90454222.QC.gz" \
	     -iin="${in_file_dir}/c22.QC3.bed" \
	     -iin="${in_file_dir}/c22.QC3.bim" \
	     -iin="${in_file_dir}/c22.QC3.fam" \
	     -iin="${in_file_dir}/pheno.txt" \
	     -iin="${in_file_dir}/covar.txt" \
         -icmd="${run_PRSice}"  --tag="PRSice_test" \
         --destination="${out_file_dir}"  --brief --yes --instance-type "mem2_ssd2_v2_x8"
