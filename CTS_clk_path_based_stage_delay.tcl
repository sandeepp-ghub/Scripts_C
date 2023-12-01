proc stageDelaywithCellList {args} {
    parse_proc_arguments -args $args opt
    set skew_group $opt(-skew_group)
    set sink $opt(-sink)
    
    puts "ClockPort/Pin Net CellType ArrivalTime Delay WireLength\n"
    
    set root [lindex [get_skew_group_path  -skew_group $skew_group -sink $sink ] 0]
    set root_delay [get_skew_group_delay -skew_group $skew_group -to $root]
    puts "$root NA $root_delay $root_delay"
    set prev_delay $root_delay
    
    foreach i [get_skew_group_path  -skew_group $skew_group -sink $sink ] {
        gui_deselect -all
        select_obj $i
        if { [get_db selected .obj_type] == "pin" } { 
            set delay [get_skew_group_delay -skew_group $skew_group -to $i]
            puts "$i [get_db pin:$i .inst.base_cell.base_name] [get_skew_group_delay -skew_group $skew_group -to $i] [expr $delay - $prev_delay]"
            set prev_delay [expr $delay + $root_delay]
        } 
    }
}

define_proc_arguments stageDelaywithCellList -info "find out the stage wise delay alongwith the cell list for a timing path"\
-define_args {
    {-skew_group "specify the skew_group name" "" string required}
    {-sink "specify the sink name"  "" string required}
}


