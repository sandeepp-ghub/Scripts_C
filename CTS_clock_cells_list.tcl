# This is  Cadence scripts copied and  modifed for F105 project requirement.
#
# Script to report clock tree instances (sinks, gates, buffers, etc.)
#
# Instance names output to $filename
#
set filename "F105_clock_instances.rpt"
set filePtr [open $filename "w"]

puts "Make sure this is ECO DB."
set clock_cells { }
set non_clock_cells { }
set clock_nets [ get_db [get_db nets -if { .is_clock == 1 } ] .name]
 foreach net $clock_nets {
 set instances {}
 #puts "$net:net"
 catch {set instances [get_db net:$net .loads.inst.name]}
  lappend clock_cells $instances
#puts "$instances \n $net:nets"
}

set clock_cells_ordered [eval [list concat] $clock_cells]
set clock_cells_unique [lsort -u $clock_cells_ordered ]
set counter 0
foreach inst $clock_cells_unique {
  puts $filePtr "$inst ([get_db inst:$inst .base_cell.name ])"
  incr counter
  lappend non_clock_cells [get_db inst:$inst -if { .base_cell.name==BUFF*||.base_cell.name==INV*}] 
  
}

puts $filePtr "##############################################################################################"
puts $filePtr "Non clock cells Instances found : { [lsort -u [eval [list concat] $non_clock_cells]] }"
puts $filePtr "##############################################################################################"
puts "Total Clock Tree Instances: $counter"
puts "Total Non clock Instances: [llength [lsort -u [eval [list concat] $non_clock_cells]]]"
puts "Non clock instances: [lsort -u [eval [list concat] $non_clock_cells]] }"
puts "Output File: $filename"
close $filePtr
