proc soc_get_driver_recivers_clock_split_point {} {

    set paths                [get_timing_paths  -group c2c_clk -max_p 1 -path_type full_clock_ex]
    set drive_clock_path     [get_attr $paths     launch_clock_paths]
    set recivers_clock_paths [get_attr $paths capture_clock_paths]
    set dp                   [get_attr [get_attr $drive_clock_path points] object]
    set db_size              [sizeof_collection $dp]

    foreach_in_collection recivers_clock_path $recivers_clock_paths {
        set rp  [get_attr [get_attr $recivers_clock_path points] object]
        for {set i 0} {$i<$db_size} {incr i} {
            if {[ compare_collections [index_collection $dp $i] [index_collection $rp $i]] ==0} {
                echo "Info: same point [get_object_name [index_collection $dp $i]]"
            } else {
              echo "Info: this is the point [get_object_name [index_collection $dp $i]]"  
            }
        }
    }

}



proc
