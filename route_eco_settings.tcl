# some ECO route setting to run faster

##Turn OFF DFM via in ECO mode
set_route_zrt_common_options -post_detail_route_redundant_via_insertion off -concurrent_redundant_via_mode off -post_eco_route_fix_soft_violations true

##Turn OFF Timing in ECO mode
set_route_zrt_detail_options -drc_convergence_effort_level high -force_max_number_iterations false -timing_driven false
set_route_zrt_global_options -crosstalk_driven false -timing_driven false
set_route_zrt_track_options  -crosstalk_driven false -timing_driven false
