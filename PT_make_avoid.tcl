
set new_avoid_list {
    roc_routes
    gserp_16lane1
    gserp_16lane0
	gserp_4lane
    gserr
	cpt0
	cpt1
}
#   rcplx

array unset cells_of
current_scenario [index_collection [current_scenario] 0]
set freeze_list [array names pteco_skipped_steps]
set_distributed_variables freeze_list
remote {
	set cells_of {}
	foreach blk $freeze_list {
		set cells_of [concat $cells_of [get_object_name [get_cells -hier -filter "ref_name==$blk"]]]
	}
}	
get_distributed_variables cells_of 
current_scenario -all

foreach el [lsort $cells_of([array names cells_of])] {
	set add 1
	foreach pat $new_avoid_list {
		if {[regexp "^$pat" $el]} {set add 0}
	}
	if {$add} {lappend new_avoid_list $el}
}
