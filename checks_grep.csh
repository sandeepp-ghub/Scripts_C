


echo "Noise"
zcat reports/*noise* | grep -B1 Ag | grep -v -e Ag -e "\-\-" |awk '{print $1}' | sort -u 
echo ""
echo "Double"
zcat reports/*double* | grep VIO |awk '{print $1}' | sort -u 
echo ""
echo "Cap"
zcat reports/*max_cap_report_constraint.rpt.gz  | grep VIO |awk '{print $1}' | sort -u
echo ""
echo "Trans"
cat reports/*max_tran_failures.txt |grep _limit | awk '{print $6}' | sort -u 
echo ""
echo "Trans"
