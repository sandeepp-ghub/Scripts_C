set obj_with_violations ""
foreach mrkr [get_db markers -if {.user_type == MRVL_FLT_METAL }] {
    set mrkr_bbox [get_db $mrkr .bbox]
    set obj_under_mrkr [get_obj_in_area -areas $mrkr_bbox -obj_type via]
    set obj_via [get_db $obj_under_mrkr -if {.net.name == CTS* }]
    set obj_under_mrkr [get_obj_in_area -areas $mrkr_bbox -obj_type wire ]

    set obj_wire [get_db $obj_under_mrkr -if {.net.name == CTS* && .layer.name == M3 && .width == 0.02  && .rect.length == 0.041 }]
    set obj_wire2 [get_db $obj_under_mrkr -if {.net.name == CTS* && .layer.name == M3 && .width == 0.02  && .rect.length == 0.063 }]

    if {[llength $obj_via] } {
    lappend obj_with_violations  {*}$obj_via  
    }
    if {[llength $obj_wire] } {
    lappend obj_with_violations  $obj_wire  
    }
     if {[llength $obj_wire2] } {
    lappend obj_with_violations  $obj_wire2  
    }


}    


select_obj $obj_with_violations

