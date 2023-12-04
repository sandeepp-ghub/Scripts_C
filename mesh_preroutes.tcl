set fp [open "mesh_preroutes.tcl" w]
set flop_location 750
set offset_num 5


puts $fp "set_db edit_wire_snap_objects_to_track  {patch regular special}"

puts $fp "set_db edit_wire_type special"
puts $fp "set_db edit_wire_drc_on {0}"
puts $fp "set_db edit_wire_stop_at_drc {1}"
puts $fp "set_db edit_wire_via_allow_geometry_drc {1}"
puts $fp "set_db edit_wire_snap_bus_to_pin {0}"
puts $fp "set_db edit_wire_snap_to_track_honor_color {0}"
puts $fp "set_db edit_wire_snap_trim_metal_to_trim_grid {0}"
puts $fp "set_db edit_wire_create_crossover_vias {1}"
puts $fp "set_db edit_wire_create_via_on_pin {1}"
puts $fp "set_db edit_wire_layer_horizontal M14"
puts $fp "set_db edit_wire_width_horizontal 0.126"
puts $fp "set_db edit_wire_spacing_horizontal 0.126"
puts $fp "set_db edit_wire_layer_vertical M13"
puts $fp "set_db edit_wire_width_vertical 0.126"
puts $fp "set_db edit_wire_spacing_vertical 0.126"
puts $fp "gui_set_tool addWire"
puts $fp "\n"
puts $fp "set_db edit_wire_layer_horizontal M14"



##Location of mesh ports on edge 0
foreach port [get_db ports *msh* -if {.name != *msh*active* && .layer.name ==M14 && .pin_edge==0} ] {
set location_x [get_db $port .location.x]
set location_y [get_db $port .location.y]
set net_name [get_db $port .net.name]
delete_obj [get_db [get_db nets $net_name] .special_wires]
puts $fp "\n"
puts $fp "set_db edit_wire_nets $net_name"
puts $fp "edit_add_route_point {$location_x $location_y}"
puts $fp "edit_end_route_point  {[expr $flop_location - $offset_num]  $location_y}"
}



##Location of mesh ports on edge 2 and 4
foreach port [get_db ports *msh* -if {.name != *msh*active* && .layer.name ==M14 && (.pin_edge==2 || .pin_edge==4)} ] {
set location_x [get_db $port .location.x]
set location_y [get_db $port .location.y]
set net_name [get_db $port .net.name]
delete_obj [get_db [get_db nets $net_name] .special_wires]

puts $fp "\n"
puts $fp "set_db edit_wire_nets $net_name"
puts $fp "edit_add_route_point  {[expr $flop_location + $offset_num]  $location_y}"
puts $fp "edit_end_route_point {$location_x $location_y}"

}

puts $fp "set_db edit_wire_drc_on true"
puts $fp "set_db edit_wire_stop_at_drc true"
puts $fp "set_db edit_wire_disable_snap false"
puts $fp "set_db edit_wire_via_allow_geometry_drc true"
puts $fp "set_db edit_wire_snap_bus_to_pin false"
puts $fp "set_db edit_wire_snap_to_track_honor_color true"
puts $fp "set_db edit_wire_snap_trim_metal_to_trim_grid true"
puts $fp "set_db edit_wire_via_auto_snap true"
puts $fp "set_db edit_wire_via_snap_honor_color true"
puts $fp "set_db edit_wire_via_snap_to_intersection true"
puts $fp "set_db edit_wire_create_crossover_vias true"
puts $fp "set_db edit_wire_create_via_on_pin true"
puts $fp "gui_set_tool select"


close $fp


puts "sourcing mesh_preroutes.tcl ....."
source mesh_preroutes.tcl 


edit_update_route_status -nets [get_db -u [get_db ports *msh* -if {.name != msh*active*} ] .net.name] -to fixed
