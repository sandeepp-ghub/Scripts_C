proc swap_del_cells_from_setup_paths {group} {
    set tps [get_timing_path -group $group -max_path 5000] 
    foreach_in_collection tp $tps {
        set points [get_attr $tp    points]
        set obj   [get_attr $points object]
        set cells [get_cells -of $obj]
        foreach_in_collection c $cells {
            set cn  [get_object_name $c  ]
            set ref [get_attr $c ref_name]
            echo "$cn $ref" 
        }

    }
}
