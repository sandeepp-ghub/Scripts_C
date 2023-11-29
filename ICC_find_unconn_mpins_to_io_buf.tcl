proc find_unconnected_ports_to_io_buf { } { 
    set i 0;
    set ports [get_ports *]
    foreach_in_collection port $ports {
        set net [get_net -of_object $port]
#        puts [get_object_name $net]
        set iobuf [get_cell -of_object $net]
        if { $iobuf == "" } {
            puts [get_object_name $port];
            incr i;
        }
#puts [get_object_name $iobuf] 
    }
    puts "you have $i unconnected ports in the design"
}
