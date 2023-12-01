get_db current_design .markers -if  {.user_type == M1.CS.6.1} -foreach {

           set box [get_db $object .bbox]
set net_list [get_db [get_obj_in_area -area $box -obj_type patch_wire] .net.name]
delete_routes -net $net_list
foreach x $net_list {
select_obj [get_db nets $x]
}

}


# Skip the prerouted nets and route only the selected nets
set_route_attributes -nets @PREROUTED -skip_routing true
set_db route_design_selected_net_only true
route_design
#Reset skip_routing and deselect all nets    
set_route_attributes -nets @PREROUTED -skip_routing false
gui_deselect -all


