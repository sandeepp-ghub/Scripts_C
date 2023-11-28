

#set instance_file /user/dnetrabile/instances_pgv

if {![info exist ::hier_prefix]} { set ::hier_prefix "" }
#set ::hier_prefix "pcie*/*/"

puts "NOTE: ::hier_prefix is set to '$::hier_prefix'"

proc get_timing_info_for_pgv_instances { instance_file } {
    set input_id [open $instance_file r]

    if { ![file exists $instance_file] } {
	puts "(E): Specified instance file doesn't exist: $instance_file"
    } else {
	set cells ""
	array unset xref_cell_to_eiv

	set cell_delay_scale_factor "0.20" ; # 20% delay factor

	set i 0; 
	puts "##SCENARIOS: [get_object [current_scenario]]"
	set format_line [format "%6s | %10s %10s %-50s %30s | %10s %-50s | %10s | %20s | %25s %s | %s --> %s" "#Index" "ScaledSLK" "MaxSlack" "WorstMaxCorner" "DLY/ScaledDLY" "MinSlack" "WorstMinCorner" "EIV" "X Y" "Refname" "Cell" "Startpoint_max" "Endpoint_max"]; puts $format_line 

	array unset max_slack
	array unset min_slack
	array unset array_max_slack
	array unset array_min_slack

	while {[gets $input_id line] >= 0 } {
	    set split_line [split $line "|"]
	    set eiv  [lindex $split_line 0]
	    set location [lindex $split_line 1]
	    set ref_name [lindex $split_line 2]
	    set cell [string trim [lindex $split_line end]]
	    set xref_cell_to_eiv($cell) $eiv
	    #lappend cells $cell
	    set eiv $xref_cell_to_eiv($cell)

	    set worst_max_corner "NA"
	    set worst_min_corner "NA"

	    #puts "DEBUG: got here 1"
	    #TO-DO: Need to put code to automatically detect the context, especially in DMSA session
	    remote_execute "set cell \[get_cells -quiet pcie*/*/${cell}\]"
	    remote_execute "set cell_delay_scale_factor \[format %.2f $cell_delay_scale_factor\]"
	    remote_execute { 
		if {[sizeof_collection $cell] > 0} {
		    set tp_max [get_timing_path -through $cell -slack_lesser_than inf -delay_type max ];  
		    set max_slack [get_attribute $tp_max slack]; 
		    set sp_max [get_object [get_attribute $tp_max startpoint]]; 
		    set ep_max [get_object [get_attribute $tp_max endpoint]]; 

		    # -----
		    # Write the timing path to a file and read it back in again to get the cell delay
		    set tmp_file "tmp_file.out"
		    redirect -file $tmp_file { report_timing $tp_max -significant_digits 4 -nosplit }

		    # Read in the worst timing path
		    set tmp_file_id [open $tmp_file r]
		    while {[gets $tmp_file_id tmp_line] >= 0 } {
			#puts $tmp_line
			#pemc/u_mac_wrap/DWC_pcie_ctl/u_DWC_pcie_core/u_radm_rc/u_radm_formation/u_radm_formation_queue/FE_OCPC73713_FE_OFN181142_n108042/ZN (INVD8BWP210H6P51CNODULVTLL) <-         0.0193 &   1.4626 f
  
			if {[string match "* <- *" $tmp_line]} {
			    set cell_delay [format %.4f [lindex $tmp_line 3]]
			    set scaled_delay [format %.4f [expr $cell_delay * $cell_delay_scale_factor]]
			    set scaled_slack [format %.4f [expr $max_slack - $scaled_delay]]
			}
		    }
		    close $tmp_file_id

		    # -----
		    set tp_min [get_timing_path -through $cell -slack_lesser_than inf -delay_type min ];  
		    set min_slack [get_attribute $tp_min slack]; 
		    set sp_min [get_object [get_attribute $tp_min startpoint]]; 
		    set ep_min [get_object [get_attribute $tp_min endpoint]]; 

		    set array_tp_max    $tp_max
		    set array_sp_max    $sp_max
		    set array_ep_max    $ep_max
		    set array_sp_min    $sp_min
		    set array_ep_min    $ep_min
		    set array_max_slack $max_slack
		    set array_min_slack $min_slack

		    set array_cell_delay $cell_delay
		    set array_scaled_delay $scaled_delay
		    set array_scaled_slack $scaled_slack

		} else {
		    set sp_max "NA"
		    set ep_max "NA"
		    set max_slack "NA"
		    set min_slack "NA"
		    set sp_min "NA"
		    set ep_min "NA"
		    set array_sp_max "NA"
		    set array_ep_max "NA"
		    set array_sp_min "NA"
		    set array_ep_min "NA"
		    set array_min_slack "NA"
		    set array_max_slack "NA"
		    set scaled_slack "NA"
		}
	    }

	    #puts "DEBUG: got here 2"
	    # Need to merge variables from child sessions back to the parent session.
	    # ---
	    if {[info exists tp_max]} {unset tp_max }
	    get_distributed_variables tp_max -merge_type none
	    if {[info exists sp_max]} {unset sp_max }
	    get_distributed_variables sp_max -merge_type none
	    if {[info exists ep_max]} {unset ep_max }
	    get_distributed_variables ep_max -merge_type none

	    if {[info exists array_tp_max]} {unset array_tp_max }
	    get_distributed_variables array_tp_max -merge_type none
	    if {[info exists array_sp_max]} {unset array_sp_max }
	    get_distributed_variables array_sp_max -merge_type none
	    if {[info exists array_ep_max]} {unset array_ep_max }
	    get_distributed_variables array_ep_max -merge_type none

	    # ---
	    if {[info exists tp_min]} {unset tp_min }
	    get_distributed_variables tp_min -merge_type none
	    if {[info exists sp_min]} {unset sp_min }
	    get_distributed_variables sp_min -merge_type none
	    if {[info exists ep_min]} {unset ep_min }
	    get_distributed_variables ep_min -merge_type none

	    if {[info exists array_tp_min]} {unset array_tp_min }
	    get_distributed_variables array_tp_min -merge_type none
	    if {[info exists array_sp_min]} {unset array_sp_min }
	    get_distributed_variables array_sp_min -merge_type none
	    if {[info exists array_ep_min]} {unset array_ep_min }
	    get_distributed_variables array_ep_min -merge_type none

	    # ---
	    if {[info exists min_slack]} { unset min_slack }
	    get_distributed_variables min_slack -merge_type min
	    if {[info exists max_slack]} { unset max_slack }
	    get_distributed_variables max_slack -merge_type min

	    if {[info exists array_min_slack]} { unset array_min_slack }
            get_distributed_variables array_min_slack -merge_type none
	    if {[info exists array_max_slack]} { unset array_max_slack }
	    get_distributed_variables array_max_slack -merge_type none


	    # ---
	    if {[info exists array_cell_delay]} { unset array_cell_delay }
            get_distributed_variables array_cell_delay -merge_type none
	    if {[info exists array_scaled_delay]} { unset array_scaled_delay }
	    get_distributed_variables array_scaled_delay -merge_type none
	    if {[info exists array_scaled_slack]} { unset array_scaled_slack }
	    get_distributed_variables array_scaled_slack -merge_type none

	    #puts "DEBUG: got here 4"
	    #parray array_max_slack
	    #parray array_sp_max
	    #parray array_sp_min

	    # Cycle through the corners that the merged variable returns for max slack
	    # The purpose is to identify the corner, startpoint, and endpoint associated with the worst slack
	    foreach corner [array names array_max_slack] { 
		if { $array_max_slack($corner) == "$max_slack" } { 
		    set worst_max_corner $corner

		    # Get the values for that identified worst corner
		    set worst_sp_max $array_sp_max($corner)
		    set worst_ep_max $array_ep_max($corner)

		    set cell_delay   $array_cell_delay($corner)
		    set scaled_delay $array_scaled_delay($corner)
		    set scaled_slack $array_scaled_slack($corner)
		}
	    }

	    #puts "DEBUG: got here 5"
	    # Cycle through the corners that the merged variable returns for min slack
	    foreach corner [array names array_min_slack] { 
		if { $array_min_slack($corner) == "$min_slack" } { 
		    set worst_min_corner $corner
		    set worst_sp_min $array_sp_min($corner)
		    set worst_ep_min $array_ep_min($corner)
		}
	    }

	    incr i; 

	    #puts "DEBUG: got here 6"
	    #if {![info exists scaled_slack]} { set scaled_slack "NA" }
	    set format_line [format "%6s | %10s %10s %-50s %30s | %10s %-50s | %10s | %20s | %25s  %s | %s --> %s" $i $scaled_slack $max_slack $worst_max_corner $cell_delay/$scaled_delay $min_slack $worst_min_corner $eiv $location $ref_name $cell $worst_sp_max $worst_ep_max]; puts $format_line 
	    #set format_line [format "%6s | %10s | %10s | %10s | %10s | %25s  %s " $i $max_slack $min_slack $window $eiv $ref_name $cell]; puts $format_line 

	}

	close $input_id 
    }
}

puts "Loading procedure: 'get_timing_info_for_pgv_instances <eiv_instance_file_from_INV>'"
