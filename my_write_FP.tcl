proc my_write_floorplan {outFile} {
    deselect_obj -all
    select_obj [get_db insts -if {.is_macro}]
    select_obj [get_db insts -if {.is_black_box==true&&.name!=*ENDCAP*&&.name!=*WELLTAP*&&.name==*CAP*}]
#select_obj [get_db insts -if {.is_memory}]
    select_obj [get_db ports]
    select_obj [get_db place_blockages *LIORAL*]
    eval write_def  -selected ${outFile}.def
    deselect_obj -all
#    select_obj [get_db insts -if {.is_memory}]
    select_obj [get_db insts -if {.is_black_box==true&&.name!=*ENDCAP*&&.name!=*WELLTAP*&&.name==*CAP*}]
    select_obj [get_db insts -if {.is_macro}]
    
    select_obj [get_db place_blockages *LIORAL*]
    select_obj [get_db route_blockages *LIORAL*]
    eval write_floorplan_script -selected  ${outFile}.tcl
}
