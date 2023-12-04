dehighlight -all
set allBus [lsort -uniq [dbget top.terms.bus.baseName  -e]]
set i 1
set c 1
set fp [open port_macro_connection.rpt w]
puts $fp "This report will contain port-->macro connection upto 3 level"
puts $fp ""
source /mrvl/cavmhomes/bsekar/scripts/mem/fanin_trace.tcl
source /mrvl/cavmhomes/bsekar/scripts/mem/fanout_trace.tcl
foreach bus $allBus {
	deselectAll
	selectIOPin ${bus}*

	if {[regexp T_RWM $bus]} {continue }
	if {[regexp TEST $bus]} {continue }

	set dir [lsort -uniq [get_property [get_ports $bus -quiet] direction]]
	if { $dir == "in"} {
		fanout_trace ${bus}* 3 port
		if {[info exists omacros1] && [llength $omacros1] > 0 } {selectInst [gon $omacros1]   }
		if {[info exists omacros2] && [llength $omacros2] > 0 } {selectInst [gon $omacros2]   }
		if {[info exists omacros3] && [llength $omacros3] > 0 } {selectInst [gon $omacros3]   }
	   } else {
		fanin_trace ${bus}* 3 port

		if {[info exists imacros1] && [llength $imacros1] > 0 } {selectInst [gon $imacros1]  }
		if {[info exists imacros2] && [llength $imacros2] > 0 } {selectInst [gon $imacros2]  }
		if {[info exists imacros3] && [llength $imacros3] > 0 } {selectInst [gon $imacros3]  }
		}
	incr c
	if {$i == 4} {set i 5}
	if { [regexp "inst"  [dbget -e  selected.objType]] } {
		highlight -index $i ; set i [expr $i + 1]
		puts $fp "Name : $bus direction : $dir total pins : [soc [get_ports $bus -quiet]]"
		puts $fp "Macro : [ dbget -e [dbget selected.objType inst -p].name]"
		puts $fp ".............................................."
		}
	#if {$i < 1} {break}
	#if {$i == 53} {set i 52}
	#if {$i == 49} {set i 30}
}

puts "CHECK port_macro_connection.rpt file . it willl comtain port-->macro connnection."


close $fp

