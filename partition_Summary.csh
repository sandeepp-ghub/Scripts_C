



echo "MAX TRANS"
echo ""
zcat reports/*_max_tran_report_constraint.rpt.gz | grep VIO | awk '{print $1}' | sort -u 
echo ""

echo "MAX CAP"
echo ""
zcat reports/*_max_cap_report_constraint.rpt.gz | grep VIO | awk '{print $1}' | sort -u 
echo ""

echo "MIN PERIOD"
echo ""
grep VIO reports/*_min_period_failures_not_waived.txt  
echo ""

echo "MIN PULSE WIDTH"
echo ""
grep VIO reports/*_min_pulse_width_failures_not_waived.txt 
echo ""

echo "NOISE"
echo ""

zgrep -B1 Aggressors: reports/*_report_noise.rpt.gz | grep -v -e Aggre -e "\-\-" | awk '{print $2}' | sort -u 
echo ""

echo "SI DOUBLE SWITCHING"
echo ""
zgrep -B1 Aggre  reports/*report_si_double_switching_clock_network.rpt.gz |  grep -v -e Aggre -e "\-\-" | awk '{print $2}' |sort -u
echo ""

echo "XTALK"
echo ""
 cat reports/quality_reports/*/high_xtalk_nets_checklist_*.rpt |sed -ne 's/,/ /gp' | awk '{print $2}' | grep -v "^NET"|  sort -u
echo ""

echo "UNAPPROVE CLOCK CELL"
echo ""
 cat reports/quality_reports/*/unapproved_clock_types_checklist_*.rpt | sort -u
echo ""

echo "GATED CLOCK"
echo ""
cat reports/quality_reports/*/gated_clocks_checklist_*.rpt | sort -u 
echo ""

echo "UNANNOTATED NETS"
echo ""
grep "Pin to pin nets" */4_report_annotated_parasitics.rpt | awk '{print $(NF-1)}' | sort -u
echo ""

echo "CHECK_TIMING : UNCONSTRAINED ENDPOINT"
echo ""
cat reports/*_check_timing.rpt.NOT_waived_phase2 | grep -A12 "Information: Checking .unconstrained_endpoints" | sort -u | grep -v -e "NOTE" -e "^Info" -e "endpoints which are not constrained for maximum delay" -e "^<<" -e "\-\-" -e "^Endpoint" -e "^ of the same clock" 
echo ""

echo "CHECK_TIMING : NO_CLOCK"
echo ""
cat reports/*_check_timing.rpt.NOT_waived_phase2 | grep -A9 "Information: Checking .no_clock" | sort -u | grep -v -e "^<<" -e "^Info" -e "\-\-" -e "Clock Pin" -e "register clock pins with no clock"
echo ""


#cat post_du.csv | sed -ne 's/,/ /gp' | grep " min " | awk 'BEGIN {wns=1000;tns=0;fep=0} { if ($6<wns) { wns=$6 } ; tns=tns+$7; fep=fep+$8 } END {print wns" "tns" "fep} '
#cat post_du.csv | sed -ne 's/,/ /gp' | grep " max " | awk 'BEGIN {wns=1000;tns=0;fep=0} { if ($6<wns) { wns=$6 } ; tns=tns+$7; fep=fep+$8 } END {print wns" "tns" "fep} '

