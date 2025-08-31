#!/bin/sh

#cd /mnt/d/2-postDR/ukb/test
#cd /mnt/g/Downloads/PRS

#sudo umount /mnt/g
#sudo mount -t drvfs G: /mnt/g

Rscript PRSice.R \
--prsice PRSice_linux \
--base /mnt/d/2-postDR/mo/osteocalcinGWAS20241024/data/RPL/GCST/2025/harmonised/base_OR_GCST90454222.QC.gz \
--target merged_QC3 \
--binary-target T \
--pheno /mnt/d/0-dell-NAS/ukbA/data/liaoming/PRS/RPL/pheno.txt \
--cov /mnt/d/0-dell-NAS/ukbA/data/liaoming/PRS/RPL/covar.txt \
--stat OR \
--or \
--out ./RPL/merged_QC3
