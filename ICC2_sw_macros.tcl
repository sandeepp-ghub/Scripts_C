proc sw_macros {} {
    set macros [filter_collection [get_selection ] "design_type==macro"]
    if {[sizeof_collection $macros] ne "2"} {echo  "Error: need to select two macros only ..."; return}
    set_fixed_objects $macros -unfix
    set macro1 [index_collection $macros 0]
    set bbox [get_attr $macro1 bbox]
    set macro1_x [lindex [lindex $bbox 0] 0]
    set macro1_y [lindex [lindex $bbox 0] 1]
    set macro1_o [get_attr $macro1 orientation]
    set macro2 [index_collection $macros 1]
    set bbox [get_attr $macro2 bbox]
    set macro2_x [lindex [lindex $bbox 0] 0]
    set macro2_y [lindex [lindex $bbox 0] 1]
    set macro2_o [get_attr $macro2 orientation]

#    move objects
    move_objects $macro1 -x $macro2_x -y $macro2_y -rotate_by $macro2_o
    move_objects $macro2 -x $macro1_x -y $macro1_y -rotate_by $macro1_o


}
