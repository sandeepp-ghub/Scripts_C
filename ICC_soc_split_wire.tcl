proc split_wire {net} {
    set suffix lior
     set driver       [get_cells -of_object [get_pins -of_object [get_nets $net -hier]  -filter "direction==out"]]
     set resivers     [get_cells -of_object [get_pins -of_object [get_nets $net -hier]  -filter "direction==in" ]]
     set resivers_pin [get_pins -of_object [get_nets $net -hier]  -filter "direction==in"]
     set all [get_cells -of_object [get_pins -of_object [get_nets $net -hier]  -filter "direction==in" ]] 
     set resivers_lib [get_attr $v_driver ref_name]
     set pin_x [get_attribute ${driver} bbox_llx]
     set pin_y [get_attribute ${driver} bbox_lly]
     create_cell [get_object_name $driver]_$suffix $ref_cell
	 move_objects -to "${pin_x} ${pin_y}" [get_cells [get_object_name $driver]_$suffix]
     set in_pins [get_pins -of_object $driver -filter "direction==in"]
     foreach p $in_pins {
        set pin_lib_name [get_attr $p pin_lib_name]
        connect 
     }

}
