set fin [open cp_rcplx r]
while {[gets $fin line] >= 0} {
	#if {[regexp {^\s*(\S+)\s+\(\S+\)\s+user-defined\s+(\S+)} $line match pin case]} 
	if {[regexp {^\s*(\S+)\s+\(\S+\)\s+} $line match pin]} {
		set net [get_nets -top -seg -of [get_pins $pin]]
		set drivers [get_pins -quiet -leaf -of $net -filter "direction==out"]
		if {[sizeof_collection $drivers] == 0} {
			puts "NO DRIVER: [get_object_name $net]"
		}
	}
}
close $fin
