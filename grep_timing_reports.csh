
cd /proj/cayman/wa/vvenugopalan/impl/hbm_xbar_wrapper_0.1.0A/track.1219_flat_postroute/tempuscui.postroute.sta/SETH.TTR2.hbm_xbar_wrapper_0.005.2022-12-19-23:01:16/TTR2_out
zgrep -n "Startpoint:\| Endpoint:\| Slack" report_tmg.merged_bucket.late.xbar_to_default.txt.gz | paste - - - | grep -v "\/SI" | grep -v lockup > late_xbar_to_default.rpt
zgrep -n "Startpoint:\| Endpoint:\| Slack" report_tmg.merged_bucket.early.default_to_xbar.txt.gz | paste - - - | grep -v "\/SI" | grep -v lockup > early_default_to_xbar.rpt

zgrep -n "Startpoint:\| Endpoint:\| Slack" report_tmg.merged_bucket.late.xbar_to_default.txt.gz | paste - - - | grep -v "\/SI" | grep lockup > late_xbar_to_default.withlockup.rpt

zcat report_tmg.merged_bucket.late.xbar_to_default.txt.gz  | tail -n+104232 | head -500 > worst_path.late.xbar_to_default.rpt

zcat report_tmg.merged_bucket.early.default_to_xbar.txt.gz  | tail -n+230 | head -500 > worst_path.early.default_to_xbar.rpt

zcat report_tmg.merged_bucket.late.xbar_to_default.txt.gz  | tail -n+426 | head -500 > full_path.late_xbar_to_default.withlockup.rpt

#/proj/cayman/wa/vvenugopalan/impl/hbm_xbar_wrapper_0.1.0A/track.1219_flat_postroute/tempuscui.postroute.sta/SETH.TTR2.hbm_xbar_wrapper_0.005.2022-12-19-23:01:16/TTR2_out
#-rw-rw-rw- 1 seth cayman    360210 Dec 21 20:45 late_xbar_to_default.rpt
#-rw-rw-rw- 1 seth cayman  22071597 Dec 21 20:47 early_default_to_xbar.rpt
#-rw-rw-rw- 1 seth cayman    295932 Dec 21 20:54 worst_path.late.xbar_to_default.rpt
#-rw-rw-rw- 1 seth cayman    244462 Dec 21 21:39 worst_path.early.default_to_xbar.rpt

grep "child_release(hbm_xbar_wrapper_0)" flow/track_config.tcl
grep "child_release(xbar_top_32_0)" flow/track_config.tcl
