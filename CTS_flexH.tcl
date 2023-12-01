#Configure your CCopt run by providing the correct constraints.

set_db cts_primary_delay_corner ssgnp0p675vm40c_cworstCCwTm40_setup
set_db cts_target_max_transition_time {top 0.05 trunk 0.05 leaf 0.05}
set_db cts_target_skew 0.042
set_db cts_route_type_auto_trim false

#Setting RouteType
### User can add shielding to the nets using the "-shield_net <netName>" option and can also specify the shielding side as "-shield_side one_side". These are optional.

#create_route_type -name TOP -route_rule 2w2s_ndr -top_preferred_layer M14 -bottom_preferred_layer M12  -preferred_routing_layer_effort high
#create_route_type -name TRUNK -route_rule 2w2s_ndr -top_preferred_layer M14 -bottom_preferred_layer M12 -preferred_routing_layer_effort high  
#create_route_type -name LEAF -route_rule 2w2s_ndr -top_preferred_layer M14 -bottom_preferred_layer M12 -preferred_routing_layer_effort high

set_db clock_trees .cts_route_type_top TOP
set_db clock_trees .cts_route_type_trunk TRUNK
set_db clock_trees .cts_route_type_leaf LEAF

#Creating clock tree spec.

create_clock_tree_spec -out_file ccopt.spec
source ccopt.spec

#Creating Flexible HTree Network.
##You can tune the switches present in create_ccopt_flexible_htree based on your requirement.
create_flexible_htree  -name gpu_CLK_STACKS_flex_Htree  -trunk_cell DCCKBD24BWP210H6P51CNODULVT   -final_cell DCCKBD16BWP210H6P51CNODULVT  -sink_instance_prefix FHT  -source pin:g78ae_slice/g78ae_slice_CLK_STACKS_TAP/Z  -sink_grid {12 5}  -sink_grid_box {12.974 417.1435 102.6725 2352.085}  -sink_grid_sink_area {30 30}   -image_directory ./report
create_flexible_htree -name flex_HTREE -trunk_cell DCCKBD16BWP210H6P51CNODULVT  -final_cell DCCKBD10BWP210H6P51CNODULVT  -no_symmetry_buffers -sink_instance_prefix HJ -source CLK_COREGROUP -sink_grid {4 4}
create_flexible_htree -name flex_HTREE -trunk_cell DCCKBD16BWP210H6P51CNODULVT  -final_cell DCCKBD10BWP210H6P51CNODULVT  -no_symmetry_buffers -sink_instance_prefix HJ -source CLK_STACKS -sink_grid {4 4}
create_flexible_htree -name flex_HTREE -trunk_cell DCCKBD16BWP210H6P51CNODULVT  -final_cell DCCKBD10BWP210H6P51CNODULVT  -no_symmetry_buffers -sink_instance_prefix HJ -source CLK -sink_grid {4 4}

synthesize_flexible_htrees
set_db cts_spec_config_create_clock_tree_source_groups true


#NOTE: The command option -no_symmetry_buffers has been changed to -omit_symmetry in Innovus 20.1. The option being used works with present version of Innovus and will be obsoleted in a future release.

#Setting up the cell list for the connection from the tap point to all sinks.
##MS CTS FLOW

#set_db clock_trees .cts_top_buffer_cells { DCCKBD16BWP210H6P51CNODULVT DCCKBD14BWP210H6P51CNODULVT DCCKBD12BWP210H6P51CNODULVT DCCKBD10BWP210H6P51CNODULVT}
#set_db clock_trees .cts_buffer_cells {DCCKBD16BWP210H6P51CNODULVT DCCKBD14BWP210H6P51CNODULVT DCCKBD12BWP210H6P51CNODULVT DCCKBD10BWP210H6P51CNODULVT}
#set_db clock_trees .cts_leaf_buffer_cells {DCCKBD8BWP210H6P51CNODULVT DCCKBD6BWP210H6P51CNODULVT DCCKBD5BWP210H6P51CNODULVT DCCKBD4BWP210H6P51CNODULVT DCCKBD16BWP210H6P51CNODULVT DCCKBD14BWP210H6P51CNODULVT DCCKBD12BWP210H6P51CNODULVT DCCKBD10BWP210H6P51CNODULVT CKBD3BWP210H6P51CNODULVT CKBD2BWP210H6P51CNODULVT}
#
#set_db clock_trees .cts_top_inverter_cells {DCCKND16BWP210H6P51CNODULVT DCCKND14BWP210H6P51CNODULVT DCCKND12BWP210H6P51CNODULVT DCCKND10BWP210H6P51CNODULVT }
#set_db clock_trees .cts_inverter_cells { DCCKND16BWP210H6P51CNODULVT DCCKND14BWP210H6P51CNODULVT DCCKND12BWP210H6P51CNODULVT DCCKND10BWP210H6P51CNODULVT}
#set_db clock_trees .cts_leaf_inverter_cells {DCCKND8BWP210H6P51CNODULVT DCCKND6BWP210H6P51CNODULVT DCCKND5BWP210H6P51CNODULVT DCCKND4BWP210H6P51CNODULVT DCCKND16BWP210H6P51CNODULVT DCCKND14BWP210H6P51CNODULVT DCCKND12BWP210H6P51CNODULVT DCCKND10BWP210H6P51CNODULVT CKND3BWP210H6P51CNODULVT CKND2BWP210H6P51CNODULVT}
#
#set_db clock_trees .cts_clock_gating_cells {CKLNQTWBD8BWP210H6P51CNODULVT CKLNQD6BWP210H6P51CNODULVT CKLNQD5BWP210H6P51CNODULVT CKLNQD4BWP210H6P51CNODULVT CKLNQD3BWP210H6P51CNODULVT CKLNQD2BWP210H6P51CNODULVT CKLNQD1BWP210H6P51CNODULVT CKLNQD16BWP210H6P51CNODULVT CKLNQD14BWP210H6P51CNODULVT CKLNQD12BWP210H6P51CNODULVT CKLNQD10BWP210H6P51CNODULVT CKLHQTWBD4BWP210H6P51CNODULVT CKLHQD8BWP210H6P51CNODULVT CKLHQD6BWP210H6P51CNODULVT CKLHQD5BWP210H6P51CNODULVT CKLHQD3BWP210H6P51CNODULVT CKLHQD2BWP210H6P51CNODULVT CKLHQD1BWP210H6P51CNODULVT CKLHQD16BWP210H6P51CNODULVT CKLHQD14BWP210H6P51CNODULVT CKLHQD12BWP210H6P51CNODULVT CKLHQD10BWP210H6P51CNODULVT}
#set_db clock_trees .cts_logic_cells {CKND2NOMSCD1BWP210H6P51CNODULVT CKND2NOMSBD1BWP210H6P51CNODULVT CKXOR2TWAD4BWP210H6P51CNODULVT CKXOR2D2BWP210H6P51CNODULVT CKXOR2D1BWP210H6P51CNODULVT CKOR2D2BWP210H6P51CNODULVT CKND2TWCD4BWP210H6P51CNODULVT CKND2TWCD2BWP210H6P51CNODULVT CKND2TWAD4BWP210H6P51CNODULVT CKND2NOMSAD1BWP210H6P51CNODULVT CKND2D2BWP210H6P51CNODULVT CKND2BWP210H6P51CNODULVT CKMUX2TWBD4BWP210H6P51CNODULVT CKMUX2D2BWP210H6P51CNODULVT CKMUX2D1BWP210H6P51CNODULVT CKAN2D4BWP210H6P51CNODULVT CKAN2D2BWP210H6P51CNODULVT CKAN2D1BWP210H6P51CNODULVT}
#
# 

#Setting dont touch as False on all the clock gates so that the root allocation [assignment of the sink with respect to each tap point] is proper.

foreach i [get_db clock_trees .insts -if {.cts_node_type == clock_gate}] {
   set_db inst:$i .dont_touch false
}

#Use the following two commands if you want to enable cloning in your runs. The default behavior is "False".

set_db cts_clone_clock_gates true
set_db cts_clone_clock_logic true

set_db clock_trees .cts_route_type_top TOP
set_db clock_trees .cts_route_type_trunk TRUNK
set_db clock_trees .cts_route_type_leaf LEAF

set_db cts_clock_gate_movement_limit 100000
clock_design
 
write_db FHTREE.db 
