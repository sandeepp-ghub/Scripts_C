define_proc_arguments create_straight_routes -info " draw straight routes" -define_args {
    { -nets_file          "nets_file" "" string optional }
    { -nets_list "net"       "" string optional }
}

proc create_straight_routes { args } {
    parse_proc_arguments -args $args opts

set nets ""
    if {[info exists opts(-nets_file)]} {
            set FH1 [open "$opts(-nets_file)" r]
            while {[gets $FH1 net] >= 0} {
                lappend nets $net
            }
            close $FH1
    } elseif {[info exists opts(-nets_list)]} {

         set nets $opts(-nets_list)
    }  else {
     puts "one of the Arguments is missing -nets_file/-nets_list"
     return   
    } 

        set nets_2term [get_db -unique nets $nets -if { .num_connections == 2 && ![llength .wires]}]

        if { ! [llength $nets_2term] } {
           puts "Nets have more than 2 terminals/pins or some nets are routed"
            return
        }

        

        set route_dict [dict create]

        set route_cnt 0
        foreach net_2term $nets_2term {
            set driver [lindex [get_db $net_2term .drivers] 0]
            set load [lindex [get_db $net_2term .loads] 0]
            #Check for layer alignment
            set driver_layer [get_db $driver .layer.name]
            set load_layer [get_db $load .layer.name]
            if { $driver_layer != $load_layer } {
                continue
            }
            set layer_is_vert [expr [lsearch [get_db [get_db layers -if {.type == "routing"}] .name] $driver_layer] % 2]
            set driver_loc {*}[get_db $driver .location]
            set load_loc {*}[get_db $load .location]
            if { ! (( $layer_is_vert && ([lindex $driver_loc 0] == [lindex $load_loc 0])) || \
                    (!$layer_is_vert && ([lindex $driver_loc 1] == [lindex $load_loc 1]))) } {
                continue
            }
            
            if { [lindex $driver_loc 0] == [lindex $load_loc 0] && \
                 [lindex $driver_loc 1] == [lindex $load_loc 1] } {
                continue
            }
            
            #Set axis coords for sorting
            if { [lindex $driver_loc 0] == [lindex $load_loc 0] } {
                set axis_ord [lindex $driver_loc 0]
            } elseif { [lindex $driver_loc 1] == [lindex $load_loc 1] } {
                set axis_ord [lindex $driver_loc 1]
            }
             
             set driver_width [get_db $driver .width]

            #Add route information to route dictionary
            #route_dict -> [list [dict net_name to_coord from_coord width] ]
            set route_list_per_layer [list]
            if { [dict exists $route_dict $driver_layer] } {
                set route_list_per_layer [dict get $route_dict $driver_layer]
            }
            set route_entry [dict create \
                net_name [get_db $net_2term .name] \
                to_coord $driver_loc \
                from_coord $load_loc \
                axis_ord $axis_ord \
                width $driver_width \
            ]
            lappend route_list_per_layer $route_entry
            dict set route_dict $driver_layer $route_list_per_layer

            incr route_cnt
#            if { ! [expr $route_cnt % 10000] } {
#                puts "Processing $route_cnt of [llength $nets_2term] nets ..."
#            }
        }


        #Setup command file
        set draw_wire_cmd_name "straightwire_commands.tcl"
        set pref [open "$draw_wire_cmd_name" w]
        puts $pref "set_db edit_wire_type regular"
        puts $pref "set_db edit_wire_drc_on {0}"
        puts $pref "set_db edit_wire_stop_at_drc {0}"
        puts $pref "set_db edit_wire_disable_snap {1}"
        puts $pref "set_db edit_wire_via_allow_geometry_drc {1}"

        puts $pref "set_db edit_wire_snap_bus_to_pin {0}"
        puts $pref "set_db edit_wire_snap_to_track_honor_color {0}"
        puts $pref "set_db edit_wire_snap_trim_metal_to_trim_grid {0}"
        puts $pref "set_db edit_wire_via_auto_snap {0}"
        puts $pref "set_db edit_wire_via_snap_honor_color {0}"
        puts $pref "set_db edit_wire_via_snap_to_intersection {0}"
        puts $pref "set_db edit_wire_create_crossover_vias {0}"
        puts $pref "set_db edit_wire_create_via_on_pin {0}"
        puts $pref "gui_set_tool addWire"

        puts "Adding edit_wire commands to $draw_wire_cmd_name"

        puts $pref ""

        #Write routes from route dict to route command file
        dict for {route_layer route_shape_list} $route_dict {

            set route_layer_is_vert [expr [lsearch [get_db [get_db layers -if {.type == "routing"}] .name] $route_layer] % 2]

            #Sort all potential net shapes by their extents then their axis ordinate to maximize grouping
            set route_shape_list_sorted [lsort -real -index [list 3 $route_layer_is_vert] \
                                            [lsort -real -index [list 5 $route_layer_is_vert] \
                                                [lsort -real -index {7} $route_shape_list] \
                                            ]
                                        ]

            puts "Adding [llength $route_shape_list_sorted] routes on layer $route_layer to $draw_wire_cmd_name ..."



            puts $pref ""
            if { $route_layer_is_vert } {
                puts $pref "set_db edit_wire_layer_vertical $route_layer"
            } else {
                puts $pref "set_db edit_wire_layer_horizontal $route_layer"
            }
            set prev_extents {}
            set prev_width 0
            set prev_axis_ord 0
            set prev_space 0
            set override_list {}
            set net_list {}
            set orig_from_coord {}
            set orig_to_coord {}

            #set route_shape_idx 0
            foreach route_shape_entry $route_shape_list_sorted {
                set net_name [dict get $route_shape_entry net_name]
                set to_coord [dict get $route_shape_entry to_coord]
                set from_coord [dict get $route_shape_entry from_coord]
                set axis_ord [dict get $route_shape_entry axis_ord]
                set width [dict get $route_shape_entry width]

                set extents [lsort -real [concat [lindex $to_coord $route_layer_is_vert] [lindex $from_coord $route_layer_is_vert]]]
                if { ![llength $override_list] || $extents == $prev_extents  && $width == $prev_width} {


                    lappend net_list $net_name
                    set override_len [llength $override_list]
                    set override_idx [expr $override_len + 1]

                    if { ![llength $override_list] } {
                        set orig_from_coord $from_coord
                        set orig_to_coord $to_coord
                    } else {
                        lset override_list [expr $override_len - 1] 2 {*}[convert_dbu_to_um \
                                                                            [expr \
                                                                                [convert_um_to_dbu $axis_ord]  - \
                                                                                [convert_um_to_dbu $prev_axis_ord] - \
                                                                                [convert_um_to_dbu $width] \
                                                                            ] \
                                                                        ]
                    }
                    lappend override_list [list $override_idx $width 0]

                } else {

                    puts $pref ""
                    puts $pref "set_db edit_wire_nets { $net_list }"
                    puts $pref "set_db edit_wire_wire_override_spec  { $override_list }"
                    puts $pref "edit_add_route_point $orig_from_coord"
                    puts $pref "edit_end_route_point $orig_to_coord"

                    set override_list [list [list 1 $width 0]]
                    set orig_from_coord $from_coord
                    set orig_to_coord $to_coord
                    set net_list [list $net_name ]
                }

                set prev_extents $extents
                set prev_width $width
                set prev_axis_ord $axis_ord
                #incr route_shape_idx
            }
            if { [llength $override_list] } {
                puts $pref ""
                puts $pref "set_db edit_wire_nets { $net_list }"
                puts $pref "set_db edit_wire_wire_override_spec  { $override_list }"
                puts $pref "edit_add_route_point $orig_from_coord"
                puts $pref "edit_end_route_point $orig_to_coord"

                set override_list {}
                set net_list {}
            }
        }

        puts $pref ""

            #This piece of garbage returns ''  .  Can't seem to work around it
            #"edit_wire_type"

        set attr_list [list \
            "edit_wire_drc_on" \
            "edit_wire_stop_at_drc" \
            "edit_wire_disable_snap" \
            "edit_wire_via_allow_geometry_drc" \
            "edit_wire_snap_bus_to_pin" \
            "edit_wire_snap_to_track_honor_color" \
            "edit_wire_snap_trim_metal_to_trim_grid" \
            "edit_wire_via_auto_snap" \
            "edit_wire_via_snap_honor_color" \
            "edit_wire_via_snap_to_intersection" \
            "edit_wire_create_crossover_vias" \
            "edit_wire_create_via_on_pin" \
        ]

        foreach attr_name $attr_list {
            set old_attr [get_db $attr_name]
            if { $old_attr != "" && [llength $old_attr] } {
                puts $pref "set_db $attr_name $old_attr"
            }
        }
        puts $pref "gui_set_tool select"

        close $pref
        set start_time [clock clicks -millisec]

#        puts "Routing $route_cnt routes ..."
#        set ew_log_fname "edit_wires.log"
#        if { [catch {redirect -append -stderr -file $ew_log_fname { source -e -v $draw_wire_cmd_name }}] } {
#            puts "There was an error in $draw_wire_cmd_name. Check $ew_log_fname"
#        }
#        set tot_time_ms [format "%0.1f" [expr {([clock clicks -millisec]-$start_time)}]]
#        set time_per_ms [format "%0.1f" [expr $tot_time_ms / double($route_cnt)]]
#        set tot_time_s [format "%0.1f" [expr $tot_time_ms / 1000.]]
#        puts "Drew $route_cnt routes in $tot_time_s s. $time_per_ms ms per route"
#


    }



