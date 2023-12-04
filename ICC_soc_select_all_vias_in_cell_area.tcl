set esd_cords [get_attribute [get_cell *esd* -all] boundary] 
set esd_bottom_left [lindex $esd_cords 0] 
set esd_top_left [lindex $esd_cords 1] 
set esd_bottom_right [lindex $esd_cords 3] 
set esd_top_right [lindex $esd_cords 2] 
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}


###### Check VDD Vias Above The esd 
set metal1_above_esd_VDD [convert_to_polygon [get_net_shapes -of [get_nets *VDD* -all] -filter "layer == metal1"  -intersec "$esd_top_left [expr [lindex $esd_top_right 0] ]  [expr [lindex $esd_top_right 1] + 1]  "] -collection ]
set metal2_above_esd_VDD [convert_to_polygon [get_net_shapes -of [get_nets *VDD* -all] -filter "layer == metal2"  -intersec "$esd_top_left [expr [lindex $esd_top_right 0] ]  [expr [lindex $esd_top_right 1] + 1]  "] -collection ]
fic m2 $metal2_above_esd_VDD {                                                                                                                   
	fic m1 $metal1_above_esd_VDD {    
		if { [get_vias -of_objects [get_net -all VDD]  -intersect [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]] -filter "via_layer == via1" ] eq "" } {
			puts "no via in polygon:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			set look_in_win "[convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			puts "$look_in_win \n \{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] +1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] + 1.8]\} \}" 
		  		copy_objects -delta {0 -1.8}   "[get_vias -of_objects [get_net -all VDD] -intersect "\{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] +1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] + 1.8]\} \}"]" -use_same_net

	
		
		} else {
		   puts "Found Via1 in Window:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"
		}	   
 
	}
}

###### Check VSS Vias Above The esd 
set metal1_above_esd_VSS [convert_to_polygon [get_net_shapes -of [get_nets *VSS* -all] -filter "layer == metal1"  -intersec "$esd_top_left [expr [lindex $esd_top_right 0] ]  [expr [lindex $esd_top_right 1] + 1]  "] -collection ]
set metal2_above_esd_VSS [convert_to_polygon [get_net_shapes -of [get_nets *VSS* -all] -filter "layer == metal2"  -intersec "$esd_top_left [expr [lindex $esd_top_right 0] ]  [expr [lindex $esd_top_right 1] + 1]  "] -collection ]
fic m2 $metal2_above_esd_VSS {                                                                                                                   
	fic m1 $metal1_above_esd_VSS {    
		if { [get_vias -of_objects [get_net -all VSS]  -intersect [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]] -filter "via_layer == via1" ] eq "" } {
			puts "no via in polygon:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			set look_in_win "[convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			puts "$look_in_win \n \{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] +1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] + 1.8]\} \}" 
	      copy_objects -delta {0 -1.8}   "[get_vias -of_objects [get_net -all VSS] -intersect "\{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] +1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] + 1.8]\} \}"]" -use_same_net
		}  else {
		   puts "Found Via1 in Window:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"
		}	   

	}
}

###### Check VDD Vias Below The esd 
set metal1_below_esd_VDD [convert_to_polygon [get_net_shapes -of [get_nets *VDD* -all] -filter "layer == metal1"  -intersec "$esd_bottom_left [expr [lindex $esd_bottom_right 0] - 2]  [expr [lindex $esd_bottom_right 1] - 1]  "] -collection ]
set metal2_below_esd_VDD [convert_to_polygon [get_net_shapes -of [get_nets *VDD* -all] -filter "layer == metal2"  -intersec "$esd_bottom_left [expr [lindex $esd_bottom_right 0] - 2]  [expr [lindex $esd_bottom_right 1] - 1]  "] -collection ]
fic m2 $metal2_below_esd_VDD {                                                                                                                   
	fic m1 $metal1_below_esd_VDD {    
		if { [get_vias -of_objects [get_net -all VDD]  -intersect [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]] -filter "via_layer == via1" ] eq "" } {
			puts "no via in polygon:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			set look_in_win "[convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			puts "$look_in_win \n \{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] -1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] - 1.8]\} \}" 
	      copy_objects -delta {0 1.8}   "[get_vias -of_objects [get_net -all VDD] -intersect "\{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] -1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] - 1.8]\} \}"]" -use_same_net 
		} else {
		   puts "Found Via1 in Window:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"
		}	   
	}
}

###### Check VSS Vias Below The esd 
set metal1_below_esd_VSS [convert_to_polygon [get_net_shapes -of [get_nets *VSS* -all] -filter "layer == metal1"  -intersec "$esd_bottom_left [expr [lindex $esd_bottom_right 0] - 2]  [expr [lindex $esd_bottom_right 1] - 1]  "] -collection ]
set metal2_below_esd_VSS [convert_to_polygon [get_net_shapes -of [get_nets *VSS* -all] -filter "layer == metal2"  -intersec "$esd_bottom_left [expr [lindex $esd_bottom_right 0] - 2]  [expr [lindex $esd_bottom_right 1] - 1]  "] -collection ]
fic m2 $metal2_below_esd_VSS {                                                                                                                   
	fic m1 $metal1_below_esd_VSS {    
		if { [get_vias -of_objects [get_net -all VSS]  -intersect [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]] -filter "via_layer == via1" ] eq "" } {
			puts "no via in polygon:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			set look_in_win "[convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"; 	
			puts "$look_in_win \n \{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] -1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] - 1.8]\} \}" 
	      copy_objects -delta {0 1.8}   "[get_vias -of_objects [get_net -all VSS] -intersect "\{\{[lindex [lindex [lindex $look_in_win 0] 0] 0] [expr [lindex [lindex [lindex $look_in_win 0] 0] 1] -1.8]\} \{[lindex [lindex [lindex $look_in_win 0] 1] 0] [expr [lindex [lindex [lindex $look_in_win 0] 1] 1] - 1.8]\} \}"]" -use_same_net 
		} else {
		   puts "Found Via1 in Window:  [convert_from_polygon [compute_polygons -boolean and [get_attribute $m2 coordinate] [get_attribute $m1 coordinate]]]"
		}	   
 
	}
}






