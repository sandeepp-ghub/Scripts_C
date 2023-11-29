procedure ::inv::clock::set_via_pillar_rule_on_cts_cells  {
    -short_description "set_via_pillar_rule_on_cts_cells."
    -description       "set_via_pillar_rule_on_cts_cells."
    -example           "::inv::clock::set_via_pillar_rule_on_cts_cells"
    -args              {{args -type string -optional -multiple -description "args list"}}
} {
    global ::CDB
    log -info "::inv::clock::set_via_pillar_rule_on_cts_cells - START"
    if { $::FLOW(via_pillar_switch) } {
        log -info "Via pillar insertion turned on. Setting rules on CTS cells"
    } else {
        log -warn "Via pillar insertion turned off. Not setting rules on CTS cells"
        log -info "::inv::clock::set_via_pillar_rule_on_cts_cells - SKIP"
        return
    }

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
                set trunk_cell [get_db [get_db base_cells DCCKBD24BWP2*H6P5*CNOD$VT DCCKBKAD24BWP2*H6P5*CNOD$VT] .name]
            }
            if {[info exists ::CDB($clk,override_h3_final_cell)]} {
                set final_cell $::CDB($clk,override_h3_final_cell)
            } elseif {[info exists ::CDB(override_h3_final_cell)]} {
                set final_cell $::CDB(override_h3_final_cell)
            } else {
                set VT [lindex $::CDB(clock_cells_vt_class) 0]
                set final_cell [get_db [get_db base_cells DCCKBD16BWP2*H6P5*CNOD$VT DCCKBKAD16BWP2*H6P5*CNOD$VT] .name]
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
    #-- If via pillar is def, also set it to cts & set it as required.
    foreach p $::CDB(clock_pins_for_via_pillar) {
        puts $p
        set pd [lindex [get_db $p .stack_via_list] 0]
        if {$pd ne ""} {
            
            set_db $p  .cts_stack_via_rule_top            $pd
            set_db $p  .cts_stack_via_rule_trunk          $pd                
            set_db $p  .cts_stack_via_rule_leaf           $pd
            set_db $p  .cts_stack_via_rule_required_top   true
            set_db $p  .cts_stack_via_rule_required_trunk true
            set_db $p  .cts_stack_via_rule_required_leaf  true

        } else {
            log -info "WARNING:: via pillar def in missing on pin: $p"
        }
    }

    log -info "::inv::clock::set_via_pillar_rule_on_cts_cells - END"
}
