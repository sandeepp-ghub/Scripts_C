proc find_clock_ports_tap {} { 
    set cname [get_db clocks .base_name -unique]
	foreach cn $cname {
	#    puts ""
	#    puts $cn
	    set srcs [get_db [lindex [get_db clocks *$cn] 0] .sources]
	#    puts $srcs
	    if {[get_db [get_db [lindex [get_db clocks *$cn] 0] .is_generated]]} {puts "$cn, gen_clock..."; continue}
	    if {[regexp {pin\:} [get_db [lindex [get_db clocks *$cn] 0] .sources]]  } {puts "$cn, internal clock..."; continue}
	    foreach src $srcs {
	       set inst [get_db [get_db [get_db $src .net] .load_pins] .inst.name]
	       puts "$cn,$src,$inst"
	    }
	
	}
}
