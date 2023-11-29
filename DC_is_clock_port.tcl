#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: get a pin|port name go over all clocks sources and    #
# look for a match.                                                  #
#                                                                    #
#====================================================================#
# Example:  is_clock_port  core_clk                                  #
#           CORE_CLK                                                 #
#           1                                                        #
# Example2: if {![is_clock_port $clk -no_verbose]} {.....}           #
#====================================================================#

proc is_clock_port {args} {
    set return_val 0
    parse_proc_arguments -args ${args} results
    set port_name $results(pin_name)
    foreach_in_collection clk [all_clocks] {
        set clk_source [get_object_name [get_attr $clk sources]]
        if {$clk_source eq $port_name} {
            if {![info exists results(-no_verbose)]} {puts [get_object_name $clk]}
            set return_val 1
        }
    }
    return $return_val
}

define_proc_attributes is_clock_port \
    -info "get a pin|port name go over all clocks sources and look for a match." \
    -define_args {
    {pin_name string "pin OR port name" string required}
    {-no_verbose  "do not print clock name only return value"  "" boolean optional}

  }

