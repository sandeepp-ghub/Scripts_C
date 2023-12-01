proc dbNetWireLenX { net } {
set x_total ""
foreach x_len [get_db [get_db [get_db nets $net] .wires -if {.direction==horizontal}] .length] { set x_total [expr $x_total + $x_len]} ; 
return $x_total
}

proc dbNetWireLenY { net } {
set y_total ""
foreach y_len [get_db [get_db [get_db nets $net] .wires -if {.direction==vertical}] .length] { set y_total [expr $y_total + $y_len]} ; 
return $y_total
}

proc getNetLength { name } {
     if { $name == 0x0 } { return "*" }
     set NetLength [expr [dbNetWireLenX $name ] + [dbNetWireLenY $name ]]
     return $NetLength
}
 
proc ecoAddRepeaterChain { net maxdist cell } {
  #set_db eco_batch_mode true
  puts "Batch Mode set to true"
  if {[get_db [get_db nets $net] .num_connections] == 2} {
   set len [getNetLength $net]
   puts "Net: $net Length: $len"
   while {$len > $maxdist} {
    puts "Remaining length: $len relative_distance_to_sink: [expr $maxdist/$len]"
    puts "eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr $maxdist/$len]"
    set result [ eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr $maxdist/$len] ]
    set newInstName [lindex $result 2]
    select_obj [get_db insts $newInstName]
    set len [getNetLength $net]
   }

   # Place last buffer nearby the driver
   if {$len > 10.0} {
    puts "Remaining length > 10: $len relative_distance_to_sink: [expr 1-(10.0/$len)]"
    puts "eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr 1-(10.0/$len)]"
    set result [ eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr 1-(10.0/$len)] ]
    set newInstName [lindex $result 2]
    select_obj [get_db insts $newInstName]
   }
   select_obj [get_db selected .pins.net.name]
  } else {
    puts "Warning: cannot create chain because net has more than one endpoint"
  }
#set_db eco_batch_mode false
puts "Batch Mode set to false"
}
gui_deselect -all
