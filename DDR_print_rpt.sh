set frun=`l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/ | grep dss_2ch__ | awk '{print $9}' | sort | tail -n 1`
echo "#===========================#"
echo "# Func Missing unannotation #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/*unannotated*
echo "#===========================#"
echo "# Func check_timing         #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/reports/*NOT*
echo "#===========================#"
echo "# Func max tran const       #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/reports/*max_tran_report_constraint*
echo "#===========================#"
echo "# Func max cap const        #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/reports/*max_cap_report_constraint*
echo "#===========================#"
echo "# Func min pulse width      #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/reports/*min_pulse_width*not_waived*
echo "#===========================#"
echo "# Func min_period           #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/reports/*min_period*not_waived*
echo "#===========================#"
echo "# Func internal rpt         #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/reports/split_rpt/*/hierarchical_full/dss_dch_top-internal.sum.gz
echo "#===========================#"
echo "# Func external rpt         #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_rundirs/$frun/reports/split_rpt/*/hierarchical_full/dss_dch_top-interface.sum.gz




set srun=`l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/ | grep dss_2ch__ | awk '{print $9}' | sort | tail -n 1`
echo "#===========================#"
echo "# Scan Missing unannotation #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/*unannotated*
echo "#===========================#"
echo "# Scan check_timing         #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/reports/*NOT*
echo "#===========================#"
echo "# Scan max tran const       #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/reports/*max_tran_report_constraint*
echo "#===========================#"
echo "# Scan max cap const        #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/reports/*max_cap_report_constraint*
echo "#===========================#"
echo "# Scan min pulse width      #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/reports/*min_pulse_width*not_waived*
echo "#===========================#"
echo "# Scan min_period           #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/reports/*min_period*not_waived*
echo "#===========================#"
echo "# Scan internal rpt         #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/reports/split_rpt/*/hierarchical_full/dss_dch_top-internal.sum.gz
echo "#===========================#"
echo "# Scan external rpt         #"
echo "#===========================#"
l /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/$srun/reports/split_rpt/*/hierarchical_full/dss_dch_top-interface.sum.gz


