################################################################################
# Routines to add buffer chains on arbitrary nets.
# Author : Arun Hegde
# Usage :
# add_buffer_chain_on_net <net_name> <buffer_separation_dist> <cell_to_use>
# Example :
# add_buffer_chain_on_net jtg__hub_ctl_bits_5_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
# After addition of buffer chains on multiple nets execute the following
# place_eco
# route_eco
# 
################################################################################

proc get_drv_to_rcv_pins_data_list {net_name ignore_dist} {
    #
    # Assumption : A net has a single driver pin but can have any number of receiver pins
    #
    set drv_pin [get_db [get_db nets $net_name] .driver_pins]
    set ret_drv_pin $drv_pin
    if {[llength $drv_pin] > 1} {
        puts "%ERROR : Driver has more than 1 driver pin"
    }
    set drv_pin_name [get_db $drv_pin .name]
    set drv_pin_loc_x [get_db $drv_pin .location.x]
    set drv_pin_loc_y [get_db $drv_pin .location.y]
    set load_pin_list [get_db [get_db nets $net_name] .load_pins]
    set ret_dist 0
    set ret_rcv_pin 0
    set ret_rcv_pin_list [list]
    foreach rcv_pin $load_pin_list {
        set rcv_pin_name [get_db $rcv_pin .name]
        set rcv_pin_loc_x [get_db $rcv_pin .location.x]
        set rcv_pin_loc_y [get_db $rcv_pin .location.y]
        # Find the radial between the driver pin and the receiving pin
        set rdist [expr {sqrt(pow(($rcv_pin_loc_x - $drv_pin_loc_x),2) + pow(($rcv_pin_loc_y - $drv_pin_loc_y),2))}]
        if {$rdist > $ignore_dist} {
            lappend ret_rcv_pin_list $rcv_pin
        }
    }
    # We will now find the average x and y of the cluster of rcv pins
    set tot_pin_x 0
    set tot_pin_y 0
    set pin_cnt 0
    foreach pin $ret_rcv_pin_list {
        set pin_x [get_db $pin .location.x]
        set tot_pin_x [expr {$tot_pin_x + $pin_x}]
        set pin_y [get_db $pin .location.y]
        set tot_pin_y [expr {$tot_pin_y + $pin_y}]
        incr pin_cnt
    }
    if {$pin_cnt != 0 } {
        set avg_x [expr {$tot_pin_x/$pin_cnt}]
    } else {
        set avg_x $drv_pin_loc_x
    }
    if {$pin_cnt != 0 } {
        set avg_y [expr {$tot_pin_y/$pin_cnt}]
    } else {
        set avg_y $drv_pin_loc_y
    }
            
    set ret_rdist [expr {sqrt(pow(($avg_x - $drv_pin_loc_x),2) + pow(($avg_y - $drv_pin_loc_y),2))}]
    set ret_rcv_loc [list $avg_x $avg_y]
 
    return [list $ret_rdist $ret_rcv_loc $ret_drv_pin $ret_rcv_pin_list]
}

proc get_new_rcv_loc { drv_loc rcv_loc rel_dist_of_new_rcv } {

    set drv_loc_x [lindex $drv_loc 0] 
    set drv_loc_y [lindex $drv_loc 1]
    set rcv_loc_x [lindex $rcv_loc 0] 
    set rcv_loc_y [lindex $rcv_loc 1]
    
    
    set delta_x [expr {$rcv_loc_x - $drv_loc_x}]
    set delta_y [expr {$rcv_loc_y - $drv_loc_y}]
    
    set new_rcv_loc_x [expr {$rcv_loc_x - $delta_x*$rel_dist_of_new_rcv}] 
    set new_rcv_loc_y [expr {$rcv_loc_y - $delta_y*$rel_dist_of_new_rcv}] 
    
    return [list $new_rcv_loc_x $new_rcv_loc_y]
}


#
# Given a net, the routine will try to add repeaters from the driver to receiver pins as long as the distance from
# the driver to receiving pins exceeds the 'max_rpt_dist' value.
#
proc add_buffer_chain_on_net {net_name max_rpt_dist cell} {
    set_db eco_batch_mode true
    set ret_data_list [get_drv_to_rcv_pins_data_list $net_name $max_rpt_dist]
    set dist [lindex $ret_data_list 0]
    set rcv_loc [lindex $ret_data_list 1]
    set drv_pin [lindex $ret_data_list 2]
    set rcv_pin_list [lindex $ret_data_list 3]
    set net_name_list [list]    
    while {$dist > $max_rpt_dist} {
        set drv_pin_name [get_db $drv_pin .name] 
        set rcv_pin_name_list [list]
        foreach rcv_pin $rcv_pin_list {
            set pin_name [get_db $rcv_pin .name]
            lappend rcv_pin_name_list $pin_name
        }
        puts "%INFO: Adding additional buffers between $drv_pin_name and {$rcv_pin_name_list} : dist = $dist"
        if {[llength $rcv_pin_list] > 1} {
            # If there are multiple receive pins that we need to connect to using the added driver, we 
            # do not move the location that we got originally.
            set rel_dist_of_new_rcv 0
        } else {
            set rel_dist_of_new_rcv [expr {$max_rpt_dist/$dist}]
        }
        puts "%INFO: Rel Distance of new rcv from current rcv in terms of current rcv to drv distance : $rel_dist_of_new_rcv"
        set drv_loc_x [get_db $drv_pin .location.x]
        set drv_loc_y [get_db $drv_pin .location.y]
        set drv_loc [list $drv_loc_x $drv_loc_y]
        set new_rcv_loc [get_new_rcv_loc $drv_loc $rcv_loc $rel_dist_of_new_rcv]
        puts "eco_add_repeater -cells $cell -location $new_rcv_loc -pins $rcv_pin_name_list"
        set result [eco_add_repeater -cells $cell -location $new_rcv_loc -pins $rcv_pin_name_list]
        set new_inst_name [lindex $result 0]
        # net that we are currently operating on (i.e $net_name)
        set inp_net_name [lindex $result 1]
        # Newly added net at the output of the newly added buffer
        set out_net_name [lindex $result 2]
        lappend net_name_list $out_net_name
        set ret_data_list [get_drv_to_rcv_pins_data_list $net_name $max_rpt_dist]
        set dist [lindex $ret_data_list 0]
        set rcv_loc [lindex $ret_data_list 1]
        set drv_pin [lindex $ret_data_list 2]
        set rcv_pin_list [lindex $ret_data_list 3]
    }    
    deselect_obj -all
    # Delete the old net/routes
    select_obj [get_db nets $net_name]
    delete_selected_from_floorplan
    # add the original net to the net_name_list and select them
    lappend net_name_list $net_name
    select_obj [get_db nets $net_name_list]
    set_db eco_batch_mode false
}

#
# Following nets were cleaned up for dynamic IR violations on the drivers because of cutting down 
# on the long routes from driver to receiver. This works on paths with slacks. 
#
#add_buffer_chain_on_net jtg__hub_ctl_bits_5_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_ctl_bits_4_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_scan_ctl_15_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_ctl_bits_9_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_scan_ctl_12_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_scan_ctl_13_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tie__apn_ap_hub_state_bits_2_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_scan_ctl_14_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_ctl_bits_3_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tie__apn_ap_hub_state_bits_0_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_ctl_bits_0_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tie__apn_ap_hub_state_bits_1_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tie__apn_ap_hub_state_bits_3_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net jtg__hub_scan_ctl_8_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tie__apn_ap_hub_state_bits_5_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net pad__hub_scan_cmp_in_0_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tdh__apn_rml_0_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tdh__apn_rml_1_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#add_buffer_chain_on_net tdh__apn_rml_2_N_iso_in_buff 20 BUFFD3BWP210H6P51CNODULVTLL
#place_eco
#route_eco
