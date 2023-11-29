set designs_to_remove {}
foreach_in_collection i [get_cells -hierarchical -filter "is_hierarchical == true"] {
        append_to_collection designs_to_remove [get_designs [get_attr $i ref_name]]
}
set designs_to_remove  [ remove_from_collection [get_designs *] [add_to_collection [current_design] $designs_to_remove]]

set cells_to_remove {}
foreach_in_collection j $designs_to_remove {
                foreach_in_collection i [get_cells -hierarchical -filter "ref_name == [get_object_name $j]"] {
                    if { [sizeof_col [get_cells [get_object_name $i]/* -q]] == 0 } {
                        echo "Ungrouping Empty instance [get_object_name $i]"
                        lappend cells_to_remove [get_object_name $i]
                    }
                }
            }
if {[llength $cells_to_remove ] > 0  } {
                foreach i $cells_to_remove {
                    remove_attribute -quiet $i dont_touch
                    remove_cell $i
                }
}




set design_list [file_to_list /nfs/pt/store/project_store12/store_kw28/USERS_V/lioral/kw28/default_area_manof/MODELS/Backend/kw28_alpha_macro/glc/r0/report/empty_module_file.rpt]
set designs_to_remove {}
foreach d $design_list {
    append_to_collection designs_to_remove [get_designs $d]
    puts "appending $d"
}
set cells_to_remove {}
foreach_in_collection j $designs_to_remove {
                foreach_in_collection i [get_cells -hierarchical -filter "ref_name == [get_object_name $j]"] {
                    if { [sizeof_col [get_cells [get_object_name $i]/* -q]] == 0 } {
                        echo "Ungrouping Empty instance [get_object_name $i]"
                        lappend cells_to_remove [get_object_name $i]
                    }
                }
            }
if {[llength $cells_to_remove ] > 0  } {
                foreach i $cells_to_remove {
                    remove_attribute -quiet $i dont_touch
                    remove_cell $i
                }
}

