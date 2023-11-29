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

procedure ::inv::clock::h3_run  {
    -short_description "Set and run flex htree synt.."
    -description       "Set and run flex htree synt."
    -example           "::inv::clock::h3_run"
    -args              {{args -type string -optional -multiple -description "args list"}}
} {
    log -info "::inv::clock::h3_run - START"
    global ::CDB;
    
    # see if mscts_clock_list is empty or not.
    if {![info exists ::CDB(h3_clocks_list)] || $::CDB(h3_clocks_list) eq ""} {
        log -info "::inv::clock::h3_run - SKIP"
        return 1
    }

    # Settings.
    set_db cts_flexible_htree_placement_legalization_effort high



# Advance: set ::CDB(override_h3_grid)            {16 16}
# Advance: set ::CDB($clk,override_h3_grid)       {16 16}
# Advance: set ::CDB(override_h3_trunk_cell)      CKBD24BWP300H8P64PDULVT
# Advance: set ::CDB($clk,override_h3_trunk_cell) CKBD24BWP300H8P64PDULVT
# Advance: set ::CDB(override_h3_final_cell)      CKBD12BWP300H8P64PDULVT
# Advance: set ::CDB($clk,override_h3_final_cell) CKBD12BWP300H8P64PDULVT
# Advance: set ::CDB($clk,override_h3_source)     "after_clock_gate_mux/Z"

    foreach clk $CDB(h3_clocks_list) {
        if {[info exists ::CLOCK(h3_sink_grid_box)] && [llength $::CLOCK(h3_sink_grid_box)] == 4 } {
            set ::CDB(h3_sink_grid_box) $::CLOCK(h3_sink_grid_box)
        }
        # selecting sink_grid_box.
        if {[info exists ::CDB($clk,h3_sink_grid_box)]} {
            set sink_grid_box  "\{$::CDB($clk,h3_sink_grid_box)\}"
        } elseif {[info exists ::CDB(h3_sink_grid_box)]} {
            set sink_grid_box  "\{$::CDB(h3_sink_grid_box)\}"
        } else {
            set sink_grid_box  "\{$::CDB(core_bbox,x0) $::CDB(core_bbox,y0) $::CDB(core_bbox,x1) $::CDB(core_bbox,y1)\}"
        }
        log -info "Sink grid box is set to $sink_grid_box"        


        # get it from settings set ::CDB($clk,added_bol_flags)                   "-no_symmetry_buffers"
        # selecting a grid.
        if {[info exists ::CLOCK(override_h3_grid)] && [llength $::CLOCK(override_h3_grid)] == 2 } {
            set ::CDB(override_h3_grid) $::CLOCK(override_h3_grid)
        }
        if {[info exists ::CDB($clk,override_h3_grid)]} {
            set sink_grid $::CDB($clk,override_h3_grid)
        } elseif {[info exists ::CDB(override_h3_grid)]} {
            set sink_grid $::CDB(override_h3_grid)
            log -info "Sink grid Matrix(override) $sink_grid"
        } else {
            # --select pitch. if grid box is set select max/x/y for the grid box not block.
            set ssink_grid_box [lindex $sink_grid_box 0]
            set max_x [expr [lindex $ssink_grid_box 2] - [lindex $ssink_grid_box 0]]
            set max_y [expr [lindex $ssink_grid_box 3] - [lindex $ssink_grid_box 1]]


            # Get tap to tap pitch.
            if {[info exists ::CLOCK(h3_grid_pitch)] && [llength $::CLOCK(h3_grid_pitch)] == 2 } {
                set ::CDB(h3_grid_pitch) $::CLOCK(h3_grid_pitch)
            }
            if {[info exists ::CDB($clk,h3_grid_pitch)]} {
                set h3_grid_pitch  $::CDB($clk,h3_grid_pitch)
            } elseif {[info exists ::CDB(h3_grid_pitch)]} {
                set h3_grid_pitch $::CDB(h3_grid_pitch)
            } else {
                set h3_grid_pitch {100 100}
            }
            #puts  "h3_grid_pitch -> $h3_grid_pitch"
            set pitch_x   [lindex $h3_grid_pitch 0]
            set pitch_y   [lindex $h3_grid_pitch 1]
            set grid_x    [expr $max_x / $pitch_x]
            set grid_y    [expr $max_y / $pitch_y]
            set grid_x    [expr int($grid_x)]
            set grid_y    [expr int($grid_y)]
            if {$grid_x < 2 } {set grid_x 2}
            if {$grid_y < 2 } {set grid_y 2}
            set sink_grid "$grid_x $grid_y"
            log -info "Sink grid Matrix $sink_grid"

        }
        # selecting a source.
        if {[info exists ::CLOCK(override_h3_source)] && $::CLOCK(override_h3_source) ne "" } {
            set ::CDB($clk,override_h3_source) $::CLOCK(override_h3_source)
        }
        if {[info exists ::CDB($clk,override_h3_source)]} {
            set src  $::CDB($clk,override_h3_source)
        } elseif { [::common::tdb::ipbu_get_key {SYN FLOW multivoltage_flow}] } {
            # if it's a multivoltage block, we may need to move the h3 source from the port, to the downstream
            # levelshifters output pin, because h3 doesn't seem to work through a level shifter
            set clk_src [get_db [get_db clocks -if {.base_name==$clk} ] .sources -u]
            set first_sink [ get_db $clk_src .net.loads.inst]

            if { [llength $first_sink] > 1 } {
                log -warn "When checking h3_source $clk_src for a levelshifter, more than 1 immediate sink cell found.  Flow will assume no levelshifter present because levelshifters must always be the only load"
            }

            if { [llength $first_sink] == 1 && [get_db $first_sink .is_level_shifter] } {
                set first_sink_outpin [get_db [get_db $first_sink .pins] -if {.direction==out}]
                set src $first_sink_outpin
                
            } else {
                set src [get_db [get_db clocks -if {.base_name==$clk} ] .sources -u]
            }
        } else {
            set clk_src [get_db [get_db clocks -if {.base_name==$clk} ] .sources -u]
            set first_sink [ get_db $clk_src .net.loads.inst -if {.base_cell!=*ANT*}]
            if {[llength $first_sink] == 1 && [get_db $first_sink .place_status]=="fixed"} {
                set first_sink_outpin [get_db [get_db $first_sink .pins] -if {.direction==out}]
                set src $first_sink_outpin
            } else {
                set src [get_db [get_db clocks -if {.base_name==$clk} ] .sources -u]
            }

        }
         log -info "Htree source for clock $clk is $src"

        #selecting cells.
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
    

    # Adding bol flags.
        if {[info exists ::CDB($clk,added_h3_flags)]} {
            set cmd $::CDB($clk,added_h3_flags)
        } else {
            # set cmd "-no_symmetry_buffers -image_directory ./report"
            set cmd " -image_directory ./report"
        }
        if {$::CLOCK(htree_mode) eq "distance" } {
            puts "INFO-CMD: create_flexible_htree \
                -name ${clk}_flex_Htree \
                -trunk_cell $trunk_cell  \
                -final_cell $final_cell \
                -sink_instance_prefix FHT \
                -source $src \
                -sink_grid \{$sink_grid\} \
                -sink_grid_box $sink_grid_box \
                -mode distance \
                -max_driver_distance $::CLOCK(h3_max_driver_distance) \
                -max_root_distance   $::CLOCK(h3_max_root_distance) \
                -sink_grid_sink_area \{$::CLOCK(h3_sink_grid_sink_area)\} \
                $cmd"

            eval create_flexible_htree \
                -name ${clk}_flex_Htree \
                -trunk_cell $trunk_cell  \
                -final_cell $final_cell \
                -sink_instance_prefix FHT \
                -source $src \
                -sink_grid \{ $sink_grid \} \
                -sink_grid_box $sink_grid_box \
                -mode distance \
                -max_driver_distance $::CLOCK(h3_max_driver_distance) \
                -max_root_distance   $::CLOCK(h3_max_root_distance) \
                -sink_grid_sink_area \{$::CLOCK(h3_sink_grid_sink_area)\} \
                $cmd
        } else {
            puts "INFO-CMD: create_flexible_htree \
                -name ${clk}_flex_Htree \
                -trunk_cell $trunk_cell  \
                -final_cell $final_cell \
                -sink_instance_prefix FHT \
                -source $src \
                -sink_grid \{$sink_grid\} \
                -sink_grid_box $sink_grid_box \
                -sink_grid_sink_area \{$::CLOCK(h3_sink_grid_sink_area)\} \
                $cmd"

            eval create_flexible_htree \
                -name ${clk}_flex_Htree \
                -trunk_cell $trunk_cell  \
                -final_cell $final_cell \
                -sink_instance_prefix FHT \
                -source $src \
                -sink_grid \{ $sink_grid \} \
                -sink_grid_box $sink_grid_box \
                -sink_grid_sink_area \{$::CLOCK(h3_sink_grid_sink_area)\} \
                $cmd
        }
    }
    # Splitting the cts sinks between the new htree tap points. clone CG and En logic.
    synthesize_flexible_htrees

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
            foreach name $::CLOCK($RR_ovrd_clocks_list) {
                set ctrees [get_db clock_trees -if ".name==*flexible_htree_${name}_flex_Htree*"]
                if {$ctrees eq ""} {puts "Info: No htree clock trees exists for clock $name def at ::CLOCK($RR_ovrd_clocks_list) = $::CLOCK($RR_ovrd_clocks_list)"; continue}
                puts "Setting Routing rule $RR_ovrd_clocks_list on clocks $::CLOCK($RR_ovrd_clocks_list)"
                foreach ctree $ctrees {
                    set_db $ctree .cts_route_type_top   $top_RR_rule 
                    set_db $ctree .cts_route_type_trunk $trunk_RR_rule
                    set_db $ctree .cts_route_type_leaf  $leaf_RR_rule
                }
            }
        }
    }
    log -info "::inv::clock::h3_run - END"
}
