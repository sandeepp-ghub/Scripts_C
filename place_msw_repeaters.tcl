##Using Rahul M's Msh rptr script
#V2 : Added msh_rptr_M14 proc for tdh/cdh

####tdh variables
#set msh_rptr_var(valid_bits_regex) {*msh*dat[429] *msh*req[176] *msh*rsp[165] *msh*rsp[82] *msh*snp[139] }
#set msh_rptr_var(lftedge_in_flops_x) 469.3585
#set msh_rptr_var(rgtedge_in_flops_x) 569.3585
#set msh_rptr_var(w2e_i_loc) {440 330 170 20}
#set msh_rptr_var(w2e_o_loc) {460 570 720 820 1020}
#set msh_rptr_var(e2w_i_loc) {560 710 810 1030}
#set msh_rptr_var(e2w_o_loc) {540 460 310 160 10}

###tdv variables
#set msh_rptr_var(valid_bits_regex) {*msh*dat[429] *msh*req[176] *msh*rsp[165] *msh*rsp[82] *msh*snp[139] }
#set msh_rptr_var(botedge_in_flops_y) 840 
#set msh_rptr_var(topedge_in_flops_y) 980
#set msh_rptr_var(n2s_i_loc) {1000 1150 1340 1545 1685 1805}
#set msh_rptr_var(n2s_o_loc) {970 860 730 580 370 220 20}
#set msh_rptr_var(s2n_i_loc) {850 720 590 380 230 10}
#set msh_rptr_var(s2n_o_loc) {860 1010 1140 1330 1535 1675 1795}

set block_name [get_db current_design .name]

namespace eval msh_rptrs_M14 {
#    variable valid_bits_regex {*msh*dat[429] *msh*req[176] *msh*rsp[165] *msh*rsp[82] *msh*snp[139] }
#    variable hier_w2e msh_rpt/flop_msw_flp
#    variable hier_e2w msh_rpt/flop_msh_flp



if { ${block_name} == "pcl_til_tdh" || ${block_name} == "pcl_til_cdh" || ${block_name} == "pcl_til_rch"} {
    if {[info exists ::msh_rptr_var(lftedge_in_flops_x)] } {
        variable lftedge_in_flops_x  $::msh_rptr_var(lftedge_in_flops_x)
    } else {
        variable design_x2 [get_db current_design .bbox.ur.x]
        variable lftedge_in_flops_x  [expr (${design_x2}/2) - 50]
    }
    
    if {[info exists ::msh_rptr_var(rgtedge_in_flops_x)] } {
        variable rgtedge_in_flops_x  $::msh_rptr_var(rgtedge_in_flops_x)
    } else {
        variable design_x2 [get_db current_design .bbox.ur.x]
        variable rgtedge_in_flops_x  [expr (${design_x2}/2) + 50]
    }
    
    if {[info exists ::msh_rptr_var(valid_bits_regex)] } {
        variable  valid_bits_regex  $::msh_rptr_var(valid_bits_regex)
    } 
    
    if {[info exists ::msh_rptr_var(w2e_i_loc)] } {
        variable w2e_i_loc  $::msh_rptr_var(w2e_i_loc)
        variable n_of_loc [llength $w2e_i_loc]
        if { [expr ${n_of_loc} % 2 ]} {
            puts "odd number of values {${w2e_i_loc}} for w2e_i_loc "
            return
           } 
    } else {
        puts "w2e_i_loc varible is not set; provide Even number of values in decreasing order "
        return
    }
    
    if {[info exists ::msh_rptr_var(w2e_o_loc)] } {
        variable w2e_o_loc  $::msh_rptr_var(w2e_o_loc)
        variable n_of_loc [llength $w2e_o_loc]
        if { ![expr ${n_of_loc} % 2 ]} {
            puts "Even number of values {${w2e_o_loc}} for w2e_o_loc "
            puts "w2e_o_loc variable needs to be odd (1Buff + 2*n inv)"
            return
           } 
    } else {
        puts "w2e_o_loc varible is not set; provide odd number of values in increasing order"
        return
    }
    
    if {[info exists ::msh_rptr_var(e2w_i_loc)] } {
        variable e2w_i_loc  $::msh_rptr_var(e2w_i_loc)
        variable n_of_loc [llength $e2w_i_loc]
        if { [expr ${n_of_loc} % 2 ]} {
            puts "odd number of values {${e2w_i_loc}} for e2w_i_loc "
            return
           } 
    } else {
        puts "e2w_i_loc varible is not set; provide Even number of values in increasing order"
        return
    }
    
    if {[info exists ::msh_rptr_var(e2w_o_loc)] } {
        variable e2w_o_loc  $::msh_rptr_var(e2w_o_loc)
        variable n_of_loc [llength $e2w_o_loc]
        if { ![expr ${n_of_loc} % 2 ]} {
            puts "Even number of values {${e2w_o_loc}} for e2w_o_loc "
            puts "e2w_o_loc variable needs to be odd (1Buff + 2*n inv)"
            return
           } 
    } else {
        puts "e2w_o_loc varible is not set; provide odd number of values in decreasing order"
        return
    }

}

    
    proc place_msw_rptrs {} {
        
        #E2W nets msw__msh (i) til__msh* (o)
        #W2E nets msh__til (i) msh__msw* (o)


        #input ports on left edge to flops
        set w2e_i_nets [get_db [get_db ports msh__til*] .net.name]
        #Flops to output ports on right edge
        set w2e_o_nets [::msh_rptrs_M14::_find_start_nets_of_ports msh__msw*]
        #input ports on right edge to flops
        set e2w_i_nets [get_db [get_db ports msw__msh*] .net.name]
        #Flops to output ports on left edge
        set e2w_o_nets [::msh_rptrs_M14::_find_start_nets_of_ports til__msh*]

        #First we will delete the buffer tree if any on these nets
        set tad_wires_f "tad_delete_buffer_wires.name"
        set FH [open $tad_wires_f w]
        foreach msh_net [concat $w2e_i_nets $w2e_o_nets $e2w_i_nets $e2w_o_nets] {
            puts $FH $msh_net
        }
        close $FH

        set old_no_assign_setting [get_db init_no_new_assigns]
        set_db init_no_new_assigns 0
        delete_buffer_trees -nets_file $tad_wires_f
        set_db init_no_new_assigns $old_no_assign_setting
        #

        # Now place the *msh* flops
        #reset the nets after buffer tree deletion

        set w2e_o_nets [::msh_rptrs_M14::_find_start_nets_of_ports msh__msw*]
        set e2w_o_nets [::msh_rptrs_M14::_find_start_nets_of_ports til__msh*]

#        set_dont_touch [concat {*}$w2e_i_nets {*}$w2e_o_nets {*}$e2w_i_nets {*}$e2w_o_nets]
        
        set all_flps {}
        #w2e flops
        lappend all_flps [::msh_rptrs_M14::place_msh_flps [list \
                                                           nets $w2e_i_nets\
                                                           location $::msh_rptrs_M14::lftedge_in_flops_x\
                                                           direction "w2e"\
                                                          ]]
        #e2w flops
        lappend all_flps [::msh_rptrs_M14::place_msh_flps [list \
                                                           nets $e2w_i_nets\
                                                           location $::msh_rptrs_M14::rgtedge_in_flops_x\
                                                           direction "e2w"\
                                                          ]]

        #legalize and fixed placement
        #padding to reduce dynamic ir/m1 short issues
        set all_flps [concat {*}$all_flps]
        set_db place_detail_honor_inst_pad true
        
        foreach inst $all_flps {
            set scale_factor 0.5
            set padding_site  [expr int(round([get_db inst:$inst .base_cell.bbox.dx] / [get_db site:core .size.x]) * $scale_factor)]
            set cmd "set_inst_padding -inst $inst -left_side $padding_site -right_side $padding_site -top_side 1 -bottom_side 1"
            ipbu_info $cmd
            eval $cmd
        }
        
        set_db place_detail_eco_max_distance 20
        place_detail -inst $all_flps
        set_db [get_db insts $all_flps ] .place_status fixed

        #place the first gate connected to the flop. These are the scan related gates that we need to place in order to route the wire.
        #router will not route unless all the gates connected to the wires are placed .
        place_connected -attractor $all_flps -attractor_pin {D Q} -level 1 -place_status

        #for valid bits, we need to also place the first gate connected to the port
        set valid_bit_first_inst_names {}
        foreach valid_bit_regex $::msh_rptrs_M14::valid_bits_regex {
            foreach valid_port [get_db ports $valid_bit_regex -if {.direction == in}] {
                foreach valid_bit_first_inst_name [get_db [all_fanout -levels 1 -from $valid_port -only_cells] .name] {
                    lappend valid_bit_first_inst_names $valid_bit_first_inst_name
                    set flop_connected_to_valid_bit [get_db [::msh_rptrs_M14::_get_msh_flp [get_db $valid_port .name]] .name]
                    #puts $flop_connected_to_valid_bit
                    place_inst $valid_bit_first_inst_name [_get_inst_llx $flop_connected_to_valid_bit] [_get_port_y [get_db $valid_port .name]]  -placed
                }   
            }
        }
        place_detail -inst $valid_bit_first_inst_names
        set_db [get_db insts $valid_bit_first_inst_names] .place_status fixed
        ::msh_rptrs_M14::handle_valid_bits_route_attributes

        #
        # Now place the rptrs
        #input ports on left edge to flops
        ##x-locations in decreasing order from flop to port
        #Even no. of locations (all inverters)
        array set w2e_i_insts_or_ports_for_preroutes [::msh_rptrs_M14::place_msh_rptrs [list \
                                                                                        nets $w2e_i_nets\
                                                                                        locations $::msh_rptrs_M14::w2e_i_loc\
                                                                                        direction "w2e"\
                                                                                        pre_flop 1\
                                                                                       ]]
        #Flops to output ports on right edge
        #x-locations in increasing order from flop to port
        #Odd number of locations (1buffer + Even no. of inverters)
        #Buffer is added on stage 1 because some of the flops have side-loads
        array set w2e_o_insts_or_ports_for_preroutes [::msh_rptrs_M14::place_msh_rptrs [list \
                                                                                        nets $w2e_o_nets\
                                                                                        locations $::msh_rptrs_M14::w2e_o_loc\
                                                                                        direction "w2e"\
                                                                                        pre_flop 0\
                                                                                       ]]
        #input ports on right edge to flops
        #x-locations in increasing order from flop to port
        #Even no. of locations (all inverters)
        array set e2w_i_insts_or_ports_for_preroutes [::msh_rptrs_M14::place_msh_rptrs [list \
                                                                                        nets $e2w_i_nets\
                                                                                        locations $::msh_rptrs_M14::e2w_i_loc\
                                                                                        direction "e2w"\
                                                                                        pre_flop 1\
                                                                                       ]]
        #Flops to output ports on left edge
        #x-locations in decreasing order from flop to port
        #Odd number of locations (1buffer + Even no. of inverters)
        #Buffer is added on stage 1 because some of the flops have side-loads
        array set e2w_o_insts_or_ports_for_preroutes [::msh_rptrs_M14::place_msh_rptrs [list \
                                                                                        nets $e2w_o_nets\
                                                                                        locations $::msh_rptrs_M14::e2w_o_loc\
                                                                                        direction "e2w"\
                                                                                        pre_flop 0\
                                                                                       ]]
        
        #legalize and fixed placement
        #padding to reduce dynamic ir

        set_db place_detail_honor_inst_pad true
        
        foreach inst [get_db insts *AUTO_MSH_RPTR*] {
            set scale_factor 0.5
            set padding_site  [expr int(round([get_db $inst .base_cell.bbox.dx] / [get_db site:core .size.x]) * $scale_factor)]
            
            set cmd "set_inst_padding -inst [get_db $inst .name] -left_side $padding_site -right_side $padding_site -top_side 1 -bottom_side 1"
            ipbu_info $cmd
            eval $cmd
        }
 
        place_detail -inst [get_db [get_db insts *AUTO_MSH_RPTR* -if {.base_cell.name == MRVLSPBUF*}] .name]
        place_detail -inst [get_db [get_db insts *AUTO_MSH_RPTR*] .name]
        _set_fixed_status *AUTO_MSH_RPTR*

        #
        # Set the route attributes on the mesh wires for proper routing
        array set all_insts_or_ports_for_preroute [concat \
                                                       [array get w2e_i_insts_or_ports_for_preroutes] \
                                                       [array get w2e_o_insts_or_ports_for_preroutes] \
                                                       [array get e2w_i_insts_or_ports_for_preroutes] \
                                                       [array get e2w_o_insts_or_ports_for_preroutes]]
        set all_msh_nets {}
        foreach net [concat {*}$w2e_i_nets {*}$w2e_o_nets {*}$e2w_i_nets {*}$e2w_o_nets] {
            lappend all_msh_nets [concat {*}$all_insts_or_ports_for_preroute($net,net_name)]
        }
        set all_msh_nets [concat {*}$all_msh_nets]
        ::msh_rptrs_M14::set_route_attributes_on_msh_wires $all_msh_nets
        #
        
        #now draw the m14 preroutes
        #w2e pre flop
        ::msh_rptrs_M14::draw_preroutes [list \
                                         nets $w2e_i_nets\
                                         direction "w2e"\
                                         place_direction "left"\
                                         insts_or_ports_for_preroutes [array get w2e_i_insts_or_ports_for_preroutes]\
                                        ]

        #w2e post flop
        ::msh_rptrs_M14::draw_preroutes [list \
                                         nets $w2e_o_nets\
                                         direction "w2e"\
                                         place_direction "right"\
                                         insts_or_ports_for_preroutes [array get w2e_o_insts_or_ports_for_preroutes]\
                                        ]

        #e2w pre flop
        ::msh_rptrs_M14::draw_preroutes [list \
                                         nets $e2w_i_nets\
                                         direction "e2w"\
                                         place_direction "right"\
                                         insts_or_ports_for_preroutes [array get e2w_i_insts_or_ports_for_preroutes]\
                                        ]

        #e2w post flop
        ::msh_rptrs_M14::draw_preroutes [list \
                                         nets $e2w_o_nets\
                                         direction "e2w"\
                                         place_direction "left"\
                                         insts_or_ports_for_preroutes [array get e2w_o_insts_or_ports_for_preroutes]\
                                        ]

        #

        #Fully shield the valid bits for timing (this is achieved by adding routing blockage and not adding vdd/gnd close to the signal)
        ::msh_rptrs_M14::block_valid_bits_nearest_M14_track
        
        #lastly route the msh nets
        ::msh_rptrs_M14::route_msh_wires $all_msh_nets
    }


    proc place_msh_flps {finfo} {
        array set flp_info $finfo
        set nets $flp_info(nets)
        set flp_x $flp_info(location)
        set all_flps {}
        foreach net $nets {
            set flp_inst [::msh_rptrs_M14::_get_msh_flp $net]
            
            set flp_y [_get_port_y $net]
            place_inst [get_db $flp_inst .name] $flp_x $flp_y -soft_fixed
            lappend all_flps [get_db $flp_inst .name]
        }

        return $all_flps
    }


    proc place_msh_rptrs {ninfo} {
        array set nets_info $ninfo
        set nets $nets_info(nets)
        set locations $nets_info(locations)
        set direction $nets_info(direction)
        set pre_flop $nets_info(pre_flop)

        array set insts_or_ports_for_preroutes {}

        set buff "MRVLSPBUFD48BWP210H6P51CNODLVT"
        set rptr "MRVLSPINVD48BWP210H6P51CNODLVT"

        foreach net $nets {
            set orig_net $net
            set rptr_cnt 0
            set rptr_y [_get_port_y $net]
            set net_name [get_db [get_db ports $orig_net] .net.name]
            set hier [get_db [_get_msh_flp $net_name] .parent.name]
            foreach rptr_x $locations {
                set new_rptr_name "${hier}/AUTO_MSH_RPTR_${rptr_cnt}__${net_name}"
                set new_net_name  "${hier}/AUTO_NET__${rptr_cnt}__${net_name}"
                regsub -all {(\[|\])} $new_rptr_name __ new_rptr_name

                if {$pre_flop} {
                    puts "Inserting ${rptr} inst_name:${new_rptr_name} -- at location:{$rptr_x $rptr_y} on net:${net}"
                    ipbu_add_repeater -net $net -new_net_name $new_net_name -location [list $rptr_x $rptr_y] -name $new_rptr_name -cell $rptr
                    lappend insts_or_ports_for_preroutes($net) inst:$new_rptr_name
                    lappend insts_or_ports_for_preroutes($net,net_name) $new_net_name
                } else { #post flop
                    if {$rptr_cnt == 0} { # The net after the flop will not be routed here. This net (flop) will also drive the sideload which pnr can optimize as it deems fit
                        puts "Inserting ${buff} inst_name:${new_rptr_name} -- at location:{$rptr_x $rptr_y} on net:${net}"
                        ipbu_add_repeater -net $net -new_net_name $new_net_name -location [list $rptr_x $rptr_y] -name $new_rptr_name -cell $buff -dont_drive_sideload
                        lappend insts_or_ports_for_preroutes($net) inst:$new_rptr_name
                        #net_name field is not added here as this net will not be pre-routed
                        #also add don't touch to this new net as the innovus should not optimize/change the output of the flop connection to the newly added buffer above
#                        set_db [get_db nets $new_net_name] .dont_touch true
                        set_db [get_db pin:$new_rptr_name/I ] .dont_touch true
                    } else {
                        puts "Inserting ${rptr} inst_name:${new_rptr_name} -- at location:{$rptr_x $rptr_y} on net:${net}"
                        ipbu_add_repeater -net $net -new_net_name $new_net_name -location [list $rptr_x $rptr_y] -name $new_rptr_name -cell $rptr
                        lappend insts_or_ports_for_preroutes($net) inst:$new_rptr_name
                        lappend insts_or_ports_for_preroutes($net,net_name) $new_net_name
                    }
                }
                incr rptr_cnt
            }

            #Add the ports/flops bases on pre/post flop
            if {$pre_flop} {
                set insts_or_ports_for_preroutes($net) [linsert $insts_or_ports_for_preroutes($net) 0 [::msh_rptrs_M14::_get_msh_flp $net]]
            }
            lappend insts_or_ports_for_preroutes($net) port:$net
            lappend insts_or_ports_for_preroutes($net,net_name) $net
        }

        return [array get insts_or_ports_for_preroutes]
    }

    proc draw_preroutes {ninfo} {
        array set nets_info $ninfo
        set nets $nets_info(nets)
        set direction $nets_info(direction)
        set place_direction $nets_info(place_direction)
        array set insts_or_ports_for_preroutes $nets_info(insts_or_ports_for_preroutes)
        foreach net $nets {
            set preroute_x [_get_port_x $net]
            set preroute_y [_get_port_y $net]
            set preroute_w [_get_port_w $net]
            set preroute_y0 ""
            set preroute_x0 ""
            set preroute_y1 ""
            set preroute_x1 ""
            for {set i 0} {$i < [expr {[llength $insts_or_ports_for_preroutes($net)] -1}]} {incr i} {
                set curr [lindex $insts_or_ports_for_preroutes($net) $i]
                set next [lindex $insts_or_ports_for_preroutes($net) [expr $i+1]]

                if {$place_direction == "down"} {
                    if {[get_db $curr .obj_type] == "port"} {
                        set preroute_y1 [get_db $curr .location.y]
                    } else {
                        set preroute_y1 [_get_inst_lly [get_db $curr .name]]
                    }
                    
                    if {[get_db $next .obj_type] == "port"} {
                        set preroute_y0 [get_db $next .location.y]
                    } else {
                        set preroute_y0 [_get_inst_ury [get_db $next .name]]
                    }
                } elseif {$place_direction == "up"} { 
                    if {[get_db $curr .obj_type] == "port"} {
                        set preroute_y0 [get_db $curr .location.y]
                    } else {
                        set preroute_y0 [_get_inst_ury [get_db $curr .name]]
                    }
                    
                    if {[get_db $next .obj_type] == "port"} {
                        set preroute_y1 [get_db $next .location.y]
                    } else {
                        set preroute_y1 [_get_inst_lly [get_db $next .name]]
                    }
                } elseif {$place_direction == "left"} { 
                    if {[get_db $curr .obj_type] == "port"} {
                        set preroute_x0 [get_db $curr .location.x]
                    } else {
                        set preroute_x0 [_get_inst_urx [get_db $curr .name]]
                    }
                    
                    if {[get_db $next .obj_type] == "port"} {
                        set preroute_x1 [get_db $next .location.x]
                    } else {
                        set preroute_x1 [_get_inst_llx [get_db $next .name]]
                    }
                } elseif {$place_direction == "right"} { 
                    if {[get_db $curr .obj_type] == "port"} {
                        set preroute_x1 [get_db $curr .location.x]
                    } else {
                        set preroute_x1 [_get_inst_urx [get_db $curr .name]]
                    }
                    
                    if {[get_db $next .obj_type] == "port"} {
                        set preroute_x0 [get_db $next .location.x]
                    } else {
                        set preroute_x0 [_get_inst_llx [get_db $next .name]]
                    }
                }


                if {$place_direction == "up" || $place_direction == "down"} {
                create_shape -net [lindex $insts_or_ports_for_preroutes($net,net_name) $i] -path_segment [list $preroute_x $preroute_y0 $preroute_x $preroute_y1] -width $preroute_w -layer M13 -status fixed
                } else {
                create_shape -net [lindex $insts_or_ports_for_preroutes($net,net_name) $i] -path_segment [list $preroute_x0 $preroute_y $preroute_x1 $preroute_y] -width $preroute_w -layer M14 -status fixed
                }
            } 
        }
    }


    proc set_route_attributes_on_msh_wires {all_msh_nets} {
        foreach cell [get_db base_cells .name MRVLSPINV* ] {
            set_via_pillars -base_pin $cell/ZN -required 1 { \
                                                                 VPPERF_M1_M9_1_3_3_2_2_2_2_2_1\
                                                             }
            set_via_pillars -base_pin $cell/I  -required 1 { \
                                                                 VPPERF_M1_M5_1_3_2_2_1\
                                                             }
        }
        foreach cell [get_db base_cells .name MRVLSPBUF* ] {
            set_via_pillars -base_pin $cell/Z -required 1 { \
                                                                VPPERF_M1_M9_1_3_3_2_2_2_2_2_1\
                                                            }
        }
        #Don't touch these nets
        set_dont_touch $all_msh_nets

        #Add 2w1s ndrs for M9-M12 wires as we will only VP to M9
        create_route_rule \
            -name msh_2w1s \
            -generate_via \
            -width_multiplier {M9:M12 2}

        
        foreach msh_net $all_msh_nets {
            set_route_attributes \
                -nets $msh_net \
                -route_rule msh_2w1s \
                -weight 10
        }

        #for eco_add_repeater to work
        edit_update_route_status -nets $all_msh_nets -to routed
        convert_special_routes_for_eco -nets $all_msh_nets
    }


    proc route_msh_wires {all_msh_nets} {
        set honor_route_rule_setting [get_db route_design_strict_honor_route_rule]
        set_db route_design_strict_honor_route_rule true

        #        set all_msh_nets [::msh_rptrs_M14::_get_all_msh_nets]
        
        #Route the msh wires
        set_db eco_batch_mode false
        set_db eco_honor_fixed_status true 
        set_db eco_honor_dont_use true
        set_db eco_honor_dont_touch true
        set_db eco_update_timing true
        set_db eco_honor_fixed_wires true
        set_db eco_refine_place true
        set_db eco_prefix ECO

        ::msh_rptrs_M14::_fix_m14_shorts
        
        deselect_obj -all
        #        select_obj [get_db [get_db insts "*AUTO*msh*"] .pins.net]
        select_obj [get_db nets $all_msh_nets]

        #Speical handling for the valid bits
        #        deselect_obj [get_db [get_db insts [regsub -all {[\[\]]} $valid_bits_regex __]] .pins.net]
        
        set_db route_design_selected_net_only true
        set_db route_design_with_timing_driven false
        set_db route_design_with_si_driven false

#        #block all M14 routes before routing. This will avoid almost all of the antenna issues 
#        create_route_blockage \
#            -rects [list  [_get_design_llx] [_get_design_lly] [_get_design_urx] [_get_design_ury] ]\
#            -layer M14 \
#            -name RouteBlk_M14_mshrptrs
#
        route_eco
#        delete_route_blockage -name RouteBlk_M14_mshrptrs

        delete_markers
        check_drc -limit 0 -out_file check_drc.1.rpt
        route_eco -fix_drc
        check_drc -limit 0 -out_file check_drc.2.rpt

        set_db route_design_selected_net_only false
        set_db route_design_with_timing_driven true
        set_db route_design_with_si_driven true

        edit_update_route_status -nets $all_msh_nets -to fixed

        # Also fix the diode placement
        # Since the nets are marked fixed, if we don't fix the Ant diode, they move during placement and causes opens
        if {[llength [get_db insts *msh*ANTFIX*]]} {
            set_db [get_db insts *msh*ANTFIX*] .place_status fixed
        }
        
        #dont route these later in the design
        set_db selected .skip_routing true
        set_db route_design_strict_honor_route_rule $honor_route_rule_setting 
        write_def -routing -selected pre_routing.def
        deselect_obj -all
    }

    proc block_valid_bits_nearest_M14_track {} {
        foreach valid_regex $::msh_rptrs_M14::valid_bits_regex {
            foreach net [get_db [get_db ports -if {.direction ==in && .name == $valid_regex}] .name] {
                #first find the M14 track for the given M14 pin
                set m14_port_loc [get_db [get_nets $net] .driver_ports.location.y]
                set current_m14_track [um2track -layer M14 -um $m14_port_loc]
                set current_m14_track_plus_1track_loc [track2um -layer M14 -num [expr $current_m14_track + 1]]
                set current_m14_track_minus_1track_loc [track2um -layer M14 -num [expr $current_m14_track - 1]]
                set diff [expr {abs($current_m14_track_plus_1track_loc - $m14_port_loc)}]
                if { $diff > 0.258} {
                    set closest_m14_track_loc $current_m14_track_minus_1track_loc
                } else {
                    set closest_m14_track_loc $current_m14_track_plus_1track_loc
                }

                # Create the route blockage
                set track_width [get_db [get_nets $net] .driver_ports.width]
                create_route_blockage \
                    -rects [list \
                                0 \
                                [expr {$closest_m14_track_loc - ($track_width/2)}] \
                                [get_db current_design .bbox.ur.x] \
                                [expr {$closest_m14_track_loc + ($track_width/2)}] \
                                                               ]\
                    -layer M14 \
                    -name RouteBlk_Crit_$net
            }
        }
    }



#    proc block_valid_bits_nearest_M14_track {} {
#        foreach valid_regex $::msh_rptrs_M14::valid_bits_regex {
#            foreach net [get_db [get_db ports -if {.direction ==in && .name == $valid_regex}] .name] {
#                #first find the M14 track for the given M14 pin
#                set m14_track [get_db [get_nets $net] .driver_ports.location.y]
#                
#                #Now find the track next to it to block. Since the other side is a shield, we have to take that into account on which side track to pick
#                set all_m14_tracks [lsort -real [ipbu_get_tracks M14 horizontal]]
#                
#                set current_m14_track_index [lsearch -real -exact $all_m14_tracks $m14_track]
#                
#                set current_m14_track_plus_1track  [expr {[lindex $all_m14_tracks [expr {$current_m14_track_index + 1}]] - [lindex $all_m14_tracks $current_m14_track_index]}]
#                set current_m14_track_minus_1track [expr {[lindex $all_m14_tracks $current_m14_track_index] - [lindex $all_m14_tracks [expr {$current_m14_track_index - 1}]]}]
#
#                if {[expr {($current_m14_track_plus_1track - $current_m14_track_minus_1track) < ($current_m14_track_minus_1track - $current_m14_track_plus_1track)}]} { 
#                    set closest_m14_track [lindex $all_m14_tracks [expr {$current_m14_track_index + 1}]]
#                } else {
#                    set closest_m14_track [lindex $all_m14_tracks [expr {$current_m14_track_index - 1}]]
#                }
#
#                # Create the route blockage
#                set track_width [get_db [get_nets $net] .driver_ports.width]
#                create_route_blockage \
#                    -rects [list \
#                                0 \
#                                [expr {$closest_m14_track - ($track_width/2)}] \
#                                [get_db current_design .bbox.ur.x] \
#                                [expr {$closest_m14_track + ($track_width/2)}] \
#                                                               ]\
#                    -layer M14 \
#                    -name RouteBlk_Crit_$net
#            }
#        }
#    }

    proc _find_start_nets_of_ports {ports_pat} {
        return [get_db [get_db \
                            [all_fanin -to [get_db ports $ports_pat]]\
                            -if {.name == *msh_rpt*/Q}]\
                    .net.name]
    }

    proc _get_msh_flp {net} {
        if {[get_db [get_db ports $net] .direction] == "out"} {
            return [get_db [get_db [all_fanin -to [get_db nets $net]] -if {.name == */Q}] .inst]
        } else {
            return [get_db [get_db [all_fanout -from [get_db nets $net]] -if {.name == */D}] .inst]
        }
    }

    proc _get_all_msh_nets {} {
        return [concat \
                    [get_db -u [get_db ports -if {.name == *msh* && .layer.name != M11}] .net.name] \
                    [get_db [get_db insts "*AUTO*msh*"] .pins.net.name]\
                   ]
    }

    proc _fix_m14_shorts {} {
        #sometimes after place_detail, some instances of the MRVLBUF that are placed after the flop are placed physically before the flop and that causes short with the net which is the input of the flop as we track share.
        #we will delete the M14 portion of the shorted area
        ipbu_info "Cleaning up M14 shorts"
        delete_markers
        check_drc -check_short_only -layer_range M14 -out_file check_drc.0.rpt
        foreach marker [get_db markers -if {.subtype == Metal_Short}] {
            deselect_obj -all 
            set bbox [get_db $marker .bbox]
            select_obj [get_db [get_obj_in_area -areas $bbox -layers M14 -obj_type special_wire]]
            edit_cut_route -box $bbox -selected
            delete_obj [get_obj_in_area -areas $bbox -layers M14 -obj_type special_wire -enclosed_only]
            ipbu_info "Deleting bbox of M14 shorts : $bbox"
        }
    }
    
    proc handle_valid_bits_route_attributes {} {
        #trace the valid bit and set route attribute 
        set valid_nets {}
        foreach valid_bit_regex $::msh_rptrs_M14::valid_bits_regex {
            foreach valid_port [get_db ports $valid_bit_regex -if {.direction == in}] {
                set valid_bit_first_inst [all_fanout -levels 1 -from $valid_port -only_cells]
                set valid_net {}
                if {[get_db $valid_bit_first_inst .is_inverter]} {
                    set valid_bit_first_inst_name [get_db $valid_bit_first_inst .name]
                    set valid_bit_mux_inst_name [lsearch -inline -not -regexp [get_db [all_fanout -levels 1 -from [get_db $valid_bit_first_inst .pins -if {.direction == out}] -only_cells ] .name] $valid_bit_first_inst_name]
                    set valid_net [get_db [get_db inst:$valid_bit_mux_inst_name .pins -if {.direction == out}] .net.name]
                    lappend valid_nets $valid_net
                } else {
                    set valid_net [get_db [get_db $valid_bit_first_inst .pins -if {.direction == out}] .net.name]
                    lappend valid_nets $valid_net
                }
                # trace this to the flops/latches
                lappend valid_nets [get_db  [get_db [all_fanout -from $valid_net -only_cells ] -if {!.is_sequential }] .pins.net.name]
            }
        }
        set valid_nets [concat {*}$valid_nets]

        #remove all the buffers on the valid nets
        set netfile "tad_valid_wires.txt"
        fwrite -file $netfile -wlist $valid_nets

        set old_no_assign_setting [get_db init_no_new_assigns]
        set_db init_no_new_assigns 0
        delete_buffer_trees -nets_file $netfile
        set_db init_no_new_assigns $old_no_assign_setting

        #set ndr on these nets 
        #Add 2w1s ndrs for M11-M12 wires for valid bits
        create_route_rule \
            -name msh_val_m11_m12_2w1s \
            -generate_via \
            -width_multiplier {M11:M12 2}

        foreach net [get_db [get_db nets $valid_nets] .name] {
            set_route_attributes \
                -nets $net \
                -route_rule msh_val_m11_m12_2w1s \
                -weight 10 \
                -top_preferred_routing_layer 13 \
                -bottom_preferred_routing_layer 12 \
  
        }

    }
}




namespace eval msh_rptrs_M13 {
    #variable valid_bits_regex {*msh*dat[429] *msh*req[176] *msh*rsp[165] *msh*rsp[82] *msh*snp[139] }
#    variable hier_n2s msh_rpt/flop_msw_flp
#    variable hier_s2n msh_rpt/flop_msh_flp

if { ${block_name} == "pcl_til_tdv" ||  ${block_name} == "pcl_til_cdv"} {   
    if {[info exists ::msh_rptr_var(botedge_in_flops_y)] } {
        variable botedge_in_flops_y  $::msh_rptr_var(botedge_in_flops_y)
    } else {
        variable design_y2 [get_db current_design .bbox.ur.y]
        variable botedge_in_flops_y  [expr (${design_y2}/2) - 50]
    }
    
    if {[info exists ::msh_rptr_var(topedge_in_flops_y)] } {
        variable topedge_in_flops_y  $::msh_rptr_var(topedge_in_flops_y)
    } else {
        variable design_y2 [get_db current_design .bbox.ur.y]
        variable topedge_in_flops_y  [expr (${design_y2}/2) + 50]
    }
    
    if {[info exists ::msh_rptr_var(valid_bits_regex)] } {
        variable  valid_bits_regex  $::msh_rptr_var(valid_bits_regex)
    } 
    
    if {[info exists ::msh_rptr_var(n2s_i_loc)] } {
        variable n2s_i_loc  $::msh_rptr_var(n2s_i_loc)
        variable n_of_loc [llength $n2s_i_loc]
        if { [expr ${n_of_loc} % 2 ]} {
            puts "odd number of values {${n2s_i_loc}} for n2s_i_loc "
            return
           } 
    } else {
        puts "n2s_i_loc varible is not set; provide Even number of values in decreasing order "
        return
    }
    
    if {[info exists ::msh_rptr_var(n2s_o_loc)] } {
        variable n2s_o_loc  $::msh_rptr_var(n2s_o_loc)
        variable n_of_loc [llength $n2s_o_loc]
        if { ![expr ${n_of_loc} % 2 ]} {
            puts "Even number of values {${n2s_o_loc}} for n2s_o_loc "
            puts "n2s_o_loc variable needs to be odd (1Buff + 2*n inv)"
            return
           } 
    } else {
        puts "n2s_o_loc varible is not set; provide odd number of values in increasing order"
        return
    }
    
    if {[info exists ::msh_rptr_var(s2n_i_loc)] } {
        variable s2n_i_loc  $::msh_rptr_var(s2n_i_loc)
        variable n_of_loc [llength $s2n_i_loc]
        if { [expr ${n_of_loc} % 2 ]} {
            puts "odd number of values {${s2n_i_loc}} for s2n_i_loc "
            return
           } 
    } else {
        puts "s2n_i_loc varible is not set; provide Even number of values in increasing order"
        return
    }
    
    if {[info exists ::msh_rptr_var(s2n_o_loc)] } {
        variable s2n_o_loc  $::msh_rptr_var(s2n_o_loc)
        variable n_of_loc [llength $s2n_o_loc]
        if { ![expr ${n_of_loc} % 2 ]} {
            puts "Even number of values {${s2n_o_loc}} for s2n_o_loc "
            puts "s2n_o_loc variable needs to be odd (1Buff + 2*n inv)"
            return
           } 
    } else {
        puts "s2n_o_loc varible is not set; provide odd number of values in decreasing order"
        return
    }
    

}
   
    
    proc place_msw_rptrs {} {
        
            #N2S nets msh__til (i) msh__msw* (o)
            #S2N nets msw__msh (i) til__msh* (o)

        set n2s_i_nets [get_db [get_db ports msh__til*] .net.name]
        set n2s_o_nets [::msh_rptrs_M13::_find_start_nets_of_ports msh__msw*]
        set s2n_i_nets [get_db [get_db ports msw__msh*] .net.name]
        set s2n_o_nets [::msh_rptrs_M13::_find_start_nets_of_ports til__msh*]

        #First we will delete the buffer tree if any on these nets
        set tad_wires_f "tad_delete_buffer_wires.name"
        set FH [open $tad_wires_f w]
        foreach msh_net [concat $n2s_i_nets $n2s_o_nets $s2n_i_nets $s2n_o_nets] {
            puts $FH $msh_net
        }
        close $FH

        set old_no_assign_setting [get_db init_no_new_assigns]
        set_db init_no_new_assigns 0
        delete_buffer_trees -nets_file $tad_wires_f
        set_db init_no_new_assigns $old_no_assign_setting
        #

        # Now place the *msh* flops
        #reset the nets after buffer tree deletion
        set n2s_o_nets [::msh_rptrs_M13::_find_start_nets_of_ports msh__msw*]
        set s2n_o_nets [::msh_rptrs_M13::_find_start_nets_of_ports til__msh*]

#        set_dont_touch [concat {*}$n2s_i_nets {*}$n2s_o_nets {*}$s2n_i_nets {*}$s2n_o_nets]
        
        set all_flps {}
        #n2s flops
        lappend all_flps [::msh_rptrs_M13::place_msh_flps [list \
                                                           nets $n2s_i_nets\
                                                           location $::msh_rptrs_M13::topedge_in_flops_y\
                                                           direction "n2s"\
                                                          ]]
        #s2n flops
        lappend all_flps [::msh_rptrs_M13::place_msh_flps [list \
                                                           nets $s2n_i_nets\
                                                           location $::msh_rptrs_M13::botedge_in_flops_y\
                                                           direction "s2n"\
                                                          ]]

        #legalize and fixed placement
        #padding to reduce dynamic ir/m1 short issues
        set all_flps [concat {*}$all_flps]
        set_db place_detail_honor_inst_pad true
        
        foreach inst $all_flps {
            set scale_factor 0.5
            set padding_site  [expr int(round([get_db inst:$inst .base_cell.bbox.dx] / [get_db site:core .size.x]) * $scale_factor)]
            set cmd "set_inst_padding -inst $inst -left_side $padding_site -right_side $padding_site -top_side 1 -bottom_side 1"
            ipbu_info $cmd
            eval $cmd
        }
        
        set_db place_detail_eco_max_distance 20
        place_detail -inst $all_flps
        set_db [get_db insts $all_flps ] .place_status fixed

        #place the first gate connected to the flop. These are the scan related gates that we need to place in order to route the wire.
        #router will not route unless all the gates connected to the wires are placed .
        place_connected -attractor $all_flps -attractor_pin {D Q} -level 1 -place_status

        #for valid bits, we need to also place the first gate connected to the port
        set valid_bit_first_inst_names {}
        foreach valid_bit_regex $::msh_rptrs_M13::valid_bits_regex {
            foreach valid_port [get_db ports $valid_bit_regex -if {.direction == in}] {
                foreach valid_bit_first_inst_name [get_db [all_fanout -levels 1 -from $valid_port -only_cells] .name] {
                    lappend valid_bit_first_inst_names $valid_bit_first_inst_name
                    set flop_connected_to_valid_bit [get_db [::msh_rptrs_M13::_get_msh_flp [get_db $valid_port .name]] .name]
                    place_inst $valid_bit_first_inst_name [_get_port_x [get_db $valid_port .name]] [_get_inst_lly $flop_connected_to_valid_bit] -placed
                }   
            }
        }
        place_detail -inst $valid_bit_first_inst_names
        set_db [get_db insts $valid_bit_first_inst_names] .place_status fixed
        ::msh_rptrs_M13::handle_valid_bits_route_attributes

        #
        # Now place the rptrs
        array set n2s_i_insts_or_ports_for_preroutes [::msh_rptrs_M13::place_msh_rptrs [list \
                                                                                        nets $n2s_i_nets\
                                                                                        locations $::msh_rptrs_M13::n2s_i_loc\
                                                                                        direction "n2s"\
                                                                                        pre_flop 1\
                                                                                       ]]
        
        array set n2s_o_insts_or_ports_for_preroutes [::msh_rptrs_M13::place_msh_rptrs [list \
                                                                                        nets $n2s_o_nets\
                                                                                        locations $::msh_rptrs_M13::n2s_o_loc\
                                                                                        direction "n2s"\
                                                                                        pre_flop 0\
                                                                                       ]]
        
        array set s2n_i_insts_or_ports_for_preroutes [::msh_rptrs_M13::place_msh_rptrs [list \
                                                                                        nets $s2n_i_nets\
                                                                                        locations $::msh_rptrs_M13::s2n_i_loc\
                                                                                        direction "s2n"\
                                                                                        pre_flop 1\
                                                                                       ]]
        
        array set s2n_o_insts_or_ports_for_preroutes [::msh_rptrs_M13::place_msh_rptrs [list \
                                                                                        nets $s2n_o_nets\
                                                                                        locations $::msh_rptrs_M13::s2n_o_loc\
                                                                                        direction "s2n"\
                                                                                        pre_flop 0\
                                                                                       ]]
        
        #legalize and fixed placement
        #padding to reduce dynamic ir

        set_db place_detail_honor_inst_pad true
        
        foreach inst [get_db insts *AUTO_MSH_RPTR*] {
            set scale_factor 0.5
            set padding_site  [expr int(round([get_db $inst .base_cell.bbox.dx] / [get_db site:core .size.x]) * $scale_factor)]
            
            set cmd "set_inst_padding -inst [get_db $inst .name] -left_side $padding_site -right_side $padding_site -top_side 1 -bottom_side 1"
            ipbu_info $cmd
            eval $cmd
        }
 
        place_detail -inst [get_db [get_db insts *AUTO_MSH_RPTR* -if {.base_cell.name == MRVLSPBUF*}] .name]
        place_detail -inst [get_db [get_db insts *AUTO_MSH_RPTR*] .name]
        _set_fixed_status *AUTO_MSH_RPTR*

        #
        # Set the route attributes on the mesh wires for proper routing
        array set all_insts_or_ports_for_preroute [concat \
                                                       [array get n2s_i_insts_or_ports_for_preroutes] \
                                                       [array get n2s_o_insts_or_ports_for_preroutes] \
                                                       [array get s2n_i_insts_or_ports_for_preroutes] \
                                                       [array get s2n_o_insts_or_ports_for_preroutes]]
        set all_msh_nets {}
        foreach net [concat {*}$n2s_i_nets {*}$n2s_o_nets {*}$s2n_i_nets {*}$s2n_o_nets] {
            lappend all_msh_nets [concat {*}$all_insts_or_ports_for_preroute($net,net_name)]
        }
        set all_msh_nets [concat {*}$all_msh_nets]
        ::msh_rptrs_M13::set_route_attributes_on_msh_wires $all_msh_nets
        #
        
        #now draw the m13 preroutes
        #n2s pre flop
        ::msh_rptrs_M13::draw_preroutes [list \
                                         nets $n2s_i_nets\
                                         direction "n2s"\
                                         place_direction "up"\
                                         insts_or_ports_for_preroutes [array get n2s_i_insts_or_ports_for_preroutes]\
                                        ]

        #n2s post flop
        ::msh_rptrs_M13::draw_preroutes [list \
                                         nets $n2s_o_nets\
                                         direction "n2s"\
                                         place_direction "down"\
                                         insts_or_ports_for_preroutes [array get n2s_o_insts_or_ports_for_preroutes]\
                                        ]

        #s2n pre flop
        ::msh_rptrs_M13::draw_preroutes [list \
                                         nets $s2n_i_nets\
                                         direction "s2n"\
                                         place_direction "down"\
                                         insts_or_ports_for_preroutes [array get s2n_i_insts_or_ports_for_preroutes]\
                                        ]

        #s2n post flop
        ::msh_rptrs_M13::draw_preroutes [list \
                                         nets $s2n_o_nets\
                                         direction "s2n"\
                                         place_direction "up"\
                                         insts_or_ports_for_preroutes [array get s2n_o_insts_or_ports_for_preroutes]\
                                        ]

        #

        #Fully shield the valid bits for timing (this is achieved by adding routing blockage and not adding vdd/gnd close to the signal)
        ::msh_rptrs_M13::block_valid_bits_nearest_M13_track
        
        #lastly route the msh nets
        ::msh_rptrs_M13::route_msh_wires $all_msh_nets
    }


    proc place_msh_flps {finfo} {
        array set flp_info $finfo
        set nets $flp_info(nets)
        set flp_y $flp_info(location)
        set all_flps {}
        foreach net $nets {
            set flp_inst [::msh_rptrs_M13::_get_msh_flp $net]
            
            set flp_x [_get_port_x $net]
            place_inst [get_db $flp_inst .name] $flp_x $flp_y -soft_fixed
            lappend all_flps [get_db $flp_inst .name]
        }

        return $all_flps
    }


    proc place_msh_rptrs {ninfo} {
        array set nets_info $ninfo
        set nets $nets_info(nets)
        set locations $nets_info(locations)
        set direction $nets_info(direction)
        set pre_flop $nets_info(pre_flop)

        array set insts_or_ports_for_preroutes {}

        set buff "MRVLSPBUFD48BWP210H6P51CNODLVT"
        set rptr "MRVLSPINVD48BWP210H6P51CNODLVT"

        foreach net $nets {
            set orig_net $net
            set rptr_cnt 0
            set rptr_x [_get_port_x $net]
            set net_name [get_db [get_db ports $orig_net] .net.name]
            set hier [get_db [_get_msh_flp $net_name] .parent.name]
            foreach rptr_y $locations {
                set new_rptr_name "${hier}/AUTO_MSH_RPTR_${rptr_cnt}__${net_name}"
                set new_net_name  "${hier}/AUTO_NET__${rptr_cnt}__${net_name}"
                regsub -all {(\[|\])} $new_rptr_name __ new_rptr_name

                if {$pre_flop} {
                    ipbu_add_repeater -net $net -new_net_name $new_net_name -location [list $rptr_x $rptr_y] -name $new_rptr_name -cell $rptr
                    lappend insts_or_ports_for_preroutes($net) inst:$new_rptr_name
                    lappend insts_or_ports_for_preroutes($net,net_name) $new_net_name
                } else { #post flop
                    if {$rptr_cnt == 0} { # The net after the flop will not be routed here. This net (flop) will also drive the sideload which pnr can optimize as it deems fit
                        ipbu_add_repeater -net $net -new_net_name $new_net_name -location [list $rptr_x $rptr_y] -name $new_rptr_name -cell $buff -dont_drive_sideload
                        lappend insts_or_ports_for_preroutes($net) inst:$new_rptr_name
                        #net_name field is not added here as this net will not be pre-routed
                        #also add don't touch to this new net as the innovus should not optimize/change the output of the flop connection to the newly added buffer above
#                        set_db [get_db nets $new_net_name] .dont_touch true
                        set_db [get_db pin:$new_rptr_name/I ] .dont_touch true
                    } else {
                        ipbu_add_repeater -net $net -new_net_name $new_net_name -location [list $rptr_x $rptr_y] -name $new_rptr_name -cell $rptr
                        lappend insts_or_ports_for_preroutes($net) inst:$new_rptr_name
                        lappend insts_or_ports_for_preroutes($net,net_name) $new_net_name
                    }
                }
                incr rptr_cnt
            }

            #Add the ports/flops bases on pre/post flop
            if {$pre_flop} {
                set insts_or_ports_for_preroutes($net) [linsert $insts_or_ports_for_preroutes($net) 0 [::msh_rptrs_M13::_get_msh_flp $net]]
            }
            lappend insts_or_ports_for_preroutes($net) port:$net
            lappend insts_or_ports_for_preroutes($net,net_name) $net
        }

        return [array get insts_or_ports_for_preroutes]
    }

    proc draw_preroutes {ninfo} {
        array set nets_info $ninfo
        set nets $nets_info(nets)
        set direction $nets_info(direction)
        set place_direction $nets_info(place_direction)
        array set insts_or_ports_for_preroutes $nets_info(insts_or_ports_for_preroutes)
        foreach net $nets {
            set preroute_x [_get_port_x $net]
            set preroute_w [_get_port_w $net]
            set preroute_y0 ""
            set preroute_y1 ""
            for {set i 0} {$i < [expr {[llength $insts_or_ports_for_preroutes($net)] -1}]} {incr i} {
                set curr [lindex $insts_or_ports_for_preroutes($net) $i]
                set next [lindex $insts_or_ports_for_preroutes($net) [expr $i+1]]

                if {$place_direction == "down"} {
                    if {[get_db $curr .obj_type] == "port"} {
                        set preroute_y1 [get_db $curr .location.y]
                    } else {
                        set preroute_y1 [_get_inst_lly [get_db $curr .name]]
                    }
                    
                    if {[get_db $next .obj_type] == "port"} {
                        set preroute_y0 [get_db $next .location.y]
                    } else {
                        set preroute_y0 [_get_inst_ury [get_db $next .name]]
                    }
                } else { #up
                    if {[get_db $curr .obj_type] == "port"} {
                        set preroute_y0 [get_db $curr .location.y]
                    } else {
                        set preroute_y0 [_get_inst_ury [get_db $curr .name]]
                    }
                    
                    if {[get_db $next .obj_type] == "port"} {
                        set preroute_y1 [get_db $next .location.y]
                    } else {
                        set preroute_y1 [_get_inst_lly [get_db $next .name]]
                    }
                }

                create_shape -net [lindex $insts_or_ports_for_preroutes($net,net_name) $i] -path_segment [list $preroute_x $preroute_y0 $preroute_x $preroute_y1] -width $preroute_w -layer M13 -status fixed
            } 
        }
    }


    proc set_route_attributes_on_msh_wires {all_msh_nets} {
        foreach cell [get_db base_cells .name MRVLSPINV* ] {
            set_via_pillars -base_pin $cell/ZN -required 1 { \
                                                                 VPPERF_M1_M9_1_3_3_2_2_2_2_2_1\
                                                             }
            set_via_pillars -base_pin $cell/I  -required 1 { \
                                                                 VPPERF_M1_M5_1_3_2_2_1\
                                                             }
        }
        foreach cell [get_db base_cells .name MRVLSPBUF* ] {
            set_via_pillars -base_pin $cell/Z -required 1 { \
                                                                VPPERF_M1_M9_1_3_3_2_2_2_2_2_1\
                                                            }
        }
        #Don't touch these nets
        set_dont_touch $all_msh_nets

        #Add 2w1s ndrs for M9-M12 wires as we will only VP to M9
        create_route_rule \
            -name msh_2w1s \
            -generate_via \
            -width_multiplier {M9:M12 2}

        
        foreach msh_net $all_msh_nets {
            set_route_attributes \
                -nets $msh_net \
                -route_rule msh_2w1s \
                -weight 10
        }

        #for eco_add_repeater to work
        edit_update_route_status -nets $all_msh_nets -to routed
        convert_special_routes_for_eco -nets $all_msh_nets
    }


    proc route_msh_wires {all_msh_nets} {
        set honor_route_rule_setting [get_db route_design_strict_honor_route_rule]
        set_db route_design_strict_honor_route_rule true

        #        set all_msh_nets [::msh_rptrs_M13::_get_all_msh_nets]
        
        #Route the msh wires
        set_db eco_batch_mode false
        set_db eco_honor_fixed_status true 
        set_db eco_honor_dont_use true
        set_db eco_honor_dont_touch true
        set_db eco_update_timing true
        set_db eco_honor_fixed_wires true
        set_db eco_refine_place true
        set_db eco_prefix ECO

        ::msh_rptrs_M13::_fix_m13_shorts
        
        deselect_obj -all
        #        select_obj [get_db [get_db insts "*AUTO*msh*"] .pins.net]
        select_obj [get_db nets $all_msh_nets]

        #Speical handling for the valid bits
        #        deselect_obj [get_db [get_db insts [regsub -all {[\[\]]} $valid_bits_regex __]] .pins.net]
        
        set_db route_design_selected_net_only true
        set_db route_design_with_timing_driven false
        set_db route_design_with_si_driven false

        #block all M14 routes before routing. This will avoid almost all of the antenna issues 
        create_route_blockage \
            -rects [list  [_get_design_llx] [_get_design_lly] [_get_design_urx] [_get_design_ury] ]\
            -layer M14 \
            -name RouteBlk_M14_mshrptrs

        route_eco
        delete_route_blockage -name RouteBlk_M14_mshrptrs

        delete_markers
        check_drc -limit 0 -out_file check_drc.1.rpt
        route_eco -fix_drc
        check_drc -limit 0 -out_file check_drc.2.rpt

        set_db route_design_selected_net_only false
        set_db route_design_with_timing_driven true
        set_db route_design_with_si_driven true

        edit_update_route_status -nets $all_msh_nets -to fixed

        # Also fix the diode placement
        # Since the nets are marked fixed, if we don't fix the Ant diode, they move during placement and causes opens
        if {[llength [get_db insts *msh*ANTFIX*]]} {
            set_db [get_db insts *msh*ANTFIX*] .place_status fixed
        }
        
        #dont route these later in the design
        set_db selected .skip_routing true
        set_db route_design_strict_honor_route_rule $honor_route_rule_setting 
        write_def -routing -selected pre_routing.def
        deselect_obj -all
    }

    proc block_valid_bits_nearest_M13_track {} {
        foreach valid_regex $::msh_rptrs_M13::valid_bits_regex {
            foreach net [get_db [get_db ports -if {.direction ==in && .name == $valid_regex}] .name] {
                #first find the M13 track for the given M13 pin
                set m13_track [get_db [get_nets $net] .driver_ports.location.x]
                
                #Now find the track next to it to block. Since the other side is a shield, we have to take that into account on which side track to pick
                set all_m13_tracks [lsort -real [ipbu_get_tracks M13 vertical]]
                
                set current_m13_track_index [lsearch -real -exact $all_m13_tracks $m13_track]
                
                set current_m13_track_plus_1track  [expr {[lindex $all_m13_tracks [expr {$current_m13_track_index + 1}]] - [lindex $all_m13_tracks $current_m13_track_index]}]
                set current_m13_track_minus_1track [expr {[lindex $all_m13_tracks $current_m13_track_index] - [lindex $all_m13_tracks [expr {$current_m13_track_index - 1}]]}]

                if {[expr {($current_m13_track_plus_1track - $current_m13_track_minus_1track) < ($current_m13_track_minus_1track - $current_m13_track_plus_1track)}]} { 
                    set closest_m13_track [lindex $all_m13_tracks [expr {$current_m13_track_index + 1}]]
                } else {
                    set closest_m13_track [lindex $all_m13_tracks [expr {$current_m13_track_index - 1}]]
                }

                # Create the route blockage
                set track_width [get_db [get_nets $net] .driver_ports.width]
                create_route_blockage \
                    -rects [list \
                                [expr {$closest_m13_track - ($track_width/2)}] \
                                0\
                                [expr {$closest_m13_track + ($track_width/2)}] \
                                [get_db current_design .bbox.ur.y]\
                               ]\
                    -layer M13 \
                    -name RouteBlk_Crit_$net
            }
        }
    }

    proc _find_start_nets_of_ports {ports_pat} {
        return [get_db [get_db \
                            [all_fanin -to [get_db ports $ports_pat]]\
                            -if {.name == *msh_rpt*/Q}]\
                    .net.name]
    }

    proc _get_msh_flp {net} {
        if {[get_db [get_db ports $net] .direction] == "out"} {
            return [get_db [get_db [all_fanin -to [get_db nets $net]] -if {.name == */Q}] .inst]
        } else {
            return [get_db [get_db [all_fanout -from [get_db nets $net]] -if {.name == */D}] .inst]
        }
    }

    proc _get_all_msh_nets {} {
        return [concat \
                    [get_db -u [get_db ports -if {.name == *msh* && .layer.name != M11}] .net.name] \
                    [get_db [get_db insts "*AUTO*msh*"] .pins.net.name]\
                   ]
    }

    proc _fix_m13_shorts {} {
        #sometimes after place_detail, some instances of the MRVLBUF that are placed after the flop are placed physically before the flop and that causes short with the net which is the input of the flop as we track share.
        #we will delete the M13 portion of the shorted area
        ipbu_info "Cleaning up M13 shorts"
        delete_markers
        check_drc -check_short_only -layer_range M13 -out_file check_drc.0.rpt
        foreach marker [get_db markers -if {.subtype == Metal_Short}] {
            deselect_obj -all 
            set bbox [get_db $marker .bbox]
            select_obj [get_db [get_obj_in_area -areas $bbox -layers M13 -obj_type special_wire]]
            edit_cut_route -box $bbox -selected
            delete_obj [get_obj_in_area -areas $bbox -layers M13 -obj_type special_wire -enclosed_only]
            ipbu_info "Deleting bbox of M13 shorts : $bbox"
        }
    }
    
    proc handle_valid_bits_route_attributes {} {
        #trace the valid bit and set route attribute 
        set valid_nets {}
        foreach valid_bit_regex $::msh_rptrs_M13::valid_bits_regex {
            foreach valid_port [get_db ports $valid_bit_regex -if {.direction == in}] {
                set valid_bit_first_inst [all_fanout -levels 1 -from $valid_port -only_cells]
                set valid_net {}
                if {[get_db $valid_bit_first_inst .is_inverter]} {
                    set valid_bit_first_inst_name [get_db $valid_bit_first_inst .name]
                    set valid_bit_mux_inst_name [lsearch -inline -not -regexp [get_db [all_fanout -levels 1 -from [get_db $valid_bit_first_inst .pins -if {.direction == out}] -only_cells ] .name] $valid_bit_first_inst_name]
                    set valid_net [get_db [get_db inst:$valid_bit_mux_inst_name .pins -if {.direction == out}] .net.name]
                    lappend valid_nets $valid_net
                } else {
                    set valid_net [get_db [get_db $valid_bit_first_inst .pins -if {.direction == out}] .net.name]
                    lappend valid_nets $valid_net
                }
                # trace this to the flops/latches
                lappend valid_nets [get_db  [get_db [all_fanout -from $valid_net -only_cells ] -if {!.is_sequential }] .pins.net.name]
            }
        }
        set valid_nets [concat {*}$valid_nets]

        #remove all the buffers on the valid nets
        set netfile "tad_valid_wires.txt"
        fwrite -file $netfile -wlist $valid_nets

        set old_no_assign_setting [get_db init_no_new_assigns]
        set_db init_no_new_assigns 0
        delete_buffer_trees -nets_file $netfile
        set_db init_no_new_assigns $old_no_assign_setting

        #set ndr on these nets 
        #Add 2w1s ndrs for M11-M12 wires for valid bits
        create_route_rule \
            -name msh_val_m11_m12_2w1s \
            -generate_via \
            -width_multiplier {M11:M12 2}

        foreach net [get_db [get_db nets $valid_nets] .name] {
            set_route_attributes \
                -nets $net \
                -route_rule msh_val_m11_m12_2w1s \
                -weight 10 \
                -top_preferred_routing_layer 13 \
                -bottom_preferred_routing_layer 12 \
  
        }

    }
} 


##Rptr proc call
if { ${block_name} == "pcl_til_tdv" ||  ${block_name} == "pcl_til_cdv"} {
::msh_rptrs_M13::place_msw_rptrs
} elseif { ${block_name} == "pcl_til_tdh" || ${block_name} == "pcl_til_cdh" || ${block_name} == "pcl_til_rch"} {
::msh_rptrs_M14::place_msw_rptrs
}

