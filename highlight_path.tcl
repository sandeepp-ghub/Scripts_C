#highlight_path -from top/reg1/Q -to top/reg2/D
#highlight_path -from [get_pins -hier *reg*/Q] -to [all_outputs]
# Procedure that traces the logic cone from one or more startpoints to all endpoints or to specific list of endpoints
proc highlight_path {args} {

    parse_proc_arguments -args $args results

    deselect_obj -all

    set startpoint $results(-from)
    
    set startpoint_pins [get_db [get_pins $startpoint] -if {.obj_type == "pin"} ]
    set startpoint_inst [get_db [get_pins $startpoint_pins] .inst]
    gui_highlight -color red $startpoint_inst
    
    if {[info exist results(-to)]} {     
        set endpoint   $results(-to)
        select_obj  [get_db [all_fanout -from $startpoint -to $endpoint ] .net]
        
        set_message -id TCLCMD-917 -suppress 
        set endpoint_pins [get_db [get_pins $endpoint] -if {.obj_type == "pin"} ]
	    set endpoint_inst [get_db [get_pins $endpoint_pins] .inst]
        gui_highlight -color yellow $endpoint_inst
        set_message -id TCLCMD-917 -unsuppress 
    } else {
    	select_obj  [get_db [all_fanout -from $startpoint ] .net]
    }
    gui_highlight -color blue [get_db selected]
    
    deselect_obj -all
}




define_proc_arguments highlight_path -info "Command Description" \
   -define_args \
   {
    {-from  "startpoint" "string_val" string {required}}
    {-to    "endpoint"   "string_val" string {optional}}
   }

