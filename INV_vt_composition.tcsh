#!/bin/tcsh

set valid_stages = "invcui.pre.fp invcui.pre.place invcui.cts invcui.post.route invcui.post.opt"

set base_output_dir = $HOME/INV_VT_REPORTS

if ( $#argv != 1 ) then
    echo "(E): Must pass in a valid Innovus stage:"
    echo "     $valid_stages"
else    
    set stage = $argv[1];

    # Check if the user has passed in one of the valid Innovus stages
    set invalid_stage = "1"
    foreach valid_stage ( $valid_stages )
	if ( $stage == "$valid_stage" ) then
	    set invalid_stage = "0";
	endif
    end

    if ( $invalid_stage == "0" ) then
	# Get a list of reports to analyze
	set filelist = `ls $stage/report/${stage}.*tarpt.gz | \grep -v scan | \grep -v PUTS | \grep -v hold | \grep -v vt_breakdown`
	# Cycle through each report found
	foreach fname ( $filelist )
	    /user/dnetrabile/scripts/breakdown_vts_inv_report.tclsh $fname; 
	end

	# Output DIR
	set output_dir_tail = `echo $PWD | sed 's/\// /g' | awk '{printf "%s/%s\n", $(NF-1), $NF}'`
	set full_output_dir = $base_output_dir/$output_dir_tail

	if ( -e $full_output_dir ) then
	    cd $full_output_dir
	    # Tabulate and summarize all the reports
	    \grep "#SUMMARY:" $stage/report/$stage.*vt_breakdown | awk 'BEGIN {FS = ":"}; { printf "%-100s | %100s\n", $1, $3}'
	else
	    echo "(E): $full_output_dir doesn't exist"
	endif

    else
	echo "(E): Must pass in a valid Innovus stage:"
	echo "     $valid_stages"
    endif

endif
