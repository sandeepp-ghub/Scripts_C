proc soc_change_vertical_port_width {args} {
    parse_proc_arguments -args ${args} results
    foreach_in_collection port $results(-ports_col) {
        set terminal         [get_terminal -of_object $port]
        set location_x       [get_attr $terminal bbox_llx]
        set location_y       [get_attr $terminal bbox_lly ]
        set location_dx      [get_attr $terminal bbox_urx]
        set location_dy      [get_attr $terminal bbox_ury]
        set y_current_delta  [expr {abs($location_dy -$location_y)}]
#        puts "cuur delta $y_current_delta"
        set yprefix          [expr {($results(-ports_new_width) - $y_current_delta)*0.5*(-1)}]
#        puts "yprefix $yprefix"
        set ypostfix         [expr {($results(-ports_new_width) - $y_current_delta)*0.5}     ]
#        puts "ypostfix $ypostfix"
        set new_location_y   [expr {$location_y +  $yprefix}]
        set new_location_dy  [expr {$location_dy + $ypostfix}]
#puts "                                  \{$location_x $location_y $location_dx $location_dy\}"
        puts "executing... resize_objects -bbox \{$location_x $new_location_y $location_dx $new_location_dy\} -no_snap [get_object_name $terminal]"
        set xy [list $location_x $new_location_y $location_dx $new_location_dy]
        resize_objects -bbox  $xy -no_snap [get_object_name $terminal]


    }
}

#---------------------define proc attributes----------------------
define_proc_attributes soc_change_vertical_port_width \
    -info "set a new width to port" \
    -define_args {

{-ports_col        "ports collection"  "" list required}
{-ports_new_width  "second addend arg" "" string required}
}



