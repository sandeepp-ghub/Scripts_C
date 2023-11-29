### ************************************************************************
### *                                                                      *
### *  MARVELL CONFIDENTIAL AND PROPRIETARY NOTE                           *
### *                                                                      *
### *  This software contains information confidential and proprietary     *
### *  to Marvell, Inc. It shall not be reproduced in whole or in part,    *
### *  or transferred to other documents, or disclosed to third parties,   *
### *  or used for any purpose other than that for which it was obtained,  *
### *  without the prior written consent of Marvell, Inc.                  *
### *                                                                      *
### *  Copyright 2019-2019, Marvell, Inc.  All rights reserved.            *
### *                                                                      *
### ************************************************************************
### * Author      : Lior Allerhand (lioral)
### * Description : 
### ************************************************************************


procedure ::inv::clock::build_clock_tree_spec {


} {
    log -info "::inv::clock::build_clock_tree_spec - START"

    # Ex.
    #
    # add_clock_tree_exclusion_drivers ...
    #
    # create_skew_group -name SG2 -sources top -exclusive_sinks [get_ccopt_clock_tree_sinks *XYZ*/CK]
    #
    # set_clock_latency ...
    #
    # set_db pin:<pin> .cts_pin_insertion_delay [-index skew_group:<>] 
    # A positive value will pull the clock pin up the tree (less CTS delay)
    # A negative value will push the clock pin down the tree (more CTS delay)
    #
    # create custom skew group and apply target insertion delay
    # create_skew_group -name custom_sg \
    #              -source $sinks_source \
    #              -exclusive_sinks { SINK1/CLK SINK2/CLK } \
    #              -rank 100
    # set_db skew_group:custom_sg .cts_target_insertion_delay <>
    #
    # remove sinks from existing skew groups
    # foreach sg_sink_pin $clock_control_enable_cell_clock_pins {
    #   foreach sg [get_db pin:$sg_sink_pin .skew_groups_active_sink] { 
    #     update_skew_group -name $sg -remove_sinks $sg_sink_pin 
    #   }
    # }
    #
    # For mscts and htree the next commands are been set at pre-cts build. 
    # create_clock_tree
    # add_clock_tree_exclusion_drivers
    # create_clock_tree_source_group
    # add_clock_tree_source_group_roots
    # create_generated_clock_tree
    

    # In order to take any memory lib reco clock latency two thing need to exists. flow flag is on and some macro exists at design.
    if {[info exists ::CLOCK(convert_lib_clock_tree_latencies)] && $::CLOCK(convert_lib_clock_tree_latencies) && [llength [get_db insts -if {.is_macro==true || .is_memory==true}]] > 0} {
        convert_lib_clock_tree_latencies -sum_existing_latencies
    }

    if {[info exists ::CLOCK(skip_scan_scenario_at_clock_spec_writing)] && $::CLOCK(skip_scan_scenario_at_clock_spec_writing)} {
        create_clock_tree_spec -out_file ./datain/clock_tree.spec -views [get_db analysis_views  -if {.name!=*scan*}]
    } elseif {[info exists ::CLOCK(skip_shift_scenario_at_clock_spec_writing)] && $::CLOCK(skip_shift_scenario_at_clock_spec_writing)} {
        create_clock_tree_spec -out_file ./datain/clock_tree.spec -views [get_db analysis_views  -if {.name!=*shift*}]
    } else {
        create_clock_tree_spec -out_file ./datain/clock_tree.spec
    }
    source  ./datain/clock_tree.spec


    # IPBUBF-2492 - Bug fix, remove scan/shift skew groups before going to ccopt (if needed). 
    # In case of number of clocks block shift mode may force ccopt to balance all clocks sink point together as they are all part of the shift clock skew group.
    if {[info exists ::CLOCK(remove_shift_mode_skew_groups)] && $::CLOCK(remove_shift_mode_skew_groups)} {
        # Delete all the shift modes before building the clock
        foreach shift_modes [get_db [get_db skew_groups -if {.name==*shift*}] .name] {
            delete_skew_groups $shift_modes
        }
    }
    if {[info exists ::CLOCK(remove_scan_mode_skew_groups)] && $::CLOCK(remove_scan_mode_skew_groups)} {
        # Delete all the shift modes before building the clock
        foreach scan_modes [get_db [get_db skew_groups -if {.name==*scan*}] .name] {
            delete_skew_groups $scan_modes
        }
    }
    # IPBUBF-2492 - Bug fix -End #


    # The command traces the clock tree as defined by the CTS spec and sets net attributes  to  allow  early-global-
    # route to more predictably model clock nets. It sets isClock and isCTSClock on clock tree nets in the database.
    # It applies routing preferences such as:  top_preferred_layer,  bottom_preferred_layer,  non_default_rule,  and
    # shield_net  based on the route_type CTS properties.
    commit_clock_tree_route_attributes


    # JIRA IPBUBF-3642 Need to be able to specify shielding for a given CTS clock. Setting a no-def' NDR can only be done on clock tree. We have clock trees only after reading the clock spec.
    foreach  RR_ovrd_clocks_list {1w1s_shielded_RR_ovrd_clocks_list 1w2s_shielded_RR_ovrd_clocks_list 1w2s_not_shielded_RR_ovrd_clocks_list 2w1s_shielded_RR_ovrd_clocks_list 2w2s_shielded_RR_ovrd_clocks_list} {
        # set the rule name.
        if {$RR_ovrd_clocks_list eq "1w1s_shielded_RR_ovrd_clocks_list"}     {set top_RR_rule "top_rule_1w1s_shielded"; set trunk_RR_rule "trunk_rule_1w1s_shielded"; set leaf_RR_rule "leaf_rule_1w1s_shielded"}
        if {$RR_ovrd_clocks_list eq "1w2s_shielded_RR_ovrd_clocks_list"}     {set top_RR_rule "top_rule_1w2s_shielded"; set trunk_RR_rule "trunk_rule_1w2s_shielded"; set leaf_RR_rule "leaf_rule_1w2s_shielded"}
        if {$RR_ovrd_clocks_list eq "1w2s_not_shielded_RR_ovrd_clocks_list"} {set top_RR_rule "top_rule_1w2s";          set trunk_RR_rule "trunk_rule_1w2s";          set leaf_RR_rule "leaf_rule_1w2s"         }
        if {$RR_ovrd_clocks_list eq "2w1s_shielded_RR_ovrd_clocks_list"}     {set top_RR_rule "top_rule_2w1s_shielded"; set trunk_RR_rule "trunk_rule_2w1s_shielded"; set leaf_RR_rule "leaf_rule_2w1s_shielded"}
        if {$RR_ovrd_clocks_list eq "2w2s_shielded_RR_ovrd_clocks_list"}     {set top_RR_rule "top_rule_2w2s_shielded"; set trunk_RR_rule "trunk_rule_2w2s_shielded"; set leaf_RR_rule "leaf_rule_2w2s_shielded"}
        # set rule.
        if {[info exists ::CLOCK($RR_ovrd_clocks_list)] && $::CLOCK($RR_ovrd_clocks_list) ne ""} {
            # IPBUBF-3793 - Bug fix, if a clock is sen on > 1 ports the tree set postfix <\d+> I am adding the postfix to a regexp with * to take also the orig clock tree name in case postfix do not exists, , and a ^ to make sure no other names exists with the same tail.
            set post {[\<\d\>]*}
            foreach name $::CLOCK($RR_ovrd_clocks_list) {
                set new_name ${name}${post}
                set ctrees [get_db clock_trees -regexp ^$new_name]                
                if {$ctrees eq ""} {puts "Info: No  clock trees exists for clock $name def at ::CLOCK($RR_ovrd_clocks_list) = $::CLOCK($RR_ovrd_clocks_list)"; continue}
                puts "Setting Routing rule $RR_ovrd_clocks_list on clocks $::CLOCK($RR_ovrd_clocks_list)"
                foreach ctree $ctrees {
                    set_db $ctree .cts_route_type_top   $top_RR_rule 
                    set_db $ctree .cts_route_type_trunk $trunk_RR_rule
                    set_db $ctree .cts_route_type_leaf  $leaf_RR_rule
                }
            }
        }
    }






    if {[info exists ::CLOCK(top_and_trunk_shielding_clock_list)] && $::CLOCK(top_and_trunk_shielding_clock_list) ne ""} {
        foreach name $::CLOCK(top_and_trunk_shielding_clock_list) {
            set ctrees [get_db clock_trees -if {.name==$name}]
            if {$ctrees eq ""} {puts "Warning: No clock trees exists for clock $name def at ::CLOCK(top_and_trunk_shielding_clock_list) = $::CLOCK(top_and_trunk_shielding_clock_list)"; continue}
            foreach ctree $ctrees {
                set_db $ctree .cts_route_type_trunk trunk_shield_rule
                set_db $ctree .cts_route_type_top   top_shield_rule 
            }
        }
    }

    log -info "::inv::clock::build_clock_tree_spec - END"

}
