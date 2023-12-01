#highlightingWorstIDpaths -skew_group <skewGroupName> -number_of_paths <value>

proc highlightingWorstIDpaths {args} {
    parse_proc_arguments -args $args opt
    set sg $opt(-skew_group)
    set count $opt(-number_of_paths)
    
    set list_sink_id ""
    foreach sink [get_db skew_group:$sg .sinks_active.name] {
        lappend list_sink_id "$sink [get_skew_group_delay -to $sink -skew_group $sg]"
    }
    
    set i 0
    set  worstSinks ""
    foreach data [lsort -index 1  -decreasing $list_sink_id] {
        incr i
        lappend worstSinks [lindex $data 0 ]
        if {$i > $count} {break}
    }

    set i 0
    gui_ctd_open -title highlightingTopWorstClockPaths
    foreach sink $worstSinks {
        incr i
        gui_deselect -all
        select_obj [lindex [get_skew_group_path -skew_group $sg -sink $sink] 0]
        if { [lsort -unique [get_db selected .obj_type]] == "pin" } { 
            gui_ctd_highlight -to [get_db pin:$sink .inst.name] -from [get_db pin:[lindex [get_skew_group_path -skew_group $sg -sink $sink] 0] .inst.name] -index $i
            if { $i == 32 } {
                set i 0
            }
        } else {
            gui_ctd_highlight -to [get_db pin:$sink .inst.name] -from [lindex [get_skew_group_path -skew_group $sg -sink $sink] 0] -index $i
            if { $i == 32 } {
                set i 0
            }
        }
    }
}

define_proc_arguments highlightingWorstIDpaths -info "highlight the top worst clock ID paths of a specified skew group"\
-define_args {
    {-skew_group "specify the name of the skew_group" "" string required}
    {-number_of_paths "specifies the number of worst paths which user wants to highlight" "" integer required}
}

