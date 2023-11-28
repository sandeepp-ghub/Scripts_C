#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: when used on clock pin will go over the fanin of the  #
# pin and look for clock source.                                     #
# when used on port go over all FF in the fanin/out of the port      #
# find all clocks driving those FF                                   #
#                                                                    #
#====================================================================#
# Example: soc_find_possible_clocks  <port name / input pin name>        #
#====================================================================#

proc soc_find_possible_clocks {args} {
    parse_proc_arguments -args ${args} results
    set port $results(portORpin) 
###################################
# work on ports                   #
###################################
    if {[get_port -quiet $port] != "" } {
        set port_direction [get_attr [get_ports $port] direction]
        if {$port_direction eq "in"} {
            set regs [all_fanout -from $port -endpoints_only -flat -only_cells]
        } else {
            set regs [all_fanin -to $port -startpoints_only -flat -only_cells]
        }
        #-- remove regunit regfiles regs from regs....!?!
        if {[info exists results(-regunit_regfile_continue)]} {
            set regs [filter_collection $regs "full_name!~regunit_top/*"]
        }
        if {$regs==""} {puts "no regs connected to port"; return "";}
        set clk_pins [filter_collection [get_pins -of_object $regs] "name==CK OR name==CKQ OR name==CP OR name==clocked_on OR name==CB OR name==G OR name==CKB"]
        unset -nocomplain temp
        foreach_in_collection clk_pin $clk_pins {
            set cpn [get_object_name $clk_pin]
            set clk_start_point [all_fanin -to $cpn -startpoints_only -flat]
            set clock_driver_ports_col $clk_start_point
            foreach_in_collection clkp $clock_driver_ports_col {
                 foreach_in_collection clk [all_clocks] {
                     set clk_source [get_object_name [get_attr $clk sources]]
                     if {$clk_source eq [get_object_name $clkp]} {
                         set clk_name [get_object_name $clk]
                         lappend temp $clk_name
# break 
                     }
                 }
            }
        }
        if {[info exists temp]} {
            return [lsort -uniq $temp]
        }
###################################
# work on clk pins                #
###################################
    } else {
        set clk_start_point [all_fanin -to $port -startpoints_only -flat]
        set clock_driver_ports_col $clk_start_point
#set clock_driver_ports_col [filter_collection  $clk_start_point  "object_class == port"]
        foreach_in_collection clkp $clock_driver_ports_col {
             foreach_in_collection clk [all_clocks] {
                 set clk_source [get_object_name [get_attr $clk sources]]
                 if {$clk_source eq [get_object_name $clkp]} {
                     set clk_name [get_object_name $clk]
                     lappend temp $clk_name
                     break
                 }
             }
        }
        if {[info exists temp]} {
            return [lsort -uniq $temp]
        }

    }
     return ""
}


define_proc_attributes soc_find_possible_clocks \
    -info "when used on clock pin will go over the fanin of the \n pin and look for clock source. \n when used on port go over all FF in the fanin/out of the port \n find all clocks driving those FF and generat a list of clocks  \n" \
    -define_args {
    {portORpin "string" "input pin" string required}
    {-regunit_regfile_continue "dont take regunit ff clock in to clock list"  "" boolean optional}
  }

