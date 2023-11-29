set path [get_timing_path -from $input -max_path 1]



set points [get_attr $path points]
foreach_in_collection point $points  {
    set pin  [get_attr $point object]
    if {[get_attr $point object_class] == "port"} {continue}
    if {[get_attr $pin pin_direction ] == "in"} {
        set cell      [get_cells -of $pin]
        set cell_pins [get_pins -of $cell]
        set pinsnum   [sizeof_collection $cell_pins]
        echo [get_object_name $pin]
        if {$pinsnum > 2} { echo "LAST CELL IS SPLITE POINT"}
    }
}

