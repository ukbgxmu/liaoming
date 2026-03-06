dx extract_dataset  yongjin:test/male -ddd   
dx extract_dataset ./test/male --fields-file p20002.txt -o p20002.csv 
#dx extract_dataset ./test/male --fields-file p412022_4.txt -o p412022_4.csv 
dx extract_dataset ./test/male --fields-file p87.txt -o p87.csv 

dx extract_dataset ./test/male --fields-file diagnosis.txt -o diagnosis.csv 
dx extract_dataset ./test/male --fields-file diagnosis_date.txt -o diagnosis_date.csv 



dx extract_dataset  all  --fields-file qc_var.txt  -o qc_var.csv 





https://github.com/pydata/numexpr/blob/master/doc/user_guide.rst

import os
os.environ['NUMEXPR_MAX_THREADS'] = '16'
os.environ['NUMEXPR_NUM_THREADS'] = '8'
import numexpr as ne


~/tmp# python3 -c "import numexpr;numexpr.set_num_threads(64);numexpr.test()"