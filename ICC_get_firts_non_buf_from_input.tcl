proc get_firts_non_buf_from_input {input} {
    set i 0;
    set input [get_ports -of $input]
    set pin_col_size 1
    while {$i <100 } {
        set net [get_nets -of $input]
        set pins [get_pins -of $net -leaf]
        if {[sizeof_collection $pins] > 2} {   
            echo "Info: splite point [get_object_name $input]"
            zoom -pin_col $input
#            return $input
        }
        set inpin [get_pins -of $net -leaf -filter "direction==in"]
        set cell [get_cells -of $inpin]
        set cellpins [get_pins -of $cell]
        if {[sizeof_collection $cellpins] > 2} {   
            echo "Info: splite cell [get_object_name $cell]"
            zoom -cell_col $cell
            return $cell
        }
        set input [get_pins -of $cell -filter "direction==out"]
      incr i;
      echo $i;
    }




}
