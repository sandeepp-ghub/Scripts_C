### High  mag Cap Clock Nets ###########################################################

set fp [open ${dataout_prefix}_HIGH_CAP.rpt w]

set all_valid_ck_nets   $all_clock_nets 
set all_valid_ck_pins $all_clock_pins

set max_cap_limits [lsort -u -real  -increasing [get_attribute $all_valid_ck_pins  max_capacitance]]
set vio_nets ""
foreach max_cap $max_cap_limits {
    append_to_collection vio_nets [remove_from_collection -intersect $all_valid_ck_nets [get_nets -quiet -of [get_pins -quiet $all_valid_ck_pins -filter "max_capacitance==$max_cap"] -filter "(capacitance_max > $max_cap) || (capacitance_max > 50))"]] -unique 
}

if { [sizeof_collection $vio_nets] > 0} {
    set vio_pins [remove_from_collection -intersect $all_valid_ck_pins [get_pins -leaf -of $vio_nets] ]
    puts $fp  [format  "%-20s %-150s  %-10s %-10s %-10s %-50s  %-30s  %-150s %-30s" DESIGN_NAME  NET_NAME CAP_VAL CAP_LIMIT CAP_VIO CLOCK CLK_PERIOD  DRIVER DRIV_MASTER]
    set max_cap_limits [lsort -u -real -increasing [get_attribute -quiet $vio_pins  max_capacitance]]
    foreach max_cap $max_cap_limits {
	foreach_in_collection ck_net  [get_nets -quiet -of [get_pins -quiet $vio_pins -filter "max_capacitance == $max_cap"] -filter "capacitance_max > $max_cap"] {

	    set net_name [get_object_name $ck_net]

	    set driver [get_attribute -quiet $ck_net driver_pins]
	    set driver_name [get_object_name $driver]
	    set driver_ref [get_attribute -quiet [get_cells -quiet -of $driver]  ref_name]

	    set design_name [get_attribute [get_cells -quiet [find_pnr $driver_name]] ref_name]

	    if {$design_name == ""} {set design_name $top_design}

	    set clocks [index_collection [sort_collection [get_attribute -quiet $driver clocks] period] 0]
	    set clock_name [get_attribute $clocks full_name]
	    set clock_period [get_attribute $clocks period]
	    set clock_sources [get_object_name [get_attribute $clocks sources]]
	    
	    #set cap_max_rise [get_attribute $ck_net total_capacitance_max_rise]
	    #set cap_max_fall [get_attribute $ck_net total_capacitance_max_fall]
	    #if {$cap_max_rise > $cap_max_fall} {set cap_max $cap_max_rise} else {set cap_max $cap_max_rise}
	    set cap_max [get_attribute $ck_net capacitance_max]

	    set cap_vio [expr $max_cap - $cap_max]
	    
	    puts $fp  [format  "%-20s %-150s  %-10s %-10s %-10s %-50s  %-30s %-150s %-30s" $design_name  $net_name $cap_max $max_cap $cap_vio $clock_name $clock_period $driver_name $driver_ref ]
	    
	}
    }
}
close $fp
