gui_set_hotkey -hot_key "ctrl+G" -tcl_cmd "find_fanout_flops" -replace
gui_set_hotkey -hot_key "SHIFT+G" -tcl_cmd "find_fanin_flops" -replace

proc find_fanin_flops {args} {
parse_proc_arguments -args ${args} results
if {[info exists results(-debug)]}       {set dbg 1}  else {set dbg  0}
if {[info exists results(-super_debug)]} {set sdbg 1} else {set sdbg 0}

    set select_cells [filter_collection [get_selection] "object_class==cell" ]
    set select_ports [filter_collection [get_selection] "object_class==port" ]
    change_selection
    if {$select_ports ne ""} {
        change_selection [filter_collection [all_fanin -to $select_ports -only_cells -flat] is_sequential==true] -add
    }
    if {$select_cells ne ""} {

        set all_data_pin [get_pins -quiet -of_objects $select_cells -filter "direction==in && is_data_pin==true&&name!~*SI*"]
        if {$all_data_pin eq ""} {
            set all_data_pin [filter_collection [get_pins -quiet -of_objects $select_cells -filter "direction==in&&name!~*SI*"] {name!~"(VDD|VSS)"} -regexp]
        }
        pc $all_data_pin
    #puts "[get_object_name [filter_collection [all_fanin -to $all_data_pin -only_cells] is_sequential==true]]"
        change_selection [remove_from_collection [filter_collection [all_fanin -to $all_data_pin -only_cells -flat] "is_sequential==true&&name!~*_bist_*&&name!~*_csr_*"] $select_cells] -add
        change_selection [remove_from_collection [filter_collection [all_fanin -to $all_data_pin  -flat] "object_class==port"] $select_cells] -add
    }
}
define_proc_attributes find_fanin_flops  \
    -info "  " \
    -define_args {
        {-debug       ""  "" boolean optional}
        {-super_debug ""  "" boolean optional}

    }



proc find_fanout_flops {args} {
parse_proc_arguments -args ${args} results
if {[info exists results(-debug)]}       {set dbg 1}  else {set dbg 0}
if {[info exists results(-super_debug)]} {set sdbg 1} else {set sdbg 0}
    set select_cells [filter_collection [get_selection] "object_class==cell" ]
    set select_ports [filter_collection [get_selection] "object_class==port" ]
    change_selection
    if {[lindex [get_attribute [get_selection] object_class] 0] eq "port"} {
        change_selection [filter_collection [all_fanout -from $select_ports -only_cells -flat] is_sequential==true] -add
    } else {
        set all_data_pin [get_pins -quiet -of_objects $select_cells -filter "direction==out&&name!~*SO*"]
        if {$all_data_pin eq ""} {
           set all_data_pin [filter_collection [get_pins -quiet -of_objects $select_cells -filter "direction==out&&name!~SO*"] {name!~"(VDD|VSS)"} -regexp]
        }
        pc $all_data_pin
        #puts "[get_object_name [filter_collection [all_fanout -from $all_data_pin -only_cells] is_sequential==true]]"
        change_selection [remove_from_collection [filter_collection [all_fanout -from $all_data_pin -only_cells -flat] "is_sequential==true"] $select_cells] -add
        change_selection [remove_from_collection [filter_collection [all_fanout -from $all_data_pin  -flat] "object_class==port"] $select_cells] -add
    }
}
define_proc_attributes find_fanout_flops  \
    -info "  " \
    -define_args {
        {-debug       ""  "" boolean optional}
        {-super_debug ""  "" boolean optional}

    }




