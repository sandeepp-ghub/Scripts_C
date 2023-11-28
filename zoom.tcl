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
    # Dont clear highlight
    if {[info exists results(-add_to)]}  {
        puts "adding to current selection"
    } else { 
        gui_deselect -all 
    }
    if {[info exists results(-inst)]}      {
        if {[regexp {(inst\:.+?\/)(.*)} $results(-inst)]} {
            set results(objects) $results(-inst)
        } else {
            set  results(objects) [get_db insts  $results(-inst)]
        }
    }
    if {[info exists results(-port)]}      {
        if {[regexp {(port\:.+?\/)(.*)} $results(-port)]} {
            set results(objects) $results(-port)
        } else {
            set  results(objects) [get_db ports  $results(-port)]
        }
    }
    if {[info exists results(-net)]}       {
        if {[regexp {(net\:.+?\/)(.*)} $results(-net)]} {
            set results(objects) $results(-net)
        } else {
            set  results(objects) [get_db nets   $results(-net) ]
        }
    }
    if {[info exists results(-wire)]}       {
            set results(objects) $results(-wire)
    }

    if {[info exists results(-pin)]}       {
        if {[regexp {(pin\:.+?\/)(.*)} $results(-pin)]} {
            set results(objects) $results(-pin)
        } else {
            set  results(objects) [get_db pins   $results(-pin) ]
        }
    }
#   if {[info exists results(-shape)]}     {set  results(objects) [get_db shapes $results(-shape) ]}
    
    select_obj $results(objects) 
    gui_zoom -selected
    gui_zoom -in
    if {[info exists results(-highlight)]} { 
    # gui_; 
        gui_highlight -color $results(-highlight)
    }
  
}

define_proc_arguments zoom \
    -info "select and zoom view to a given collection -help" \
    -define_args {
        {objects    ""           "" list optional}
        {-inst      ""           "" list optional}
        {-port      ""           "" list optional}
        {-net       ""           "" list optional}
        {-wire      ""           "" list optional}
        {-pin       ""          ""  list optional}
        {-add_to    ""           "" boolean optional}
        {-highlight "highlight the new collection in gui" ""  one_of_string {optional value_help {values {yellow orange red green blue purple light_orange light_red light_green light_blue light_purple}}}}
}

#        {-cell      ""           "" list optional}
#        {-port      ""           "" list optional}
#        {-net       ""           "" list optional}
#        {-pin       ""          "" list optional}
#        {-shape     ""           "" list optional}
#        {-cell_col  ""           "" list optional}
#        {-port_col  ""           "" list optional}
#        {-net_col   ""           "" list optional}
#        {-pin_col   ""           "" list optional}
#        {-shape_col ""           "" list optional}

