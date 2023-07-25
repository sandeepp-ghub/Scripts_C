##
# 2 Approaches 
### 1: Run till place_macro_detail, get the best optimal macro placement and start with invcui_floorplan flow
### 2: Run the whole flow with settings in place for placeOpt
set_multi_cpu_usage -local_cpu 16

#save the power mesh mimic file and macros original orientation from golden Fplan

create_pg_model_for_macro_place -pg_resource_model -file golden_mimic_power_mesh.tcl
cleanup_floorplan_for_macro_place -save all

#remove routing blockages, placement blockages, relative_floorplan constraints, unplace placed instances, remove routing wires, boundary_constraints, delete physical instances

cleanup_floorplan_for_macro_place -remove {route_blockage place_blockage relative_floorplan insts_place wire boundary_constraint physical_inst}
create_place_halo -all_blocks -halo_deltas {1 1 1 1}

#set macro place constraints

set_macro_place_constraint -avoid_abut_macro_edge_with_pins true
set_macro_place_constraint -min_space_to_macro 5
set_macro_place_constraint -forbidden_space_to_macro 4
set_macro_place_constraint -min_space_to_core 5
set_macro_place_constraint -forbidden_space_to_core 4
set_macro_place_constraint -max_io_pin_group_keep_out 30
set_macro_place_constraint -honor_strict_spacing_constraint true

#init power mesh from the one got by reference(golden) FPlan.

set_db place_global_uniform_density  false;# Preferred
set_db place_opt_post_place_tcl  "";# Use if any post processing is needed 
#init_power_mesh_mapping golden_mimic_power_mesh.tcl
source golden_mimic_power_mesh.tcl

#run mixed placer

place_design -concurrent_macros -no_refine_macro
place_macro_detail

# Write out macro placement info only for the block. Use the macro placement in the regular invcui.floorplan flow

write_floorplan_script [df::current -design]_macro_placer.tcl -sections blocks
