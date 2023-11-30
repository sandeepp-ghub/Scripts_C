#save_mw_cel -as temp
#check_legality 
#report_timing
#set_object_fixed_edit [get_cells kw28_alpha_macro_io_buf/*__buffer] 1
#sig_remove_filler
legalize_placement -incremental -effort high -timing
source /nfs/pt/store/project_store12/store_kw28/USERS_V/lioral/kw28/default_area_manof/MODELS/Backend/kw28_alpha_macro/mky/r0/script/sig_connect_pg_nets.tcl
sig_connect_pg_nets
#derive_pg_connection
#legalize_placement -incremental -effort high -timing
#derive_pg_connection
route_zrt_eco -max_detail_route_iterations 60 -nets [file_to_list net_file_sorted]
save_mw_cel -as kw28_alpha_macro
#/nfs/pt/store/project_store12/store_kw28/USERS_V/lioral/kw28/default_area_manof/MODELS/Backend/kw28_alpha_macro/mky/r2/script/Shron_sol.tcl


#sig_insert_fillers
sig_write_verilog -no_power -name sparrow_alpha_macro
sig_write_wire_length
save_mw_cel -as sparrow_alpha_macro
sh touch qwerty 
sig_write_gds -cel sparrow_alpha_macro
sh touch iddqd
check_legality -verbose > check_leg
verify_lvs -max_error 2000 -ignore_floating_port -ignore_floating_net -ignore_open -ignore_eeq_pin -ignore_min_area -ignore_blockage_overlap -ignore_floating_metal_fill_net -check_short_locator
verify_zrt_route
report_timing



#verify_lvs -max_error 2000 -ignore_floating_port -ignore_floating_net -ignore_eeq_pin -ignore_min_area -ignore_blockage_overlap -ignore_floating_metal_fill_net > ver_lvs


#route_zrt_eco -nets [file_to_list nets_file_to_source1  ] -open_net_driven true -reuse_existing_global_route true -reroute modified_nets_first_then_others

sig_metal_density -mw_lib ../kw28_alpha_macro_mw -map_file /nfs/yok/layout/layout_disk02/28n_projects/KW28/PROJECT_CONFIG/Technology_Files/mky_m9.strminmap -calibre_gds /nfs/pt/store/project_store12/store_kw28/USERS_V/lioral/kw28/default_area_manof/MODELS/Backend/kw28_alpha_macro/pv/r0/work/DUMMY/DM.gds


change_selection [get_cells *filler* -all]  
set_object_fixed_edit [get_selection] 0
sig_remove_filler

legalize_placement -incremental -effort high -timing
#source /nfs/pt/store/project_store12/store_kw28/USERS_V/lioral/kw28/default_area_manof/MODELS/Backend/kw28_alpha_macro/mky/r0/script/sig_connect_pg_nets.tcl
sig_insert_fillers -dont_route_zrt_eco;
sig_connect_pg_nets
route_zrt_eco -max_detail_route_iterations 60
save_mw_cel
sig_write_verilog -no_power -name nova_c2c_cp_macro
sig_write_wire_length
sig_write_gds

sh touch qwerty





sig_


sig_write_gds -cel sparrow_alpha_macro
#sig_write_verilog -name sparrow_alpha_macro
sig_write_verilog -no_power -name nova_c2c_cp_macro
sig_write_wire_length


save_mw_cel -as sparrow_alpha_macro
sh touch qwerty


verify_lvs -max_error 2000 -ignore_floating_port -ignore_floating_net -ignore_open -ignore_eeq_pin -ignore_min_area -ignore_blockage_overlap -ignore_floating_metal_fill_net -check_short_locator
verify_zrt_route


sig_remove_filler
legalize_placement -incremental -effort high -timing
#check_legality -verbose > check_leg
sig_connect_pg_nets
set_route_zrt_detail_options -drc_convergence_effort_level high -force_max_number_iterations false -timing_driven false
set_route_zrt_global_options -crosstalk_driven false -timing_driven false
set_route_zrt_track_options  -crosstalk_driven false -timing_driven false


route_zrt_eco -max_detail_route_iterations 60 -reroute modified_nets_first_then_others
#check_legality -verbose > check_leg
sig_insert_fillers -strategy signoff_slow
#sig_write_verilog -name sparrow_alpha_macro
sig_write_verilog -no_power -name sparrow_alpha_macro
sig_write_wire_length
save_mw_cel -as sparrow_alpha_macro
sh touch qwerty 





# some ECO route setting to run faster

##Turn OFF DFM via in ECO mode
set_route_zrt_common_options -post_detail_route_redundant_via_insertion off -concurrent_redundant_via_mode off -post_eco_route_fix_soft_violations true

##Turn OFF Timing in ECO mode
set_route_zrt_detail_options -drc_convergence_effort_level high -force_max_number_iterations false -timing_driven false
set_route_zrt_global_options -crosstalk_driven false -timing_driven false
set_route_zrt_track_options  -crosstalk_driven false -timing_driven false

route_zrt_eco -max_detail_route_iterations 60


-net $bbb




set_false_path -from [get_ports]
set_false_path -to [get_ports]
set_false_path -from [get_ports]  -to [get_ports]



remove_objects [get_text * ]
sig_gen_ports_text -with_alp ;
save_mw_cel
sig_write_gds
sig_write_verilog -no_power -name nova_c2c_cp_macro
sig_write_wire_length
sig_write_def
sig_write_lef

save_mw_cel

