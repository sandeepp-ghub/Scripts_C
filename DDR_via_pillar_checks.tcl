    #-- Get all pins that play at cts stage.
    set ::CDB(clock_cells_for_via_pillar) {}
    set ::CDB(clock_pins_for_via_pillar)  {}
    set ::CDB(clock_cells_for_via_pillar) [concat  $::CDB(clock_cells_for_via_pillar) [get_db base_cells  [get_db cts_buffer_cells       ]]]
    set ::CDB(clock_cells_for_via_pillar) [concat  $::CDB(clock_cells_for_via_pillar) [get_db base_cells  [get_db cts_inverter_cells     ]]]
    set ::CDB(clock_cells_for_via_pillar) [concat  $::CDB(clock_cells_for_via_pillar) [get_db base_cells  [get_db cts_clock_gating_cells ]]]
    set ::CDB(clock_cells_for_via_pillar) [concat  $::CDB(clock_cells_for_via_pillar) [get_db base_cells  [get_db cts_logic_cells        ]]]

    #-- Htree root buffers may not be part of the cts cells. we still like to have vp on them.
    # see if mscts_clock_list is empty or not.
    if {![info exists ::CDB(h3_clocks_list)] || $::CDB(h3_clocks_list) eq ""} {
        log -info "No Htree buffers."      
    } else {
        foreach clk $CDB(h3_clocks_list) {
            if {[info exists ::CDB($clk,override_h3_trunk_cell)]} {
                set trunk_cell $::CDB($clk,override_h3_trunk_cell)
            } elseif {[info exists ::CDB(override_h3_trunk_cell)]} {
                set trunk_cell $::CDB(override_h3_trunk_cell)
            } else {
                set VT [lindex $::CDB(clock_cells_vt_class) 0]
                set trunk_cell [get_db [get_db base_cells DCCKBD24BWP2*H6P5*CNOD$VT] .name]
            }
            if {[info exists ::CDB($clk,override_h3_final_cell)]} {
                set final_cell $::CDB($clk,override_h3_final_cell)
            } elseif {[info exists ::CDB(override_h3_final_cell)]} {
                set final_cell $::CDB(override_h3_final_cell)
            } else {
                set VT [lindex $::CDB(clock_cells_vt_class) 0]
                set final_cell [get_db [get_db base_cells DCCKBD16BWP2*H6P5*CNOD$VT] .name]
            }
            set fc [get_db base_cells $final_cell]
            set tc [get_db base_cells $trunk_cell]
            set ::CDB(clock_cells_for_via_pillar) [concat  $::CDB(clock_cells_for_via_pillar) $fc]
            set ::CDB(clock_cells_for_via_pillar) [concat  $::CDB(clock_cells_for_via_pillar) $tc]
        }
    }
    #-- Moving from cells to pins.
    foreach c $::CDB(clock_cells_for_via_pillar) {
        set pins [get_db base_pins -if {.base_cell==$c}]
        set ::CDB(clock_pins_for_via_pillar) [concat $::CDB(clock_pins_for_via_pillar) $pins]
    }

