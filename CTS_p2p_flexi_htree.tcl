proc P2P_flex_cui {args} {
    for {set i 0} {$i < [llength $args]} {incr i} {
        set name [lindex $args $i]
            if {[string match "-*" $name]} {
               set options($name) [lindex $args [expr $i + 1]]
               incr i
            }
    }
reset_cts_config 

if {[info exists options(-source_pin)    ]} {    set source_pin   $options(-source_pin)    } {    Puts "Missing source pin"  ; return   }
if {[info exists options(-sink_pins)     ]} {    set sink_pins    $options(-sink_pins)     } {    Puts "Missing sinks pins"  ; return   }
if {[info exists options(-use_buffer)    ]} {    set use_buffer   $options(-use_buffer)    } {    Puts "Missing Buffer"      ; return   }
if {[info exists options(-top_layer)     ]} {    set top_layer    $options(-top_layer)     } {    Puts "Missing top layer"   ; return   }
if {[info exists options(-bottom_layer)  ]} {    set bottom_layer $options(-bottom_layer)  } {    Puts "Missing bottom layer"; return   }
if {[info exists options(-ndr)           ]} {    set ndr          $options(-ndr)           } {    set ndr ""    }
if {[info exists options(-distance)      ]} {    set distance     $options(-distance)      } {    Puts "Missing distance will default to 500u" ;  set distance 500   }
if {[info exists options(-shield_net)    ]} {    set shield_net   $options(-shield_net)    } {    set shield_net ""   }   

# for all pins endpoint 
foreach pin $sink_pins {set_db [get_db pin:$pin] .cts_sink_type stop}

create_clock_tree -name $source_pin -source $source_pin

delete_flexible_htrees HT_${ndr}_${top_layer}_${bottom_layer}
if {[get_db route_types .name RT_${ndr}_${top_layer}_${bottom_layer}] != ""} {
	delete_obj [get_db route_type:RT_${ndr}_${top_layer}_${bottom_layer}]
}

if {$ndr == ""} {
   if {$shield_net == ""} {
	   create_route_type -name RT_${ndr}_${top_layer}_${bottom_layer} \
		-top_preferred_layer $top_layer \
		-bottom_preferred_layer $bottom_layer \
		-preferred_routing_layer_effort high
   } else {
	   create_route_type -name RT_${ndr}_${top_layer}_${bottom_layer} \
		-top_preferred_layer $top_layer \
		-bottom_preferred_layer $bottom_layer \
		-shield_net $shield_net \
		-preferred_routing_layer_effort high
     }
} else {
   if {$shield_net == ""} {
	   create_route_type -name RT_${ndr}_${top_layer}_${bottom_layer} \
		-top_preferred_layer $top_layer \
		-bottom_preferred_layer $bottom_layer \
		-route_rule $ndr \
		-preferred_routing_layer_effort high
   } else {
	   create_route_type -name RT_${ndr}_${top_layer}_${bottom_layer} \
		-top_preferred_layer $top_layer \
		-bottom_preferred_layer $bottom_layer \
		-route_rule $ndr \
		-shield_net $shield_net \
		-preferred_routing_layer_effort high
     }
}

set_db cts_route_type_top RT_${ndr}_${top_layer}_${bottom_layer} 

puts "name: HT_${ndr}_${top_layer}_${bottom_layer}"
puts "sink_instance_prefix: HT_${ndr}_${top_layer}_${bottom_layer}_cell "
puts "trunk_cell: $use_buffer"
puts "final_cell: $use_buffer"
puts "source: $source_pin"
puts "sink_pins: $sink_pins"
puts "max_driver_distance: $distance "

create_flexible_htree \
 -name HT_${ndr}_${top_layer}_${bottom_layer} \
 -sink_instance_prefix  HT_${ndr}_${top_layer}_${bottom_layer}_cell \
 -adjust_sink_grid_for_aspect_ratio false \
 -no_symmetry_buffers \
 -sink_grid {1 1} \
 -trunk_cell $use_buffer \
 -final_cell $use_buffer \
 -source $source_pin \
 -sink_pins $sink_pins \
 -max_driver_distance $distance \
 -mode distance

synthesize_flexible_htrees -spec_file dummy.tcl  

delete_flexible_htrees HT_${ndr}_${top_layer}_${bottom_layer}
delete_clock_trees $source_pin  
delete_obj RT_${ndr}_${top_layer}_${bottom_layer}
}




