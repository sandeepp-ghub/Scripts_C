#!/bin/tclsh

set input_file [lindex $argv 0]
set input_id   [open $input_file r]

set line_counter 0
set path_counter 0
set record_counter 0
set data_path_start 0
while {[gets $input_id line] >= 0 } {
    puts $line
    incr line_counter
    if {[string match "*Startpoint:*" $line]} {
	incr path_counter 
	set record_counter 1
    }
    if {[string match "---------------------------------------*" $line]} {
	set data_path_start 1
    }

    if { $data_path_start } {
	if {![string match 

}


close $input_id
