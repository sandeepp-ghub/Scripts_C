source ~/scripts/service_procs/file_to_list.tcl
proc soc_long_nets_fix  {args} {
    parse_proc_arguments -args ${args} results
    global nets_list;
    global nets_index;
    global n
    #-- creat the nets list
    if {[info exists results(-creat_db)]} {
        set nets_list ""
        set lines [file_to_list /nfs/pt/store/project_store12/store_sparrow/lioral/MODELS/Backend/sparrow_alpha_macro/sta/r0/report/general/sparrow_alpha_macro.wire_above_required]
        set nets_index 0;
        foreach l $lines {
            if {[regexp {([a-zA-Z0-9\/\[\]\_])+} $l net]} {
                puts $net
                lappend nets_list $net
            }
        }
    } else {
        gui_change_highlight -remove -all_colors
    #-- interactive mode
        set n [lindex $nets_list $nets_index]
        zoom -net $n -h r
        set resvers [get_cells -of_object [get_pins -of_object [get_nets [lindex $nets_list $nets_index]]]]
        set driver  [get_cells -of_object [get_pins -of_object [get_nets [lindex $nets_list $nets_index]] -filter "direction == out"]]
        puts "#-- res"
        pc $resvers
        zoom -cell_col $resvers -h g 
        incr nets_index;

        puts "#-- drivers"
        pc $driver
        zoom -cell_col $driver  -h b 
    }


}


define_proc_attributes soc_long_nets_fix \
    -info "" \
    -define_args {
    {-creat_db    ""    "" boolean optional}
}

