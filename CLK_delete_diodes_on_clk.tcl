procedure ::inv::clock::delete_diodes_on_clock {
    -description "Deleting all diodes on clocks \$clocks"
    -args {
        {clocks -type string -mandatory} 
    }
    
} {
    set design $::SESSION(design)
    foreach clock $clocks {
        log -info "Working on clock $clock"
        set all_prefixes "${design}_${clock}_diode_cell* ${clock}_diode_cell*"
        set my_clocks  [get_db clocks -if {.base_name == $clock}]
        set my_sources [get_db $my_clocks .sources.net -uniq]
        foreach prefix $all_prefixes {
            set my_loads [get_db $my_sources .loads.inst -if {.name == $prefix*} ]
            if { [llength $my_loads] } {
                log -info "Deleting: $my_loads"
                delete_obj $my_loads
            } else {
                log -info "Nothing to delete for $prefix"
            }
        }
    }
}

