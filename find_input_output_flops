#####
## Working on fabric side
#####

set inputs [lsort -dictionary  [get_db ports -if {.direction == in && .location.y > 300 }]  ]
set outputs [lsort -dictionary  [get_db ports -if {.direction == out && .location.y > 300 }]]
mortar::write_list_to_file -list $inputs  -file interconnect_north_edge_inputs
mortar::write_list_to_file -list $outputs -file interconnect_north_edge_outputs

set afo [lsort -dictionary [get_object_name [all_fanout -from [get_ports $inputs]  -endpoints_only  -only_cells]] ]
set afi [lsort -dictionary [get_object_name [all_fanin  -to   [get_ports $outputs] -startpoints_only -only_cells]]]
mortar::write_list_to_file -list $afo -file interconnect_north_edge_input_flops_list
mortar::write_list_to_file -list $afi -file interconnect_north_edge_output_flops_list


#### post processing
grep -Fx -f interconnect_north_edge_input_flops_list interconnect_north_edge_output_flops_list > interconnect_fabric_side_flop_isInput_and_isOutput
grep -Fxv -f interconnect_fabric_side_flop_isInput_and_isOutput  interconnect_north_edge_output_flops_list > interconnect_north_edge_output_only_flops_list

cat  interconnect_north_edge_input_flops_list interconnect_north_edge_output_only_flops_list > interconnect_north_edge_all_flops_list

#####
## Working on axi side
#####
set binputs  [get_db pins tpb_interconnect_axi_domain/* -if {.direction == in && .location.y > 300 }]
set boutputs [get_db pins tpb_interconnect_axi_domain/* -if {.direction == out && .location.y > 300 }]
mortar::write_list_to_file -list $binputs  -file interconnect_axi_north_inputs
mortar::write_list_to_file -list $boutputs -file interconnect_axi_north_outputs

set out2axiflops   [lsort -dictionary  [get_object_name [all_fanin  -to   [get_pins $binputs]   -startpoints_only  -only_cells]]  ]
set infromaxiflops [lsort -dictionary  [get_object_name [all_fanout -from [get_pins $boutputs]  -endpoints_only      -only_cells]]]
mortar::write_list_to_file -list $out2axiflops   -file interconnect_north_out2axiflops
mortar::write_list_to_file -list $infromaxiflops -file interconnect_north_infromaxiflops

#### post processing
grep -Fx -f interconnect_north_out2axiflops interconnect_north_infromaxiflops > interconnect_axi_side_flop_isInput_and_isOutput
grep -Fxv -f interconnect_axi_side_flop_isInput_and_isOutput interconnect_north_out2axiflops > interconnect_north_out2axi_only_flops

cat  interconnect_north_infromaxiflops interconnect_north_out2axi_only_flops >  interconnect_all_axi_side_flops

#####
## highlight groups
#####

mortar::read_file_to_list -file  interconnect_north_edge_input_flops_list       -list fabric_side_in
mortar::read_file_to_list -file  interconnect_north_edge_output_only_flops_list -list fabric_side_out
mortar::read_file_to_list -file  interconnect_north_infromaxiflops              -list axi_north_side_in
mortar::read_file_to_list -file  interconnect_north_out2axi_only_flops          -list axi_north_side_out

::gui_highlight $fabric_side_in    -color orchid      -pattern solid
::gui_highlight $fabric_side_out   -color deepskyblue -pattern solid
::gui_highlight $axi_north_side_in  -color teal        -pattern solid
::gui_highlight $axi_north_side_out -color orange      -pattern solid

