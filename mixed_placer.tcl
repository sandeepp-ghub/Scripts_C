##
# 2 Approaches 
### 1: Run till place_macro_detail, get the best optimal macro placement and start with invcui_floorplan flow
### 2: Run the whole flow with settings in place for placeOpt
set_multi_cpu_usage -local_cpu 16

#save the power mesh mimic file and macros original orientation from golden Fplan

create_pg_model_for_macro_place -pg_resource_model -file golden_mimic_power_mesh.tcl;# If no golden macro placement available then skip it
cleanup_floorplan_for_macro_place -save all

#remove routing blockages, placement blockages, relative_floorplan constraints, unplace placed instances, remove routing wires, boundary_constraints, delete physical instances

cleanup_floorplan_for_macro_place -remove {route_blockage place_blockage relative_floorplan insts_place wire boundary_constraint physical_inst}
create_place_halo -all_blocks -halo_deltas {1 1 1 1}

#set macro place constraints

set_macro_place_constraint -avoid_abut_macro_edge_with_pins true
set_macro_place_constraint -min_space_to_macro 8 
set_macro_place_constraint -forbidden_space_to_macro 7 
set_macro_place_constraint -min_space_to_core 10 
set_macro_place_constraint -forbidden_space_to_core 4
set_macro_place_constraint -max_io_pin_group_keep_out 30
set_macro_place_constraint -honor_strict_spacing_constraint true

#init power mesh from the one got by reference(golden) FPlan.

set_db place_global_uniform_density  false;# Preferred
set_db place_opt_post_place_tcl  "";# Use if any post processing is needed 
#init_power_mesh_mapping golden_mimic_power_mesh.tcl
source golden_mimic_power_mesh.tcl;# Skip if create_pg_model_for_macro_place is skipped 

# If Port placement available, Import it
#mRunStep floorplan_import_ports

#run mixed placer

place_design -concurrent_macros -no_refine_macro
place_macro_detail

# Write out macro placement info only for the block. Use the macro placement in the regular invcui.floorplan flow

write_floorplan_script [df::current -design]_macro_placer.tcl -sections blocks

###### takeout the def ######

#dbSet [dbget top.insts.cell.baseClass block -p2].pstatus fixed
#write_def_by_section -comp_placement -no_nets temp_placement.def
#
############  Add physical cells  ###############
#
#delete_obj place_blockage
#::df::snap_block
#::df::insert_endcap
#::df::insert_welltaps
#
####un place all the standard cells before placement 
#
#unplace_obj -insts
#
##check placement density if there are too many placement blockages added by finishFloorplan
#
#check_place
#
#
##start power routing
#
#::df::route_power
#
## Place ports if location is confirmed
#
#mRunStep floorplan_import_ports
#
##reset -earlyGlobalBlockTracks since real power routing is done
#
#eval_legacy {setRouteMode -reset  -earlyGlobalBlockTracks}
#read_def temp_placement.def
#
##incremental standard cell placement and preCTS Opt
#
#set_db place_opt_run_global_place seed
#place_opt_design
#
##Save DB
#
#exec [mkdir MixedPlacer_DB]

:qa!
write_db MixedPlacer_DB  

