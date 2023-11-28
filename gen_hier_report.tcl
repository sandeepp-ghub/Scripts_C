#!/usr/local/bin/tclsh

#set input_file [lindex $argv 0]

proc generate_cell_hierarchy_report { instance } {
    #current_instance
    #current_instance $instance
    current_design
    puts "Generating cell-hierarchy for '$instance'"

    set all_cells [get_cells * -hierarchical]

    puts "Size: [sizeof_collection $all_cells]"

    set i 0
    foreach_in_collection cell_name $all_cells {
	set parent_cell_attribute [get_attribute -quiet $cell_name parent_cell]
	
	if { $i < 10 } { puts "[get_object $cell_name] ==> $parent_cell_attribute" }

	if { $parent_cell_attribute != "" } {
	    set parent_cell [get_object $parent_cell_attribute]
	    
	    set PARENT_CELLS($parent_cell) ""
	}
	incr i
    }
	
    puts [array size PARENT_CELLS]
    set output_file "$::DIR/parent_cells.txt"
    set ofid [open $output_file w]
    set previous_level "1"
    foreach cell [lsort [array names PARENT_CELLS]] {
	set split_cells [split $cell "/"]
	set level [format %3s [llength $split_cells]]
	if { $level < $previous_level } {
	    puts $ofid "#--------------------------------------------------------------"
	    puts $ofid "$level : $cell (NEW_GROUP)"
	} else {
	    puts $ofid "$level : $cell"
	}

	set previous_level "$level"
    }
    close $ofid
    puts "Wrote output_file to: $output_file"
    #parray PARENT_CELLS
}

puts "Loading proc: 'generate_cell_hierarchy_report <current_instance>'"
# End proc generate_hierarchy_report { fname }

# Show fanout from this point:
#set pin_name "gserj0/dlm_pnr/scan_clk_gen_noscan/ln0_txclk_mux_inst_noscan/hand_clk_mux0/flag_buf_0/Y"
#set all_fanout [get_pins [all_fanout -from $pin_name] -flat ]


proc generate_fanout_hierarchy_report { pin_name } {
    array unset PARENT_CELLS
    puts "Generating fanout-hierarchy for '$pin_name'"

    set all_fanout [get_pins [all_fanout -from [get_pins $pin_name] -flat -endpoints_only]]
    set all_cells [get_cells -of [get_pins $all_fanout]]

    foreach_in_collection cell_name $all_cells {
	set parent_cell_attribute [get_attribute -quiet $cell_name parent_cell]
	
	if { $parent_cell_attribute != "" } {
	    set parent_cell [get_object $parent_cell_attribute]
	    
	    set PARENT_CELLS($parent_cell) ""
	}
    }
	
    array size PARENT_CELLS
    set output_file "$::DIR/fanout_hierarchy_report.txt"
    set ofid [open $output_file w]
    puts $ofid "# Fanout report for '[get_object [get_pins $pin_name]]':"
    puts $ofid ""
    set previous_level "1"
    set previous_cell ""
    foreach cell [lsort [array names PARENT_CELLS]] {
	set split_cells [split $cell "/"]
	set level [format %3s [llength $split_cells]]
	set parent_cell [lrange $split_cells 0 end-1]

	# Split the previous cell
	set split_cells_previous [split $previous_cell "/"]
	set parent_cell_previous [lrange $split_cells_previous 0 end-1]

	if { ($level < $previous_level) || ($parent_cell_previous != $parent_cell)  } {
	    puts $ofid "#--------------------------------------------------------------"
	    puts $ofid "$level : $cell (NEW_GROUP)"
	} else {
	    puts $ofid "$level : $cell"
	}

	set previous_level "$level"
	set previous_cell  "$cell"
    }
    close $ofid
    puts "Wrote output_file to: $output_file"
    #parray PARENT_CELLS
}

puts "Loading proc: 'generate_fanout_hierarchy_report <pin_name>'"

if {![info exists ::DIR]} {
    set ::DIR [pwd]
}

