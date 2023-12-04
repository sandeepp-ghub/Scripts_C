#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: zoom to object and highlight                          #
#====================================================================#
# Example: zoom -cell <some cells> -h red                            #
#====================================================================#


proc zoom { args } {
########################################
# parse input args                     #
########################################
    
    parse_proc_arguments -args ${args} results
    if {[info exists results(-add_to)]}  {puts "adding to current selection"} else { change_selection }
    if {[info exists results(-cell)]}      {change_selection -add  [get_cells $results(-cell) ]       }
    if {[info exists results(-cell_col)]}  {change_selection -add  $results(-cell_col)                }
    if {[info exists results(-port)]}      {change_selection -add  [get_ports $results(-port) ]       }
    if {[info exists results(-port_col)]}  {change_selection -add  $results(-port_col)                }
    if {[info exists results(-net)]}       {change_selection -add  [get_nets $results(-net) ]         }
    if {[info exists results(-via)]}       {change_selection -add  [get_vias $results(-via) ]         }
    if {[info exists results(-via_col)]}   {change_selection -add  $results(-via_col) ]               }
    if {[info exists results(-net_col)]}   {change_selection -add  $results(-net_col)                 }
    if {[info exists results(-pin)]}       {change_selection -add  [get_pins $results(-pin) ]         }
    if {[info exists results(-pin_col)]}   {change_selection -add  $results(-pin_col)                 }
    if {[info exists results(-shape)]}     {change_selection -add  [get_net_shapes $results(-shape) ] }
    if {[info exists results(-shape_col)]} {change_selection -add  $results(-shape_col)               }
    if {[info exists results(-highlight)]} { gui_change_highlight -add -color $results(-highlight)  -collection [get_selection] }
    gui_zoom -window [gui_get_current_window -types "Layout" -mru] -selection

}

define_proc_attributes zoom \
    -info "select and zoom view to a given collection -help" \
    -define_args {
        {-cell      ""           "" list optional}
        {-port      ""           "" list optional}
        {-net       ""           "" list optional}
        {-via       ""           "" list optional}
        {-via_col       ""           "" list optional}
        {-pin       ""          "" list optional}
        {-shape     ""           "" list optional}
        {-cell_col  ""           "" list optional}
        {-port_col  ""           "" list optional}
        {-net_col   ""           "" list optional}
        {-pin_col   ""           "" list optional}
        {-shape_col ""           "" list optional}
        {-add_to    ""           "" boolean optional}
        {-highlight "highlight the new collection in gui" ""  one_of_string {optional value_help {values {yellow orange red green blue purple light_orange light_red light_green light_blue light_purple}}}}
}

