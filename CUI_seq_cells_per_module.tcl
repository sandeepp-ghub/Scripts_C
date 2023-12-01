##############################
##############################
proc wh_rptNumberOfFFInModule {} {
	global total_ff
	set total_ff 0
	if { [get_db selected] == "" } {
		# calculating all FFs starting from top level
		if {[get_db insts .base_cell.is_sequential 1] !="0x0"} {
		set total_ff [llength [get_db insts .base_cell.is_sequential 1]]
			puts "Top level has $total_ff sequential cells"
		}
	# going into each hierarchical instance (module)
	foreach n [get_db modules .name] {
 		wh_count_ff $n
 	}
	} else {
	## Puts "### Calculating Number of FFs in selected module "
 	foreach n [get_db selected] {
 	if {[get_db $n .obj_type] == "hinst"} {
 		set total [llength [get_db  $n .insts.is_sequential 1]]
 		 	puts "Selected module [get_db $n .name] has total $total sequential cells"
		foreach mod [get_db $n .module.name] {
		wh_count_ff_sel $mod
		}
 	} else {

 		puts "### Warning: Selected object [get_db $n .name] is of type \"[get_db $n .obj_type]\" and not of type \"hinst\". So Ignored."
 	}
 	}
	}
}
proc wh_count_ff_sel { module_pointer } {
	global total_ff
	if {[llength [get_db [get_db modules -if { .name == $module_pointer } ] .hinsts.insts.is_sequential 1 ]] !="0x0"} {
		foreach mod [get_db [get_db modules -if { .name == $module_pointer  } ] .hinsts.hinsts.name] {
		set count [llength [get_db [get_db hinsts -if { .name == $mod } ] .insts.is_sequential 1]]
		puts "Module $mod has $count sequential cells"
		}
	}
}


proc wh_count_ff { module_pointer } {
	global total_ff
	if {[llength [get_db [get_db modules -if { .name == $module_pointer } ] .hinsts.insts.is_sequential 1 ]] !="0x0"} {
		set count [llength [get_db [get_db modules -if { .name == $module_pointer  } ] .hinsts.insts.is_sequential 1]]
		puts "Module [get_db [get_db modules -if { .name == $module_pointer } ] .hinsts.name ] has $count sequential cells"
	}
}
##############################
##############################



