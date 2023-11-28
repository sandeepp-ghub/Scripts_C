proc bind_key {} {
gui_bind_key c -cmd "fp_swap_box"
gui_bind_key s -cmd "align_selected -side bottom"
gui_bind_key a -cmd "align_selected -side left"
gui_bind_key d -cmd "align_selected -side right"
gui_bind_key w -cmd "align_selected -side top"


gui_bind_key Shift-d -cmd  "space_selected -fix_side left   -space 10"
gui_bind_key Shift-a -cmd  "space_selected -fix_side right  -space 10"
gui_bind_key Shift-w -cmd  "space_selected -fix_side bottom -space 6.44"
gui_bind_key Shift-s -cmd  "space_selected -fix_side top    -space 6.44"
gui_bind_key f       -cmd "flip_or_rotate_obj -flip MY -group"
gui_bind_key g       -cmd "flip_or_rotate_obj -flip MY -group"
gui_bind_key Shift-g -cmd "flip_or_rotate_obj -flip MX -group"
gui_bind_key p       -cmd "my_write_floorplan"
}

#"shift_selected -direction down -to core_box -group"
proc fp_swap_box {} {
    set box [get_db selected]
    if {[llength [get_db selected ]] ne 2 } {
        puts "Error: number of inst must be 2 for fp_swap_box to work."
        return 0
    }
    set box0 [lindex $box 0]
    set box1 [lindex $box 1]

    set box0_l  [get_db ${box0} .location]
    set box1_l  [get_db ${box1} .location]

    set box0_o  [get_db ${box0} .orient]
    set box1_o  [get_db ${box1} .orient]

    move_obj ${box0} -point ${box1_l}
    move_obj ${box1} -point ${box0_l}

    set_db ${box0} .orient ${box1_o}
    set_db ${box1} .orient ${box0_o}

}

proc my_write_floorplan {} {
    deselect_obj -all    
    select_obj [get_db place_blockages *LIORAL*]
    select_obj [get_db route_blockages *LIORAL*]
    eval write_floorplan_script -selected  ../config/after_::inv::floorplan::convert_inst_route_blockage_to_reg_blockage.tcl

    deselect_obj -all
    select_obj [get_db insts -if {.is_macro}]
    set_db [get_db selected] .place_status fixed
    select_obj [get_db place_blockages *LIORAL*]
    select_obj [get_db route_blockages *LIORAL*]
    if {[file exists ../script/floorplan/rams.place.tcl]} {
        exec mv ../script/floorplan/rams.place.tcl ../script/floorplan/rams.place_old.tcl
        puts "Moving ../script/floorplan/rams.place.tcl _TO_ ../script/floorplan/rams.place_old.tcl"
    }
    eval write_floorplan_script -selected  ../script/floorplan/rams.place.tcl
}
