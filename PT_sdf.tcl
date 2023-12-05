set sdf_blocks {
nw_pd
gsern_slm
host
sem_pd_core
nw_scan_pd 
nws_scan_pd
}
#set sdf_blocks nws_scan_pd
#set sdf_blocks cfc_pd
#set sdf_blocks host
set sdf_blocks {sem_pd_core nw_pd}

foreach ref $sdf_blocks {
  suppress_message SDF-036
  set inst [get_object_name [index_collection [get_cells -hier -filter "ref_name==$ref"] 0]]
  #write_sdf -instance $inst ${ref}.sdf -exclude_cells [get_clock_network_objects -type cell]
  write_sdf -instance $inst ${ref}_raw.sdf
  unsuppress_message SDF-036
}

if {0} {
  suppress_message SDF-036
  write_sdf everest_raw.sdf
  unsuppress_message SDF-036
}
