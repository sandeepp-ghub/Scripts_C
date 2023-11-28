#!/bin/tclsh

set input_file /proj/t106a0/wa_003/dnetrabile/impl/pem.PNR5/track.combined_0720/inp/pemm.def
set input_file /proj/t106a0/wa_003/dnetrabile/impl/pem.PNR5/track.combined_0720/inp/pemc.def

set input_id  [open "| gzip -cd $input_file" ]

set process_info 0
set START_PINS ""
set END_PINS ""
set concat_line ""

while {[gets $input_id line] >= 0 } {
    if {[string match "PINS" [lindex $line 0]]} { 
	set process_info 1 
	set START_PINS "$line"
    }
    if {[string match "END PINS" $line]} { 
	set process_info 0
    }

    if { $process_info } {
	if {[string match ""
	    set signal_line ""; set layer_line ""; set fixed_line ""; set concat_line "";	    
	    set signal_line "$line"
	} elseif {[string match "*LAYER*" $line]} {
	    set layer_line "$line"
	} elseif {[string match "*FIXED*" $line]} {
	    set fixed_line "$line"
	}

	if 
	
	    
	puts $line
	
    }



}

close $input_id
