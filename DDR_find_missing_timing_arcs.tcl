return

show_lib_arcs  -of_objects [get_lib_cells dwc_ddrphydbyte_top_ew_ssgnp0p675vn40c_cbest_CCbest/dwc_ddrphydbyte_top_ew]

    proc show_lib_arcs {args} {
           set hot [list ]
           set lib_arcs [eval [concat get_lib_timing_arcs $args]]
           echo [format "%15s    %-15s  %18s" "from_lib_pin" "to_lib_pin" \
                     "sense"]
           echo [format "%15s    %-15s  %18s" "------------" "----------" \
                     "-----"]

           foreach_in_collection lib_arc $lib_arcs {
             set fpin [get_attribute $lib_arc from_lib_pin]
             set tpin [get_attribute $lib_arc to_lib_pin]
             set sense [get_attribute $lib_arc sense]
             set from_lib_pin_name [get_attribute $fpin base_name]
             set to_lib_pin_name [get_attribute $tpin base_name]
             echo [format "%15s -> %-15s  %18s" \
                 $from_lib_pin_name $to_lib_pin_name \
                 $sense]
            lappend  hot $from_lib_pin_name
            lappend  hot $to_lib_pin_name
           }
        return $hot
    }

set hot [show_lib_arcs  -of_objects [get_lib_cells dwc_ddrphydbyte_top_ew_ssgnp0p675vn40c_cbest_CCbest/dwc_ddrphydbyte_top_ew]]
set all_pins [get_attr [get_lib_pins  dwc_ddrphydbyte_top_ew_ssgnp0p675vn40c_cbest_CCbest/dwc_ddrphydbyte_top_ew/*] base_name]
foreach p $all_pins {if {$p in $hot} {continue} else {puts $p}}                                                                                                                  
