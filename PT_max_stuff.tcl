set paths  [get_timing_paths -nworst 100 -slack_lesser_than -0.2 -max_paths 100000 -group IN ]
foreach_in_collection path $paths {
    set points [get_attr $path points]
    
    set max_tran_der 0
    set max_tans_cell ""
    foreach_in_collection point $points {
        set pin    [get_attr $point object  ]
        set cell   [get_cells -of_object $pin]
        set trans  [get_attr $pin transition]
        if {get_attr $pin "direction==in"}  { 
            set pin_in $pin; 
            set trans_in $trans
            set trans_out [get_attr [get_pins -of_object $cell -filter "direction==out"] transition]
            set cell_trans_der [expr {$trans_in*1/$trans_out}]
            if { $cell_trans_der > $max_trans_der } {
                set max_trans_cell $cell
                set max_trans_der  $cell_trans_der
            }

        }
   
     }
     append_to_collection -uniqe cell_col $max_trans_cell
}
