namespace eval ::dn {} { 

    #set ::dn::dynamic_ir_threshold_pct 10.0; # "0.742V" ; # 10% ir drop threshold
    #set ::dn::dynamic_ir_threshold_pct 12.5; # "0.721875V";  # 12.5% ir drop threshold for Odyssey on 9/20/2022

    if {![info exists ::dn::dynamic_ir_threshold_pct]} {
	#set ::dn::dynamic_ir_threshold_pct "15.0" ; #  ir drop threshold for Odysseya0 on 10/28/2022
	set ::dn::dynamic_ir_threshold_pct "10.0" ; #  ir drop threshold for Cobra_top on 11/1/2023
    }
    
    set ::dn::ir_drop_bins { {0.10 57} {0.15 49} {0.20 50} { 0.25 59 } { 0.30 64 } }

    proc read_dynamic_ir_fails { input_file } {

	if {![file exists $input_file]} {
	    puts "(E): Input file doesn't exist; $input_file"
	} else {
	    # Parse the file name for the rail
	    # ./pgv.signoff.dynamic/dynamic_run/adsRail/latest/reports/rail/vdd_dig/vdd_dig.worstavg.iv
	    set filetail [file tail $input_file]
	    set rail_name [lindex [split $filetail "."] 0]

	    ::dn::clear_gui_texts
	    puts "(I): Reading $input_file ..."
	    set input_id [open $input_file r]
	    array unset ::dn::ir_drop_fails
	    array unset ::dn::ir_drop_bin_indexes
	    array unset ::dn::ir_drop_histogram
	    array unset ::dn::xref_insts_to_eiv
	    array unset ::dn::xref_eiv_to_insts
	    set total_instances_processed 0
	    set total_instances_passing   0
	    set total_instances_failing   0
	    set total_instances_na        0
	    while {[gets $input_id line] >= 0 } {
		# Parse the file for the 'NOMINAL_VOLTAGE' field
		if {[string match "NOMINAL_VOLTAGE*" $line]} { 
		    set nominal_voltage [format %.3f [lindex $line end]]

		    # Calculate the EIV cutoff for which violations occur
		    set eiv_cutoff [format %.4f [expr $nominal_voltage * (100.0 - $::dn::dynamic_ir_threshold_pct) / 100.0 ]]
		    puts "nominal_voltage = $nominal_voltage"
		    puts "::dn::dynamic_ir_threshold_pct = $::dn::dynamic_ir_threshold_pct"
		    puts "eiv_cutoff = $nominal_voltage * $::dn::dynamic_ir_threshold_pct = $eiv_cutoff"
		}

		# Expected format of the records
		#puts "$line"
		# - pemc/u_mac_wrap/DWC_pcie_ctl/u_DWC_pcie_core/u_radm_rc/u_radm_formation/u_radm_formation_queue/FE_OCPC488872_n370040 0.60483 0.75774 0.15290 0.60483 0.75774 0.15290 BUFFD10BWP210H6P51CNODLVT VDD VSS
		# - pemc/u_mac_wrap/DWC_pcie_ctl/u_DWC_pcie_core/u_radm_rc/u_radm_formation/u_radm_formation_queue/FE_OFC412900_n148714 0.60166 0.72195 0.12029 0.60166 0.72195 0.12029 BUFFD5BWP210H6P51CNODULVTLL VDD VSS

		if {[lindex $line 0] == "-" } {
		    incr total_instances_processed
		    set instance [lindex $line 1]  ; # 2nd field will be the instance name
		    set win_eiv  [lindex $line 2]  ; # 3rd field will be the 'win_eiv' value we need to check

		    # Some records will be 'NA' ... skip those and continue
		    if { $win_eiv != "NA" } {
			set pct_drop [format %.3f [expr 1 - ($win_eiv / $nominal_voltage)]] ; # Calculate a percentage drop from the nominal voltage

			# Store the EIV value for each valid instance
			set win_eiv_rounded [format %.3f $win_eiv]
			set ::dn::xref_insts_to_eiv($instance) "$win_eiv_rounded"
			
			if { $win_eiv <= $eiv_cutoff } {
			    incr total_instances_failing
			    if {![info exists ::dn::ir_drop_fails($instance)]} {
				set ::dn::ir_drop_fails($instance) "$pct_drop"
			    }

			    gui_deselect -all; ; # Deselect all gui objects
			    select_obj [get_cells $instance]  ; # Select this current instance
			    set i 0
			    set bin_index 0

			    foreach bin $::dn::ir_drop_bins {
				set threshold [format %.2f [lindex $bin 0]]
				set color_index [lindex $bin 1]
				if { $pct_drop >= $threshold } {
				    set instance_color "$color_index"
				    set bin_index $i
				}
				incr i
			    }

			    if {![info exists ::dn::ir_drop_histogram($win_eiv_rounded)]} {
				set ::dn::ir_drop_histogram($win_eiv_rounded) "$instance"
			    } else { 
				append ::dn::ir_drop_histogram($win_eiv_rounded) " $instance"
			    }
			    
			    gui_highlight -index $instance_color  ; # Highlight the selected object with the specified instance color
			} else {
			    incr total_instances_passing
			}
		    } else {
			incr total_instances_na
		    }
		}
	    }
	    close $input_id

	    # Count the number of instances in each bin
	    puts "Total Instances Processed: $total_instances_processed"
	    puts "Total Instances Passing:   $total_instances_passing"
	    puts "Total Instances NA:        $total_instances_na"
	    puts "Nominal Voltage (from file): ${nominal_voltage}V"
	    puts "Threshold for fails: $::dn::dynamic_ir_threshold_pct (Set using ::dn::dynamic_ir_threshold_pct)"
	    puts "Total Instances Failing:   $total_instances_failing"

	    # -----------------------------------------------------------
	    # Define starting position to list all the ir_drop_bins text
	    set ir_drop_list_x [expr [ get_db designs .bbox.ur.x] + 30]; # This is the width of the core box + offset
	    set ir_drop_list_y [ get_db designs .bbox.ur.y]; # This is the height of the core box
	    set ir_drop_list_y_spacing 10; # This the spacing in the 'Y' direction of the ir_drop text boxes
	    set ir_drop_list_text_height 10

	    # Define location of text box for the directory path
	    create_gui_text -pt  "0 [expr $ir_drop_list_y + 20]" -layer 999 -label "[pwd]" -height [expr $ir_drop_list_text_height]

	    # Define location of text box for list of group name
	    create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label "## $input_file" -height [expr $ir_drop_list_text_height + 5]

	    # -----------------------------------------------------------
	    # Decrement the next label in the y direction
	    set ir_drop_list_y [expr $ir_drop_list_y - $ir_drop_list_y_spacing]
	    create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label "Total Instances Processed = $total_instances_processed" -height $ir_drop_list_text_height	    
	    
	    # -----------------------------------------------------------
	    # Decrement the next label in the y direction
	    set ir_drop_list_y [expr $ir_drop_list_y - $ir_drop_list_y_spacing]
	    create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label "Total Instances Passing   = $total_instances_passing" -height $ir_drop_list_text_height	    
	    
	    # -----------------------------------------------------------
	    # Decrement the next label in the y direction
	    set ir_drop_list_y [expr $ir_drop_list_y - $ir_drop_list_y_spacing]
	    create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label "Total Instances NA        = $total_instances_na" -height $ir_drop_list_text_height	    

	    # -----------------------------------------------------------
	    # Decrement the next label in the y direction
	    set ir_drop_list_y [expr $ir_drop_list_y - $ir_drop_list_y_spacing]
	    create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label "Nominal Voltage = $nominal_voltage" -height $ir_drop_list_text_height	    

	    # -----------------------------------------------------------
	    # Decrement the next label in the y direction
	    set ir_drop_list_y [expr $ir_drop_list_y - $ir_drop_list_y_spacing]
	    create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label "Threshold for cutoff: -$::dn::dynamic_ir_threshold_pct %" -height $ir_drop_list_text_height	    
	    
	    # -----------------------------------------------------------
	    # Decrement the next label in the y direction
	    set ir_drop_list_y [expr $ir_drop_list_y - $ir_drop_list_y_spacing]
	    create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label "Total Instances Failing   = $total_instances_failing" -height $ir_drop_list_text_height	    
	    
	    set i 0
	    set bin_index 0
	    set ir_drop_list_y_spacing 10
	    # Cycle through each ir_drop_bin
	    foreach win_eiv_rounded [lsort -decreasing [array names ::dn::ir_drop_histogram]] {

		set threshold [format %.2f [expr [lindex $bin 0] * 100]]

		set color_index [lindex $bin 1]

		set failing_instances_count_bin 0.0
		if {[info exists ::dn::ir_drop_bin_indexes($i)]} {
		    set failing_instances_count_bin [format %.2f $::dn::ir_drop_bin_indexes($i)]
		}

		set pct_of_total_failing_instances [format %.2f [expr $failing_instances_count_bin / $total_instances_failing * 100.0]]

		# Decrement the next label in the y direction
		set ir_drop_list_y [expr $ir_drop_list_y - $ir_drop_list_y_spacing]

		set dashes ""
		for { set d 0 } { $d < [llength $::dn::ir_drop_histogram($win_eiv_rounded)] } { incr d } {
		    append dashes "="
		}

		# Define location of text box for list of group name
		set format_line [format "| %-10s | %10s | %s" [llength $::dn::ir_drop_histogram($win_eiv_rounded)] $win_eiv_rounded $dashes]
		create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label $format_line -height $ir_drop_list_text_height
		#create_gui_text -pt "$ir_drop_list_x $ir_drop_list_y"  -layer 999 -label ">= ${threshold}% irdrop ([format %.0f $failing_instances_count_bin] of $total_instances_failing fails) = ${pct_of_total_failing_instances}% of fails in this bin ==> color_index = $color_index" -height $ir_drop_list_text_height
	    
		incr i

	    }

	    set ::effective_dynamic_ir_inst($rail_name) ""
	    if {[array exists ::dn::ir_drop_fails]} {
		foreach instance [array names ::dn::ir_drop_fails] {
		    append ::effective_dynamic_ir_inst($rail_name) " $instance"
		}
	    }
	    puts "Failing PGV instances saved to \$::effective_dynamic_ir_inst($rail_name)"
	}
    }
    
    proc clear_highlight { } {
	gui_clear_highlight
    }

    proc clear_gui_texts { } {
	delete_obj [get_db current_design .gui_texts];     # Remove previous text objects
    }

   proc remove_gui_shapes { } {
	gui_delete_objs -shape; # Clear all lines
    } 

    proc remove_gui_highlights { } {
	gui_clear_highlight; #Clear all GUI text
    }

    proc remove_gui_texts { } {
	::dn::clear_gui_texts; # Clear all GUI text
    }

    proc show_instances_below_eiv { eiv } {
	gui_deselect -all
	puts "(started) Highlighting instances with effective voltage <= $eiv ..."
	foreach win_eiv [array names ::dn::ir_drop_histogram] { 
	    if { $win_eiv <= $eiv } {
		select_obj [get_cells $::dn::ir_drop_histogram($win_eiv)]
	    }
	}
	puts "(finished) Highlighting instances with effective voltage <= $eiv"
    }

    proc show_eiv_values_for_selected { } { 
	#puts "Showing Effective voltages for selected instances ..."
	set value_inst_pair ""
	set i 0
	foreach inst [get_db [get_db selected] .name] { 
	    if {[info exists ::dn::xref_insts_to_eiv($inst)]} {
		set eiv $::dn::xref_insts_to_eiv($inst); 
		lappend value_inst_pair "$eiv $inst"
	    } else {
		incr i
	    }
	}

	#if { $i } { puts "(W): No EIV value was found for $i instances" }

	foreach pair [lsort $value_inst_pair] {
	    set eiv  [lindex $pair 0]
	    set inst [lindex $pair 1]
	    set location  [get_db [get_db insts $inst] .location]
	    set base_cell [get_db [get_db insts $inst] .base_cell.name]
	    set format_line [format "%10s | %-20s | %-30s | %s" $eiv  $location  $base_cell  $inst]
	    puts $format_line
	}

    }

}
