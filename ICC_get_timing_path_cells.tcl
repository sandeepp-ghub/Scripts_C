
    set paths [get_timing_path -from top/quad_dp/ecc_flip_s1_ff/q_reg_29_/CP]
    foreach_in_collection path $paths {
        puts "--------------new path --------------------"
        foreach_in_collection point [get_att $path  points] {
            set path_pins [filter_collection [ get_attribute $point object ] "object_class != port"]
            set logic_cells [filter_collection [get_cells -of_object $path_pins] "is_combinational != false" ]
            set pin_name [ get_attribute $path_pins full_name ] ; # the object of point is a pin or port and have his attr
# set arrival  [get_attribute $point arrival ] ; # timing_point class have attr dis at -> man get_timing_path
#           puts $pin_name
           
        }
    }
