#!/bin/tcsh

# This script is used in a 'bfw' track to scan for logfile errors, timedesign summaries, drc, formality results
# Usage: Call this script from inside a track

if ( `pwd | sed 's/\// /g' | awk '{print $(NF-2)}'` != "impl" &&  `pwd | sed 's/\// /g' | awk '{print $(NF-2)}' | sed 's/_/ /g' | awk '{print $1}'` != "release" ) then
    echo "(E): Must specify a track "
else
    set TRACK=$PWD
    echo "(I): Track is $TRACK"

    # Check for errors in all logfiles
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking for logfile errors ..."
    grep -ci Error: */logfiles/*.log
    echo ""

    # Check timedesign summaries 
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking TimeDesign Summaries ..."
    echo "(I):    SETUP ..."
    ls -t invcui.*/report/*design.summa* | awk '{print "less", $0}'
    echo ""
    echo "(I):    HOLD ..."
    ls -t invcui.*/report/*design*hold*summa* | awk '{print "less", $0}'
    echo ""    

    # Check the DRC count in invcui.post.opt/report
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking Innovus DRC count ..."
    zgrep -i "total drc" invcui.post.opt/report/*drc*
    echo ""

    # Check if Formality Successfully completed.
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking Formality ..."
    grep -i "verification succeeded" fm.invcui.r2g/logfiles/*.log
    echo ""

    # Report Utilization
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking utilization ..."
    echo ""
    \zgrep -i "Placement Density:" invcui.post.opt/report/*check*place*

    # Check DRC violations in pv.signoff.drc
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking pv.signoff.drc ..."
    set fname = pv.signoff.drc/dataout/drc.sum
    if ( -e $fname ) then
	echo "grep RULECHECK $fname | grep -v RR: | grep -v STATISTICS | less"
	\grep RULECHECK $fname | grep -v RR: | grep -v STATISTICS | wc -l
	echo "tail $fname | grep sum:"
	tail $fname | grep sum:
    else 
	echo "(E): Cannot find $fname (skipping check)."
    endif

    # Report Ant violations
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking LVS ant ..."
    set fname = pv.signoff.ant/dataout/ant.sum
    if ( -e $fname ) then
	echo "\grep -c $fname | grep sum:"
	tail $fname | grep sum:
    else
	echo "(E): Cannot find $fname (skipping check)."
    endif

    # Report Opens
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking LVS opens ..." 
    set fname = pv.signoff.lvsn/dataout/lvsn.sum
    if ( -e $fname ) then
	echo "\grep -c 'Open circuit' $fname"
	\grep -c "Open circuit" $fname
    else
	echo "(E): Cannot find $fname (skipping check)."
    endif	

    set fname = pv.signoff.lvsq/dataout/lvsq.sum
    if ( -e $fname ) then
	echo "\grep -c 'Open circuit' $fname"
	\grep -c "Open circuit" $fname
    else
	echo "(E): Cannot find $fname (skipping check)."
    endif	
    

    # Report Shorts
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking LVS shorts ..."    
    echo "\grep -c SHORT pv.signoff.lvsn/lvs_LV*/*/lvs.rep.shorts"
    \grep -c SHORT pv.signoff.lvsn/lvs_LV*/*/lvs.rep.shorts
    echo "\grep -c SHORT pv.signoff.lvsn/lvs_LV*/*/lvs.rep.shorts"
    \grep -c SHORT pv.signoff.lvsq/lvs_LV*/*/lvs.rep.shorts

    # Report RLRP violations
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking RLRP violations on vdd_sys ..."    
    echo "\grep \- pgv.signoff.static/static_run/adsRail/*/Reports/vdd_sys/vdd_sys.rlrp_inst | awk '{if(\$3>300){print \$0}}' | wc -l"
    \grep \- pgv.signoff.static/static_run/adsRail/*/Reports/vdd_sys/vdd_sys.rlrp_inst | awk '{if($3>300){print $0}}' | wc -l
    echo "(I): Checking RLRP violations on gnd ..."    
    echo "\grep \- pgv.signoff.static/static_run/adsRail/*/Reports/gnd/gnd.rlrp_inst | awk '{if(\$3>300){print \$0}}' | wc -l"
    \grep \- pgv.signoff.static/static_run/adsRail/*/Reports/gnd/gnd.rlrp_inst | awk '{if($3>300){print $0}}' | wc -l

    # Check Signal EM violations 
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking pgv.signoff.signalEM violations ..."
    echo "cat pgv.signoff.signalEM/INT_SETUP/CEL-SIGNALEM/1.0.voltus/rpt/em/*.SignalEM.rms.wire.Worst1000.txt | \grep -v '^#' | wc -l"
    cat pgv.signoff.signalEM/INT_SETUP/CEL-SIGNALEM/1.0.voltus/rpt/em/*.SignalEM.rms.wire.Worst1000.txt | grep -v "^#" | wc -l | awk '{print $0, "violations"}'

    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Looking for all zero's in these categories for SignalEM (avg.rpt) report ..."
    echo "cat pgv.signoff.signalEM/signalem_run/*/adsSem/avg.rpt | \grep -A 14 'Total Skipped Nets:' | \grep -e Physically -e '  Nets' | \grep -v driver: | \grep -v receiver:"
    cat pgv.signoff.signalEM/signalem_run/*/adsSem/avg.rpt | \grep -A 14 "Total Skipped Nets:" | \grep -e "Physically" -e "  Nets" | \grep -v driver: | \grep -v receiver: 

    echo ""
    echo "(I): Looking for all zero's in these categories for SignalEM (peak.rpt) report..."
    echo "cat pgv.signoff.signalEM/signalem_run/*/adsSem/peak.rpt | \grep -A 14 'Total Skipped Nets:' | \grep -e Physically -e '  Nets' | \grep -v driver: | \grep -v receiver:"
    cat pgv.signoff.signalEM/signalem_run/*/adsSem/peak.rpt | \grep -A 14 "Total Skipped Nets:" | \grep -e "Physically" -e "  Nets" | \grep -v driver: | \grep -v receiver: 

    echo ""
    echo "(I): Looking for all zero's in these categories for SignalEM (rms.rpt) report ..."
    echo "cat pgv.signoff.signalEM/signalem_run/*/adsSem/rms.rpt | \grep -A 14 'Total Skipped Nets:' | \grep -e Physically -e '  Nets' | \grep -v driver: | \grep -v receiver:"
    cat pgv.signoff.signalEM/signalem_run/*/adsSem/rms.rpt | \grep -A 14 "Total Skipped Nets:" | \grep -e "Physically" -e "  Nets" | \grep -v driver: | \grep -v receiver: 
    # Check timing results
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Check timing results ..."
    cd pt.signoff/timing_rundir/reports
    /user/dnetrabile/scripts/show_timing_results.tcsh
    cd -
    echo ""

    # Check the top 5 worst slacks in PrimeTime run (func_max1)
    #echo "(I): ---------------------------------------------------------------------------------------------"
    #echo "(I): Checking 10 worst reg2reg slacks in func_max1 corner ..."
    #/user/dnetrabile/scripts/show_startpoint_endpoint_from_PT_rpt.sh pt.signoff/timing_rundir/reports/func_max1_failing_paths.rpt.gz | grep -v IN: | grep -v OUT: | wc -l | awk '{printf "(I): Found %s SETUP violations\n", $0}'
    #/user/dnetrabile/scripts/show_startpoint_endpoint_from_PT_rpt.sh pt.signoff/timing_rundir/reports/func_max1_failing_paths.rpt.gz | grep -v IN: | grep -v OUT: | awk '{if(NR<=10){printf "%2s ## %s\n", NR, $0}}'
    #/user/dnetrabile/scripts/show_startpoint_endpoint_from_PT_rpt.sh pt.signoff/timing_rundir/reports/func_max1_failing_paths.rpt.gz | grep -v IN: | grep -v OUT: | wc -l | awk '{printf "%s violations\n", $0}'
    echo ""

    # Check the top 5 worst slacks in PrimeTime run (func_min6)
    #echo "(I): ---------------------------------------------------------------------------------------------"
    #echo "(I): Checking 10 worst reg2reg slacks in func_min6 corner ..."
    #/user/dnetrabile/scripts/show_startpoint_endpoint_from_PT_rpt.sh pt.signoff/timing_rundir/reports/func_min6_failing_paths.rpt.gz | grep -v IN: | grep -v OUT: | wc -l | awk '{printf "(I): Found %s HOLD violations\n", $0}'
    #echo "/user/dnetrabile/scripts/show_startpoint_endpoint_from_PT_rpt.sh pt.signoff/timing_rundir/reports/func_min6_failing_paths.rpt.gz | grep -v IN: | grep -v OUT: | less"
    #/user/dnetrabile/scripts/show_startpoint_endpoint_from_PT_rpt.sh pt.signoff/timing_rundir/reports/func_min6_failing_paths.rpt.gz | grep -v IN: | grep -v OUT: | awk '{if(NR<=10){printf "%2s ## %s\n", NR, $0}}'
    #/user/dnetrabile/scripts/show_startpoint_endpoint_from_PT_rpt.sh pt.signoff/timing_rundir/reports/func_min6_failing_paths.rpt.gz | grep -v IN: | grep -v OUT: | wc -l | awk '{printf "%s violations\n", $0}'
    echo ""

endif
 
