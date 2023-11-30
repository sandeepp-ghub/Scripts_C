proc report_connection_to_io_buf { } {
    set nc 0 ;# not connected to cell
    set nb 0 ;# not io buffer
    set ib 0 ;# is io buffer
    set ports [get_ports *]
    set tot   [sizeof_collection $ports]
    foreach_in_collection p [get_ports *] { 
        set iobuf     [get_cells -of_object [filter_collection [all_connected $p -leaf] object_class==pin]]
        set iobufNmae [get_object_name $iobuf]
        if {[sizeof_collection $iobuf] == 0 } {
            lappend notConnectedToCell $iobufName
            incr nc
        } else {
            if {[regexp {kw28_alpha_macro_io_buf/.*buffer} $iobufName]} {
                lappend isIobuf $iobufName
                incr ib
            } else {
                lappend notIobuf $iobufName
                incr nb 
            }
        }
    }
close LOG
return ""
}
