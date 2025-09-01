#!/bin/bash

# 提取F列数据（跳过标题）
f_values=$(tail -n +2 ukb22418_base_a_c22.QC.het | awk '{print $3}')

# 计算平均值
mean=$(echo "$f_values" | awk '{sum+=$1} END {print sum/NR}')

# 计算标准差
sd=$(echo "$f_values" | awk -v mean="$mean" '{sum+=($1-mean)^2} END {print sqrt(sum/NR)}')

# 计算边界值
lower_bound=$(echo "$mean - 3 * $sd" | bc -l)
upper_bound=$(echo "$mean + 3 * $sd" | bc -l)

# 筛选有效样本并输出
awk -v lower="$lower_bound" -v upper="$upper_bound" '
NR==1 {
    for (i=1; i<=NF; i++) {
        if ($i == "F") f_col = i
        if ($i == "FID") fid_col = i
        if ($i == "IID") iid_col = i
    }
    print "FID IID"
    next
}
$f_col >= lower && $f_col <= upper {
    print $fid_col, $iid_col
}' ukb22418_base_a_c22.QC.het > ukb22418_base_a_c22.valid.sample