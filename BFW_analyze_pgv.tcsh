#!/bin/tcsh

# This script is used in a 'bfw' track to scan for logfile errors, timedesign summaries, drc, formality results
# Usage: Call this script from inside a track

if ( `pwd | sed 's/\// /g' | awk '{print $(NF-2)}'` != "impl" &&  `pwd | sed 's/\// /g' | awk '{print $(NF-2)}' | sed 's/_/ /g' | awk '{print $1}'` != "release" ) then
    echo "(E): Must specify a track "
else
    set TRACK=$PWD
    echo "(I): Track is $TRACK"



    # Report RLRP violations
    # 1/30/2022: DN: Per Gary Moyer, the max RLRP target has been increased from <300ohms to <500ohms since PGV flow is now using a different QRC file that has higher VIA resistance
    # 8/8/2022: Changed rail from vdd_sys to vdd_core
    if ( `pwd | \grep  odysseya0` != "" ) then
	set rail1=vdd_core
	set rail2=vdd_dig
    else
	set rail1=vdd_sys
	set rail2=vdd_sys
    endif


    set test_report_dir1 = adsRail/latest/reports/rail
    set test_report_dir2 = rpt/archive

    # Check if the static reports directory has been archived
    if ( -e pgv.signoff.static/static_run/$test_report_dir1 ) then
	set base_static_report_dir = pgv.signoff.static/static_run/$test_report_dir1
    else
	set base_static_report_dir = pgv.signoff.static/static_run/$test_report_dir2
    endif

    # Check if the dynamic reports directory has been archived
    if ( -e pgv.signoff.dynamic/dynamic_run/$test_report_dir1 ) then
	set base_dynamic_report_dir = pgv.signoff.dynamic/dynamic_run/$test_report_dir1/domain
    else
	set base_dynamic_report_dir = pgv.signoff.dynamic/dynamic_run/$test_report_dir2
    endif

    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo "(I): Checking RLRP violations on $rail1 ..."    
    echo "\grep ^\- $base_static_report_dir/${rail1}/${rail1}.rlrp_inst | awk '{if(\$3>500){print \$0}}' | \grep -v VNWELL | wc -l"
    \grep ^\- $base_static_report_dir/${rail1}/${rail1}.rlrp_inst | awk '{if($3>500){print $0}}' | \grep -v VNWELL | wc -l

    if ( $rail1 != $rail2 ) then
	echo "(I): Checking RLRP violations on $rail2 ..."    
	echo "\grep \- $base_static_report_dir/${rail2}/${rail2}.rlrp_inst | awk '{if(\$3>500){print \$0}}' | \grep -v VNWELL | wc -l"
	\grep ^\- $base_static_report_dir/${rail2}/${rail2}.rlrp_inst | awk '{if($3>500){print $0}}' | \grep -v VNWELL | wc -l
    endif

    echo "(I): Checking RLRP violations on gnd ..."    
    echo "\grep ^\- $base_static_report_dir/gnd/gnd.rlrp_inst | awk '{if(\$3>500){print \$0}}' | \grep -v VNWELL | wc -l"
    \grep \- $base_static_report_dir/gnd/gnd.rlrp_inst | awk '{if($3>500){print $0}}' | grep -v VNWELL | wc -l

    # Check Signal EM violations 
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    echo ""
    echo "(I): Looking for all zero's in these categories for SignalEM (avg_rms_peak.rpt) report ..."
    echo "cat pgv.signoff.signalEM/signalem_run/adsSem/avg_rms_peak.rpt | \grep -A 6 'EM Violation Summary'"
    cat pgv.signoff.signalEM/signalem_run/adsSem/avg_rms_peak.rpt | \grep -A 6 "EM Violation Summary" | awk '{if($0~/^Nets/){print $0, " <-------------"} else {print $0}}'

    # Check for Dynamic IR violations
    echo ""
    echo "(I): ---------------------------------------------------------------------------------------------"
    #echo "(I): Checking pgv.signoff.dynamic for instances violating dynamic IR 10% decrease in Voltage ..."
    echo "(I): Checking pgv.signoff.dynamic for instances violating dynamic IR 12.5% decrease in Voltage ..."
    #echo "cat pgv.signoff.dynamic/dynamic_run/adsRail/*dynamic*/*.worst.iv | awk '/^- /{if ( $4 < 0.9*0.825 ) {print $0}}' | awk '{if($4!~/NA/){print $0}}' | sort | wc -l"
    #cat pgv.signoff.dynamic/dynamic_run/adsRail/*dynamic*/*.worst.iv | awk '/^- /{if ( $4 < 0.825* 0.9 ) {print $0}}' | awk '{if($4!~/NA/){print $0}}' | sort | wc -l | awk '{print $0, "violations"}'
    #echo "cat pgv.signoff.dynamic/dynamic_run/adsRail/*dynamic*/*.worstavg.iv | awk '/^- /{if ( $4 < 0.9*0.825 ) {print $0}}' | awk '{if($4!~/NA/){print $0}}' | sort | wc -l"
    #cat pgv.signoff.dynamic/dynamic_run/adsRail/*dynamic*/*.worstavg.iv | awk '/^- /{if ( $4 < 0.825* 0.9 ) {print $0}}' | awk '{if($4!~/NA/){print $0}}' | sort | wc -l | awk '{print $0, "violations"}'
    echo ""

    mkdir -p dynamic_ir_fails
    set outfile = ./dynamic_ir_fails/${rail1}_gnd.worstavg.out
    #cat pgv.signoff.dynamic/dynamic_run/adsRail/*dynamic*/${rail1}_gnd.worst.iv | awk '/^- /{if ( $3 < 0.825* 0.9 ) {printf "%.2f ==> %s\n", $3/0.825, $0}}' | sort -n > $outfile
    #cat $base_dynamic_report_dir/${rail1}_gnd.worstavg.iv | awk '/^- /{if ( $3 < 0.825* 0.9 ) {printf "%.2f ==> %s\n", $3/0.825, $0}}' | sort -n > $outfile
    cat $base_dynamic_report_dir/${rail1}_gnd.worstavg.iv | awk '/^- /{if ( $3 < 0.825* 0.85 ) {printf "%.2f ==> %s\n", $3/0.825, $0}}' | sort -n > $outfile
    cp -a $base_dynamic_report_dir/${rail1}_gnd.worstavg.iv dynamic_ir_fails/.
    echo "`wc -l $outfile` dynamic IR fails on $rail1. See $outfile"

    # Create histogram for dynamic IR failures
    set outfile = ./dynamic_ir_fails/${rail1}_gnd.worstavg.histogram
    #cat $base_dynamic_report_dir/${rail1}_gnd.worstavg.iv | awk '/^- /{if($3< 0.825*0.9){printf "%.3fmV\n", $3}}' | sort | uniq -c | awk '{print $2, $1}' | sort -r | awk '{$2=sprintf("%-*s", $2, ""); gsub(" ", "=", $2); printf("%-10s%s\n", $1, $2)}' > $outfile
    cat $base_dynamic_report_dir/${rail1}_gnd.worstavg.iv | awk '/^- /{if($3< 0.825*0.85){printf "%.3fmV\n", $3}}' | sort | uniq -c | awk '{print $2, $1}' | sort -r | awk '{printf "%5s | ", $2; $2=sprintf("%-*s", $2, ""); gsub(" ", "=", $2); printf("%-10s%s\n", $1, $2)}' > $outfile
    echo "See histogram of failing values on $rail1. See $outfile"

    if ( $rail1 != $rail2 ) then
	set outfile = ./dynamic_ir_fails/${rail2}_gnd.worstavg.out
	#cat pgv.signoff.dynamic/dynamic_run/adsRail/*dynamic*/${rail2}_gnd.worst.iv | awk '/^- /{if ( $3 < 0.825* 0.9 ) {printf "%.2f ==> %s\n", $3/0.825, $0}}' | sort -n > $outfile
	#cat $base_dynamic_report_dir/${rail2}_gnd.worstavg.iv | awk '/^- /{if ( $3 < 0.825* 0.9 ) {printf "%.2f ==> %s\n", $3/0.825, $0}}' | sort -n > $outfile
	cat $base_dynamic_report_dir/${rail2}_gnd.worstavg.iv | awk '/^- /{if ( $3 < 0.825* 0.85 ) {printf "%.2f ==> %s\n", $3/0.825, $0}}' | sort -n > $outfile
	cp -a $base_dynamic_report_dir/${rail2}_gnd.worstavg.iv dynamic_ir_fails/.
	echo "`wc -l $outfile` dynamic IR fails on $rail2. See $outfile"

	# Create histogram for dynamic IR failures
	set outfile = ./dynamic_ir_fails/${rail2}_gnd.worstavg.histogram
	#cat $base_dynamic_report_dir/${rail2}_gnd.worstavg.iv | awk '/^- /{if($3< 0.825*0.9){printf "%.3fmV\n", $3}}' | sort | uniq -c | awk '{print $2, $1}' | sort -r | awk '{$2=sprintf("%-*s", $2, ""); gsub(" ", "=", $2); printf("%-10s%s\n", $1, $2)}' > $outfile
	cat $base_dynamic_report_dir/${rail2}_gnd.worstavg.iv | awk '/^- /{if($3< 0.825*0.85){printf "%.3fmV\n", $3}}' | sort | uniq -c | awk '{print $2, $1}' | sort -r | awk '{printf "%5s | ", $2; $2=sprintf("%-*s", $2, ""); gsub(" ", "=", $2); printf("%-10s%s\n", $1, $2)}' > $outfile
	echo "See histogram of failing values on $rail1. See $outfile"
    endif
endif
 
