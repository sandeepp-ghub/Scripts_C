proc find_unconnected_ports { } { 
    set i 0;
    set ports [get_ports *]
    foreach_in_collection port $ports {
        set net [get_net -of_object $port]
        set iobuf [get_cell -of_object $net]
        if { $iobuf == "" } {
            puts [get_object_name $port];
            incr i;
        }
    }
    puts "there are $i unconnected ports in the design"
}
