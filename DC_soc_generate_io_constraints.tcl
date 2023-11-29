#Usage: soc_generate_io_constraints    # generate constraints file for IO
#        [-input_delay ]        (input delay [%] (default 0.5))
#        [-output_delay ]       (output delay [%] (default 0.5))
#        [-debug]               (debug mode)

proc soc_generate_io_constraints {args} {

    set start_time [date]

    #-- Parse command line
    set results(-input_delay) {0.5}
    set results(-output_delay) {0.5}
    set results(-debug) {false}
    #-- parse command line arguments
    parse_proc_arguments -args $args results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }

    set OUTPUT_FILE io_const_file.tcl
    sh touch io_const_file.tcl

    #-- INPUTS --#
    foreach_in_collection input_port [all_inputs] {
        set primary_related_clock ""
        set input_port_name [get_object_name $input_port]
        set fanout_arr [all_fanout -endpoints_only -flat -from $input_port]
        if {$i_debug != "false"} {puts "\[DEBUG\] input_port_name = input_port_name"}
        foreach_in_collection endpoint $fanout_arr {
            set clock_pin [get_pins -of_objects [get_cells -of_objects $endpoint] -filter "is_on_clock_network == true && direction == in"]
            if {$i_debug != "false"} {puts "\[DEBUG\] clock_pin = [get_object_name $clock_pin]"}
            #-- check that all fanout pins get the same clock - if not issue an error
            set arrival_window [get_attr $clock_pin arrival_window]
#           if {$i_debug != "false"} {puts "\[DEBUG\] arrival_window = $arrival_window"}
#           {{{cdr_clk_out} pos_edge {min_r_f 0.480907   uninit} {max_r_f 0.567091   uninit}} {{cdr_clk_out} neg_edge {min_r_f   uninit 0.504195} {max_r_f   uninit 0.589930}}}
            regexp {^\{\{\{(\w+)\}.*} $arrival_window -> related_clock
            puts $related_clock
#           if {$i_debug != "false"} {puts "\[DEBUG\] related_clock = $related_clock"}
            if {$primary_related_clock == ""} {
                set primary_related_clock $related_clock
            }
            if {$primary_related_clock != $related_clock} {
                puts "Error - port $input_port_name has more than one related clocks ($primary_related_clock, $related_clock)!!!"
            }
        }
        set clock_period [get_attr $related_clock period]
        set const "set_input_delay \[expr $i_input_delay * $clock_period\] -clock $related_clock $input_port_name "
        if {$i_debug != "false"} {puts "\[DEBUG\] const = $const"}
        if {$i_debug == "false"} {
            redirect -append $OUTPUT_FILE {puts $const}
        }

    }
    

    #-- OUTPUTS --#
    foreach_in_collection output_port [get_port * -filter "direction == out && name !~ *clk*"] {
        set is_tied 0
        set primary_related_clock ""
        set output_port_name [get_object_name $output_port]
        set fanin_arr [all_fanin -startpoints_only -flat -to $output_port]
        if {$i_debug != "false"} {puts "\[DEBUG\] output_port_name = $output_port_name"}
        if {[llength $fanin_arr] == 1} {
            if [regexp {TIE} [get_attr $fanin_arr name]] {
                puts "\[WARNING\] $output_port_name is tied"
                set is_tied 1
            }
        }
        if {$is_tied == 0} {
            if {$i_debug != "false"} {puts "\[DEBUG\] ENTERING .... "}
            foreach_in_collection startpoint $fanin_arr {
                set clock_pin [get_pins -of_objects [get_cells -of_objects $startpoint] -filter "is_on_clock_network == true && direction == in"]
                if {$i_debug != "false"} {puts "\[DEBUG\] clock_pin = [get_object_name $clock_pin]"}
                #-- check that all fanout pins get the same clock - if not issue an error
                set arrival_window [get_attr $clock_pin arrival_window]
                if {$i_debug != "false"} {puts "\[DEBUG\] arrival_window = $arrival_window"}
#               {{{cdr_clk_out} pos_edge {min_r_f 0.480907   uninit} {max_r_f 0.567091   uninit}} {{cdr_clk_out} neg_edge {min_r_f   uninit 0.504195} {max_r_f   uninit 0.589930}}}
                regexp {^\{\{\{(\w+)\}.*} $arrival_window -> related_clock
                if {$i_debug != "false"} {puts "\[DEBUG\] related_clock = $related_clock"}
                if {$primary_related_clock == ""} {
                    set primary_related_clock $related_clock
                }
                if {$primary_related_clock != $related_clock} {
                    puts "Error - port $output_port_name has more than one related clocks ($primary_related_clock, $related_clock)!!!"
                }
            }
            set clock_period [get_attr $related_clock period]
            set const "set_output_delay \[expr $i_output_delay * $clock_period\] -clock $related_clock $output_port_name "
            if {$i_debug != "false"} {puts "\[DEBUG\] const = $const"}
            if {$i_debug == "false"} {
                redirect -append $OUTPUT_FILE {puts $const}
            }
        }
    }
    #if {$i_debug != "false"} {puts "\[DEBUG\] llength of index_1 = [llength $index_1]"}
}

define_proc_attributes soc_generate_io_constraints \
    -info "generate constraints file for IO" \
    -define_args {
        {-input_delay  "input delay \[%\] (default 0.5)"    "" float   optional}
        {-output_delay "output delay \[%\] (default 0.5)"   "" float   optional}
        {-debug        "debug mode"                         "" boolean optional}

}

