procedure ::inv::clock::open_cts_cells_dont_touch  {
    -short_description "open_cts_cells_dont_touch."
    -description       "open_cts_cells_dont_touch."
    -example           "::inv::clock::open_cts_cells_dont_touch"
    -args              {{args -type string -optional -multiple -description "args list"}}
} {
    global ::CDB
    log -info "::inv::clock::open_cts_cells_dont_touch - START"
    #Dont touch.
    set ::CDB(clock_cells_dont_touch_orig) ""
    foreach bcell [concat $::CDB(clock_buf) $::CDB(clock_inv) $::CDB(clock_gate) $::CDB(clock_comb)] {
        lappend ::CDB(clock_cells_dont_touch_orig) "$bcell [get_db base_cell:$bcell .dont_touch]"
        log -info "set_db base_cell:$bcell .dont_touch false"
        set_db base_cell:$bcell .dont_touch false -quiet
    }
    # Dont use.
    set ::CDB(clock_cells_dont_use_orig) ""
    foreach bcell [concat $::CDB(clock_buf) $::CDB(clock_inv) $::CDB(clock_gate) $::CDB(clock_comb)] {
        lappend ::CDB(clock_cells_dont_use_orig) "$bcell [get_db base_cell:$bcell .dont_use]"
        log -info "set_db base_cell:$bcell .dont_use false"
        set_db base_cell:$bcell .dont_use false -quiet
    }

    log -info "::inv::clock::open_cts_cells_dont_touch - END"
}
