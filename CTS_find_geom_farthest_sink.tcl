proc findingFarthestSink {args} {
	parse_proc_arguments -args $args opt
	set clock_tree_name $opt(-in_clock_tree)
	set root $opt(-root)
	set skew_group $opt(-skew_group)
	
	set sink_list ""
 	select_obj $root
	if { [lsort -unique [get_db selected .obj_type]] == "pin" } {
		set root_x [get_db pin:$root .location.x]
		set root_y [get_db pin:$root .location.y]
	} else {
		set root_x [get_db port:$root .location.x]
		set root_y [get_db port:$root .location.y]
	}
 	gui_deselect -all
	foreach i [get_clock_tree_sinks -in_clock_trees $clock_tree_name] {
		select_obj $i
		if { [lsort -unique [get_db selected .obj_type]] == "pin" } {
			set x [expr abs([expr [get_db pin:$i .location.x] - $root_x])]
			set y [expr abs([expr [get_db pin:$i .location.y] - $root_y])]
			lappend sink_list "$i [expr $x + $y]"
		} else {
			set x [expr abs([expr [get_db pin:$i .location.x] - $root_x])]
			set y [expr abs([expr [get_db pin:$i .location.y] - $root_y])]
			lappend sink_list "$i [expr $x + $y]"
		}
	}
	puts "[lindex [lsort -index 1 -real -decreasing $sink_list] 0]"
    gui_deselect -al
    set_layer_preference node_layer -is_visible 0
    set_layer_preference flightLine -is_visible 0
    gui_clear_highlight
    gui_ctd_open -title HighlightFarthestSink
    gui_ctd_highlight -from [lindex [get_skew_group_path -skew_group $skew_group -sink [lindex [lindex [lsort -index 1 -real -decreasing $sink_list] 0] 0] ] 0] -to [lindex [lindex [lsort -index 1 -real -decreasing $sink_list] 0] 0] -color red
    gui_deselect -all
}

define_proc_arguments findingFarthestSink -info "find out the max sink by calculating its manhattan distance"\
-define_args {
    {-in_clock_tree "specify the clock tree name" "" string required}
    {-root "specify the root name" "" string required}
    {-skew_group "specify the skew group name" "" string required}
}

