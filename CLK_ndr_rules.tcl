

procedure ::inv::clock::mscts_set_ndr_rules  {
    -short_description "Set NDR rule specific to cts wire. "
    -description       "Set NDR rule specific to cts wire. "
    -example           "::inv::clock::mscts_set_ndr_rule"
    -args              {{args -type string -optional -multiple -description "args list"}}
} {

    log -info "::inv::clock::mscts_set_ndr_rule - START"
    # IPBUBF-4018 - It is not recommended to use hard coded names in procs.
    set layers [get_db layers -if {.type == routing}]
    set VSS [::common::upf::get_block_ground_net]
    # IPBUBF-4156 - Htree ndr cts_top_and_trunk_ndr -> cts_trunk_ndr & cts_top_ndr need to keep back comp to not crush runs.
    if {$::CLOCK(cts_top_and_trunk_ndr) ne "none"} {
        set ::CLOCK(cts_top_ndr)   $::CLOCK(cts_top_and_trunk_ndr)
        set ::CLOCK(cts_trunk_ndr) $::CLOCK(cts_top_and_trunk_ndr)
    }
    puts "-----------------------------------------------------------------"
    puts "| name      | direction  | min_width | min_spacing  | num_masks |" 
    puts "-----------------------------------------------------------------"
    foreach layer $layers {
        set name        [get_db $layer .name]
        set direction   [get_db $layer .direction]
        set min_width   [get_db $layer .min_width]
        set min_spacing [get_db $layer .min_spacing]
        set num_masks   [get_db $layer .num_masks]
        puts [format "| %-*s | %-*s | %-*s | %-*s | %-*s |" 9 $name 10 $direction 9 $min_width 12 $min_spacing 9 $num_masks]
    }
    puts "-----------------------------------------------------------------"


    # Set cts routing rules
    if {[get_db route_rules hscd_ndr] eq ""} {create_route_rule -name hscd_ndr -width_multiplier {M5:M14 2} -spacing_multiplier {M5:M10 2.5 M11:M14 2}}
    if {[get_db route_rules 2w2s_ndr] eq ""} {create_route_rule -name 2w2s_ndr -width_multiplier {M5:M12 2} -spacing_multiplier {M5:M12 2}}
    if {[get_db route_rules 3w2s_ndr] eq ""} {create_route_rule -name 3w2s_ndr -width_multiplier {M5:M12 3} -spacing_multiplier {M5:M12 2}}
    if {[get_db route_rules 2w1s_ndr] eq ""} {create_route_rule -name 2w1s_ndr -width_multiplier {M5:M12 2}                               }
    if {[get_db route_rules 1w2s_ndr] eq ""} {create_route_rule -name 1w2s_ndr                              -spacing_multiplier {M5:M12 2}}
    if {[get_db route_rules 1w1s_ndr] eq ""} {create_route_rule -name 1w1s_ndr                                                            }

    if {[get_db route_rules hs_top_ndr] eq ""}   {create_route_rule -name hs_top_ndr   -width_multiplier {M5:M12 2} -spacing_multiplier {M5:M12 2} -hard_spacing}
    if {[get_db route_rules hs_trunk_ndr] eq ""} {create_route_rule -name hs_trunk_ndr -width_multiplier {M5:M12 2} -spacing_multiplier {M5:M12 2} -hard_spacing}
    if {[get_db route_rules hs_leaf_ndr] eq ""}  {create_route_rule -name hs_leaf_ndr  -width_multiplier {M5:M12 2} -spacing_multiplier {M5:M12 2} -hard_spacing}

    if {[get_db route_rules 2w2s_htree_ndr] eq ""} {create_route_rule -name 2w2s_htree_ndr -width_multiplier {M5:M14 2} -spacing_multiplier {M5:M14 2}}
    if {[get_db route_rules 3w2s_htree_ndr] eq ""} {create_route_rule -name 3w2s_htree_ndr -width_multiplier {M5:M14 3} -spacing_multiplier {M5:M14 2}}
    if {[get_db route_rules 2w1s_htree_ndr] eq ""} {create_route_rule -name 2w1s_htree_ndr -width_multiplier {M5:M14 2}                               }
    if {[get_db route_rules 1w2s_htree_ndr] eq ""} {create_route_rule -name 1w2s_htree_ndr                              -spacing_multiplier {M5:M14 2}}
    if {[get_db route_rules 1w1s_htree_ndr] eq ""} {create_route_rule -name 1w1s_htree_ndr                                                            }

    # IPBUBF-3703 - set Number of routing rules preset.
    #1. 1w1s_shielded_RR_ovrd_clocks_list
        if {[get_db route_types top_rule_1w1s_shielded] eq "" } { 
            create_route_type -name top_rule_1w1s_shielded   -route_rule 1w1s_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -shield_net $VSS
        }
        if {[get_db route_types trunk_rule_1w1s_shielded] eq "" } {
            create_route_type -name trunk_rule_1w1s_shielded -route_rule 1w1s_ndr\
            -top_preferred_layer M12 -bottom_preferred_layer M11 -shield_net $VSS
        }
        if {[get_db route_types leaf_rule_1w1s_shielded] eq "" } {
            create_route_type -name leaf_rule_1w1s_shielded  -route_rule 1w1s_ndr\
            -top_preferred_layer M8 -bottom_preferred_layer M5
        }

    #2. 1w2s_shielded_RR_ovrd_clocks_list
        if {[get_db route_types top_rule_1w2s_shielded] eq "" } { 
            create_route_type -name top_rule_1w2s_shielded   -route_rule 1w2s_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -shield_net $VSS
        }
        if {[get_db route_types trunk_rule_1w2s_shielded] eq "" } {
            create_route_type -name trunk_rule_1w2s_shielded -route_rule 1w2s_ndr\
            -top_preferred_layer M12 -bottom_preferred_layer M11 -shield_net $VSS
        }
        if {[get_db route_types leaf_rule_1w2s_shielded] eq "" } {
            create_route_type -name leaf_rule_1w2s_shielded  -route_rule 1w2s_ndr\
            -top_preferred_layer M8 -bottom_preferred_layer M5
        }

    #3. 1w2s_not_shielded_RR_ovrd_clocks_list
        if {[get_db route_types top_rule_1w2s] eq "" } { 
            create_route_type -name top_rule_1w2s   -route_rule 1w2s_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M13 
        }
        if {[get_db route_types trunk_rule_1w2s] eq "" } {
            create_route_type -name trunk_rule_1w2s -route_rule 1w2s_ndr\
            -top_preferred_layer M12 -bottom_preferred_layer M11
        }
        if {[get_db route_types leaf_rule_1w2s] eq "" } {
            create_route_type -name leaf_rule_1w2s  -route_rule 1w2s_ndr\
            -top_preferred_layer M8 -bottom_preferred_layer M5
        }

    #4. 2w1s_shielded_RR_ovrd_clocks_list
        if {[get_db route_types top_rule_2w1s_shielded] eq "" } { 
            create_route_type -name top_rule_2w1s_shielded   -route_rule 2w1s_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -shield_net $VSS
        }
        if {[get_db route_types trunk_rule_2w1s_shielded] eq "" } {
            create_route_type -name trunk_rule_2w1s_shielded -route_rule 2w1s_ndr\
            -top_preferred_layer M12 -bottom_preferred_layer M11 -shield_net $VSS
        }
        if {[get_db route_types leaf_rule_2w1s_shielded] eq "" } {
            create_route_type -name leaf_rule_2w1s_shielded  -route_rule 2w1s_ndr\
            -top_preferred_layer M8 -bottom_preferred_layer M5
        }

    #5. 2w2s_shielded_RR_ovrd_clocks_list
        if {[get_db route_types top_rule_2w2s_shielded] eq "" } { 
            create_route_type -name top_rule_2w2s_shielded   -route_rule 2w2s_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -shield_net $VSS
        }
        if {[get_db route_types trunk_rule_2w2s_shielded] eq "" } {
            create_route_type -name trunk_rule_2w2s_shielded -route_rule 2w2s_ndr\
            -top_preferred_layer M12 -bottom_preferred_layer M11 -shield_net $VSS
        }
        if {[get_db route_types leaf_rule_2w2s_shielded] eq "" } {
            create_route_type -name leaf_rule_2w2s_shielded  -route_rule 2w2s_ndr\
            -top_preferred_layer M8 -bottom_preferred_layer M5
        }
    # IPBUBF-3703 - End



    if {$::CLOCK(cts_preferred_layer_type) ne "custom"} {
        log -info "leaf  route_rules is set to  == $::CLOCK(cts_leaf_ndr)"
        log -info "trunk route_rules is set to  == $::CLOCK(cts_trunk_ndr)"
        log -info "top   route_rules is set to  == $::CLOCK(cts_top_ndr)"
    }
    
    if {$::CLOCK(cts_preferred_layer_type) eq "hscd"} {
        log -info "using cts_preferred_layer_type == hscd"
        # Set cts route type
        if {[get_db route_types leaf_rule] eq "" } {
            create_route_type -name leaf_rule  -route_rule hscd_ndr \
            -top_preferred_layer M8 -bottom_preferred_layer M1
        }
        if {[get_db route_types trunk_rule] eq "" } {
            create_route_type -name trunk_rule -route_rule hscd_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M6
        }
        if {[get_db route_types trunk_shield_rule] eq "" } {
            create_route_type -name trunk_shield_rule -route_rule hscd_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M6 -shield_net $VSS
        }
        if {[get_db route_types top_rule] eq "" } { 
            create_route_type -name top_rule   -route_rule hscd_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M11
        }
        if {[get_db route_types top_shield_rule] eq "" } { 
            create_route_type -name top_shield_rule   -route_rule hscd_ndr \
            -top_preferred_layer M14 -bottom_preferred_layer M11 -shield_net $VSS
        }

    }
    if {$::CLOCK(cts_preferred_layer_type) eq "high_performance"} {
        log -info "using cts_preferred_layer_type == high_performance"
        # Set cts route type
        if {[get_db route_types leaf_rule] eq "" } {
            create_route_type -name leaf_rule  -route_rule $::CLOCK(cts_leaf_ndr) \
            -top_preferred_layer M8 -bottom_preferred_layer M5
        }
        if {[get_db route_types trunk_rule] eq "" } {
            create_route_type -name trunk_rule -route_rule $::CLOCK(cts_trunk_ndr) \
            -top_preferred_layer M12 -bottom_preferred_layer M11
        }
        if {[get_db route_types trunk_shield_rule] eq "" } {
            create_route_type -name trunk_shield_rule -route_rule $::CLOCK(cts_trunk_ndr) \
            -top_preferred_layer M12 -bottom_preferred_layer M11 -shield_net $VSS
        }
        if {[get_db route_types top_rule] eq "" } { 
            create_route_type -name top_rule   -route_rule $::CLOCK(cts_top_ndr) \
            -top_preferred_layer M14 -bottom_preferred_layer M13
        }
        if {[get_db route_types top_shield_rule] eq "" } { 
            create_route_type -name top_shield_rule   -route_rule $::CLOCK(cts_top_ndr) \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -shield_net $VSS
        }

    }    

    if {$::CLOCK(cts_preferred_layer_type) eq "hs_high_performance"} {
        log -info "using cts_preferred_layer_type == hs_high_performance"
        # Set cts route type
        if {[get_db route_types leaf_rule] eq "" } {
            create_route_type -name leaf_rule  -route_rule $::CLOCK(cts_leaf_ndr) \
            -top_preferred_layer M8 -bottom_preferred_layer M5 -preferred_routing_layer_effort medium
        }
        if {[get_db route_types trunk_rule] eq "" } {
            create_route_type -name trunk_rule -route_rule $::CLOCK(cts_trunk_ndr) \
            -top_preferred_layer M12 -bottom_preferred_layer M11 -preferred_routing_layer_effort medium
        }
        if {[get_db route_types trunk_shield_rule] eq "" } {
            create_route_type -name trunk_shield_rule -route_rule $::CLOCK(cts_trunk_ndr) \
            -top_preferred_layer M12 -bottom_preferred_layer M11 -shield_net $VSS -preferred_routing_layer_effort medium
        }
        if {[get_db route_types top_rule] eq "" } { 
            create_route_type -name top_rule   -route_rule $::CLOCK(cts_top_ndr) \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -preferred_routing_layer_effort medium
        }
        if {[get_db route_types top_shield_rule] eq "" } { 
            create_route_type -name top_shield_rule   -route_rule $::CLOCK(cts_top_ndr) \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -shield_net $VSS  -preferred_routing_layer_effort medium
        }

    }    

    if {$::CLOCK(cts_preferred_layer_type) eq "easy"} {
        log -info "using cts_preferred_layer_type == easy"
        # Set cts route type
        # Set cts route type
        if {[get_db route_types leaf_rule] eq "" } {
            create_route_type -name leaf_rule  -route_rule $::CLOCK(cts_leaf_ndr) \
            -top_preferred_layer M6 -bottom_preferred_layer M5
        }
        if {[get_db route_types trunk_rule] eq "" } {
            create_route_type -name trunk_rule -route_rule $::CLOCK(cts_trunk_ndr) \
            -top_preferred_layer M8 -bottom_preferred_layer M7
        }
        if {[get_db route_types trunk_shield_rule] eq "" } {
            create_route_type -name trunk_shield_rule -route_rule $::CLOCK(cts_trunk_ndr) \
            -top_preferred_layer M8 -bottom_preferred_layer M7 -shield_net $VSS
        }
        if {[get_db route_types top_rule] eq "" } { 
            create_route_type -name top_rule   -route_rule $::CLOCK(cts_top_ndr) \
            -top_preferred_layer M14 -bottom_preferred_layer M13
        }
        if {[get_db route_types top_shield_rule] eq "" } { 
            create_route_type -name top_shield_rule   -route_rule $::CLOCK(cts_top_ndr) \
            -top_preferred_layer M14 -bottom_preferred_layer M13 -shield_net $VSS
        }

    }

    if {$::CLOCK(cts_preferred_layer_type) eq "custom"} {
        log -info "using cts_preferred_layer_type == custom"
        
        
        set  cts_leaf_ndr_custom_rule  $::CLOCK(cts_leaf_ndr_custom_rule) 
        set  cts_trunk_ndr_custom_rule $::CLOCK(cts_trunk_ndr_custom_rule) 
        set  cts_top_ndr_custom_rule   $::CLOCK(cts_top_ndr_custom_rule)
               
        
        lassign $cts_leaf_ndr_custom_rule leaf_width_mult leaf_spc_mult leaf_min_cut_mult leaf_prefered_bot leaf_prefered_top
        lassign $cts_top_ndr_custom_rule top_width_mult top_spc_mult top_min_cut_mult top_prefered_bot top_prefered_top
        lassign $cts_trunk_ndr_custom_rule trunk_width_mult trunk_spc_mult trunk_min_cut_mult trunk_prefered_bot trunk_prefered_top
        
        
        
        if {[llength $cts_leaf_ndr_custom_rule] < 5 || [llength $leaf_width_mult] == 0 || [llength $leaf_spc_mult] == 0 || [llength $leaf_min_cut_mult] == 0 } {
            log -error "Missing one of the leaf_ndr_custom_rule definitions. check $::CLOCK(cts_leaf_ndr_custom_rule)"   
        }
    
    
        if {[llength $cts_trunk_ndr_custom_rule] < 5 || [llength $trunk_width_mult] == 0 || [llength $trunk_spc_mult] == 0 || [llength $trunk_min_cut_mult] == 0 } {
            log -error "Missing one of the trunk_ndr_custom_rule definitions. check $::CLOCK(cts_trunk_ndr_custom_rule)"   
        }
    
        if {[llength $cts_top_ndr_custom_rule] < 5 || [llength $top_width_mult] == 0 || [llength $top_spc_mult] == 0 || [llength $top_min_cut_mult] == 0 } {
            log -error "Missing one of the top_ndr_custom_rule definitions. check $::CLOCK(cts_top_ndr_custom_rule)"   
        }    


           
        create_route_rule -name custom_leaf -width_multiplier "$leaf_width_mult" -spacing_multiplier "$leaf_spc_mult" -min_cut "$leaf_min_cut_mult"
        create_route_rule -name custom_top -width_multiplier "$top_width_mult" -spacing_multiplier "$top_spc_mult" -min_cut "$top_min_cut_mult"
        create_route_rule -name custom_trunk -width_multiplier "$trunk_width_mult" -spacing_multiplier "$trunk_spc_mult" -min_cut "$trunk_min_cut_mult"
        
        
        log -info "leaf  route_rules is set to  == custom_leaf"
        log -info "trunk route_rules is set to  == custom_trunk"
        log -info "top route_rules is set to    == custom_top"
        # Set cts route type
        if {[get_db route_types leaf_rule] eq "" } {
            create_route_type -name leaf_rule  -route_rule custom_leaf \
            -top_preferred_layer $leaf_prefered_top -bottom_preferred_layer $leaf_prefered_bot
        }
        if {[get_db route_types trunk_rule] eq "" } {
            create_route_type -name trunk_rule -route_rule custom_trunk \
            -top_preferred_layer $trunk_prefered_top -bottom_preferred_layer $trunk_prefered_bot
        }
        if {[get_db route_types trunk_shield_rule] eq "" } {
            create_route_type -name trunk_shield_rule -route_rule custom_trunk \
            -top_preferred_layer $trunk_prefered_top -bottom_preferred_layer $trunk_prefered_bot -shield_net $VSS
        }
        if {[get_db route_types top_rule] eq "" } { 
            create_route_type -name top_rule   -route_rule custom_top \
            -top_preferred_layer $top_prefered_top -bottom_preferred_layer $top_prefered_bot
        }
       if {[get_db route_types top_shield_rule] eq "" } { 
            create_route_type -name top_shield_rule   -route_rule custom_top \
            -top_preferred_layer $top_prefered_top -bottom_preferred_layer $top_prefered_bot -shield_net $VSS
        }

    }
    

    #Add  -shield_net VSS  if needed

    # Apply routing types to cts route    
    set_db cts_route_type_leaf    leaf_rule
    set_db cts_route_type_top     top_rule
    set_db cts_route_type_trunk   trunk_rule
    
    if {[info exists ::CLOCK(shield_trunk)] && $::CLOCK(shield_trunk) eq "1"} {
        set_db cts_route_type_trunk trunk_shield_rule
    } else {
        
    }
    if {[info exists ::CLOCK(shield_top)] && $::CLOCK(shield_top) eq "1"} {
        set_db cts_route_type_top top_shield_rule
    } else {
        
    }

    #set_db clock_tree:CLK .cts_route_type_trunk CLK_NDR ;# if needed we can add route type pr clock tree


    log -info "::inv::clock::mscts_set_ndr_rule - END"
}
