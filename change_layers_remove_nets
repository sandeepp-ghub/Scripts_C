
#create list of short nets
set count 0
unset nets_to_remove
foreach mkr [get_db current_design .markers -if {.subtype == Metal_Short}] {
    foreach net [get_db $mkr .objects] {
	if {[string match [get_db $net .obj_type] "net"]} {
	    lappend nets_to_remove $net

	    set bot_preferred_layer [get_db $net .bottom_preferred_layer]
	    set top_preferred_layer [get_db $net .top_preferred_layer]
	    set user_bot_preferred_layer [get_db $net .route_user_bottom_preferred_routing_layer]
	    if {[string match $bot_preferred_layer "layer:M13"] || \
		    [string match $bot_preferred_layer "layer:M14"] || \
		    [string match $bot_preferred_layer "layer:M15"] || \
		    [string match $bot_preferred_layer "layer:M16"] \
		} {
		echo "Net: $net"
		echo "Bot was: $bot_preferred_layer"
		echo "Top was: $top_preferred_layer"
		echo "User_bot was: $user_bot_preferred_layer"
	    
		# change bottom layer from M13+ down to M11 and top layer to M14
		set_db $net .route_user_bottom_preferred_routing_layer M11
		set_route_attributes -nets [get_db $net .name] -bottom_preferred_routing_layer 12
		set_route_attributes -nets [get_db $net .name] -top_preferred_routing_layer 15

		set bot_preferred_layer [get_db $net .bottom_preferred_layer]
		set top_preferred_layer [get_db $net .top_preferred_layer]
		set user_bot_preferred_layer [get_db $net .route_user_bottom_preferred_routing_layer]
		echo "Bot changed to: $bot_preferred_layer"
		echo "Top changed to: $top_preferred_layer"
		echo "User_bot changed to: $user_bot_preferred_layer"
		
		set count [expr $count+1]
	    }
	}
    }
}
echo $count
delete_routes -net $nets_to_remove
