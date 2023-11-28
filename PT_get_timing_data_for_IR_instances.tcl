

#set instance_file /user/dnetrabile/instances_pgv

proc get_timing_info_for_pgv_instances { instance_file } {
    set input_id [open $instance_file r]

    if { ![file exists $instance_file] } {
	puts "(E): Specified instance file doesn't exist: $instance_file"
    } else {
	set cells ""
	array unset xref_cell_to_eiv
	
	while {[gets $input_id line] >= 0 } {
	    set split_line [split $line "|"]
	    set eiv  [lindex $split_line 0]
	    set location [lindex $split_line 1]
	    set ref_name [lindex $split_line 2]
	    set cell [lindex $split_line end]
	    set xref_cell_to_eiv($cell) $eiv
	    lappend cells $cell
	}
	
	set i 0; 

	set format_line [format "%5s | %10s | %10s | %20s %s | %s --> %s" "#Index" "Slack" "EIV" "Refname" "Cell" "Startpoint" "Endpoint"]; puts $format_line 
	foreach cell $cells { 
	    incr i; 
	    puts $cell
	    set ref_name [get_attribute [get_cells $cell] ref_name]
	    set tp [get_timing_path -through $cell -slack_lesser_than inf ];  
	    set slack [get_attribute $tp slack]; 
	    set sp [get_object [get_attribute $tp startpoint]]; 
	    set ep [get_object [get_attribute $tp endpoint]]; 
	    set eiv $xref_cell_to_eiv($cell)
	    set format_line [format "%5s | %10s | %10s | %20s  %s | %s --> %s" $i $slack $eiv $ref_name $cell $sp $ep]; puts $format_line 
	}
	close $input_id 
    }
}

puts "Loading procedure: 'get_timing_info_for_pgv_instances <eiv_instance_file_from_INV>'"
