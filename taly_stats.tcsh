#!/bin/tcsh


set tracks = ""
set tracks = "$tracks /proj/stc03c1m/wa/dnetrabile/impl/COBRA_TOP/track.custom.65.COBRA_TOP.1.0A.RTL3.1.0_20230929__COBRA_MACPHY_WRAPPER.1.0A.RTL3.1.0_20230929.PhysConf_V017.20231003.mcp_pcie2"
set tracks = "$tracks /proj/stc03c1m/wa/awagstaff/impl/COBRA_TOP/track.custom.17"
set tracks = "$tracks /proj/stc03c1m/wa/rfry/impl/COBRA_TOP/track.custom.17.COBRA_TOP.1.0A__DE3.0__RTL3.1.0_20230929__PhysConfV017__DisabledArcs_20231005"

set stages = "prects cts postcts route postroute"

foreach track ( $tracks )
    echo ""
    echo "# #############################################################################################"
    echo "#"
    echo "# $track"

    foreach stage ( $stages ) 

	echo ""

	if ( $stage == "postcts" ) then
	    set filename_setup = merged.opt.summary_2.gz
	    set filename_hold  = merged.opt.summary_2.gz
	else if ( $stage == "route" || $stage == "postroute" ) then
	    set filename_setup = merged.common_report.summary_2.gz
	    set filename_hold  = merged.common_report.summary_2.gz
	else if ( $stage == "cts" || $stage == "prects" ) then
	    set filename_setup = COBRA_TOP.invcui.$stage.common_report.summary.gz
	    set filename_hold  = COBRA_TOP.invcui.$stage.common_report_hold.summary.gz
	endif

	set setup_report = $track/invcui.$stage/report/$filename_setup
	set  hold_report = $track/invcui.$stage/report/$filename_hold

	if ( -e $setup_report ) then
	    echo "(I): $setup_report ..." | awk '{printf "   %s\n", $0}'
	    # Display Setup Information
	    zgrep -B 2 -A 6 "Setup mode" $setup_report | awk '{printf "      %s\n", $0}'
	else
	    echo "(W): $setup_report not found" | awk '{printf "   %s\n", $0}'
	endif

	echo ""

	if ( -e $hold_report) then
	    echo "(I): $hold_report ..." | awk '{printf "   %s\n", $0}'
	    # Display Hold  Information
	    zgrep -B 2 -A 6 "Hold mode" $hold_report | awk '{printf "      %s\n", $0}'
	else
	    echo "(W): $hold_report not found" | awk '{printf "   %s\n", $0}'
	endif

    end
end

