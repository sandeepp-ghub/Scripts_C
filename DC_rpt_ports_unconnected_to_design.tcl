#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: go over a file line by line and append to list        #
#====================================================================#
# Example: set <list name> [file_to_list <file path>]                #
#====================================================================#


proc report_ports_unconnected_to_design {args} {
    set con 0
    set tot 0
    parse_proc_arguments -args ${args} results
    foreach_in_collection port $results(input_port_col) {
        set dir [get_attr $port port_direction]
        if {$dir eq "in"} {
            set fan [all_fanout -flat -endpoints_only -from [get_object_name $port]]
        } else {
            set fan [all_fanin -flat -startpoints_only -to [get_object_name $port]]
        }
        
        if {$fan eq ""} {
            puts [format "port %-40s  is not connected to design" [get_object_name $port]]
        } else {
            puts [format "port %-40s is connected to design"  [get_object_name $port]]
            incr con
        }
        incr tot
    }
    return "$con of $tot ports are connected to the design"

}
define_proc_attributes report_ports_unconnected_to_design \
    -info "report on ports how do not have fanin/out endpoint in the design" \
    -define_args {
 {input_port_col         "input ports collection"          input_port_col list required}
}

