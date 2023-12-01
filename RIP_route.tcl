# Deselect everything
gui_deselect -all
# Specify file with list of nets to delete and reroute
set NETFILE [open "nets.list" r+ ]
# Delete each net specified in the file
foreach i [read $NETFILE] { \
   delete_routes -net $i -type Regular \
}
close $NETFILE
# Select each net specified in the file
set NETFILE [open "nets.list" r+ ]
foreach i [read $NETFILE] { \
     select_obj [get_db nets $i]     \
}
 close $NETFILE
# Skip the prerouted nets and route only the selected nets
set_route_attributes -nets @PREROUTED -skip_routing true
set_db route_design_selected_net_only true
route_design
#Reset skip_routing and deselect all nets    
set_route_attributes -nets @PREROUTED -skip_routing false
gui_deselect -all
set_db route_design_selected_net_only false
