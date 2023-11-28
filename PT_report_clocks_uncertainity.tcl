proc report_clocks_uncertainty {} {
    global run_type_specific
    if {[regexp {max} $run_type_specific]} {
        set type "max"
    } else {
        set type "min"
    }

    foreach_in_collection clock1 [all_clocks] {
        foreach_in_collection clock2 [all_clocks] {
            set clock1_name [get_object_name $clock1]
            set clock2_name [get_object_name $clock2]
            set path [get_timing_path -delay $type -from [get_clocks $clock1] -to [get_clocks $clock2] -slack_less 10000]
            if { [sizeof_collection $path] == 0 } {
                # no paths between these clocks
                set path_clock_uncertainty "N/A"
            } elseif { [get_attr $path slack] eq "INFINITY" } {
                # There is a false path for this clock crossing
                set path_clock_uncertainty "N/A"
            } else {
                set path_clock_uncertainty [get_attr -quiet $path clock_uncertainty]
            }

            if { $path_clock_uncertainty eq {} } { 
                puts [format "ERROR: No hold clock uncertainty for transfers between %25s %25s" "$clock1_name" "$clock2_name"]
            } else {
                if {$path_clock_uncertainty ne "N/A"} {
                    puts [format "%-25s , %-25s , %-2.3f" "$clock1_name" "$clock2_name" "$path_clock_uncertainty" ]
                }
            }
        }
    }
}

