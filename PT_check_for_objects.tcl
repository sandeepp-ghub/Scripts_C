
#Warning: No net objects matched 'qlm6/rphy/refres_i' (SEL-004)                   
#Warning: No pin objects matched 'qlm6/rphy/apb_wr_bit_en_i[*]' (SEL-004)     

set fin [open max1.log r]

while {[gets $fin line] >= 0} {
  if {[regexp {Warning: No (\S+) objects matched '(\S+)' \(SEL-004\)} $line match type name]} {
	if {$type == "pin"} {
	  set p [get_pins -quiet -hier */[lindex [file split $name] end]]
	  if {[sizeof_collection $p] > 0} {
		puts "$type $name is really: [get_object_name [index_collection $p 0]]"
	  } else {
		#puts "$type XX $name"
	  }
	} elseif {$type == "net"} {
	  set n [get_nets -quiet -hier [lindex [file split $name] end]]
	  if {[sizeof_collection $n] > 0} {
		puts "$type $name is really: [get_object_name [index_collection $n 0]]"
	  } else {
		#puts "$type XX $name"
	  }
	} elseif {$type == "port"} {
	  set p [get_ports -quiet $name]
	  if {[sizeof_collection $p] > 0} {
		puts "$type $name is really: [get_object_name [index_collection $p 0]]"
	  } else {
		#puts "$type XX $name"
	  }
	} else {
	  #puts "SKIPPING $type $name"
	}
  }
}

close $fin
