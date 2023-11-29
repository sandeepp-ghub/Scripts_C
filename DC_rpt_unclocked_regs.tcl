#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 21/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: Find unclocked register in the design.                #
#              print a verbose report on the unclocked FF,           #
#              the possible reason for the problem and relevant      #
#              information for solving it                            #
#====================================================================#
# Example: report_unclocked_registers <output file name>             #
#====================================================================#






proc is_connected_to_constant {args} {
    set results(-level) 2
    parse_proc_arguments -args ${args} results
    set pin $results(pin_name)

########################################
# level 1                              #
########################################
    set spoint [list]
    set spoint [all_fanin -to $pin -flat -startpoints_only]
    foreach_in_collection sp $spoint {
         set spn1 [get_object_name $sp ]
         if {[regexp {\*\*logic_0\*\*} $spn1 ] || [regexp {\*\*logic_1\*\*} $spn1 ]} {
            return 1
         }
    if {[info exists results(-level)]} {
        if {$results(-level) eq "1"} {
            continue
        }
    }
########################################
# level 2                              #
########################################
         set spoint_cell ""
         set spoint_cell [all_fanin -to $pin -flat -startpoints_only -only_cells ] ;#first level start point cells
         foreach_in_collection spc $spoint_cell {               ;# run on every first level start point cell
             set spoint_cell_input_pin [get_pins -of_object $spc -filter "pin_direction==in"]
             foreach_in_collection sp_pin2 $spoint_cell_input_pin { ;# run on every pin of a start point cell
                 set spn_pin2 [get_object_name $sp_pin2]
                 set spoint2 [all_fanin -to $spn_pin2 -flat -startpoints_only]
                 foreach_in_collection sp2 $spoint2 {          ;# run on every start point of a pin of pin of start point cell
                     set spn2 [get_object_name $sp2]
                     if {[regexp {\*\*logic_0\*\*} $spn2 ] || [regexp {\*\*logic_1\*\*} $spn2 ]} {
                         return 1
                     }
                 }
              }
         }
     }
    return 0
}

define_proc_attributes is_connected_to_constant \
    -info "Get a pin and return 1 if this pin is connected to logic0/1 in level 1 or 2 of fanin from him -help" \
    -define_args {
    {pin_name "" "" string required}
    {-level "" "" int optional}
}

proc report_unclocked_registers {args} {
    parse_proc_arguments -args ${args} results
##### find all unclocked FF ######
global TopModule
    
    # collect all unclocked registers
    set unclocked_regs [filter_collection [all_registers] "full_name !~ ${TopModule}_bonus_top/ADDED_BONUS*"]
    
    foreach_in_collection clock [get_clocks] {
    
        set unclocked_regs [remove_from_collection ${unclocked_regs} [all_registers -clock ${clock}]]
    
    }

    set ff_list "" ; # in the begining it was a file
    foreach_in_collection cell ${unclocked_regs} {
    
        lappend ff_list [get_object_name ${cell}]
    
    }
###############################
set logic_zero ""
set others ""
set clockandports ""
set clockandpins ""
set logic_zero_count 0
set others_count 0
set i 0
foreach cell $ff_list {
    set p [filter_collection [get_pins -of_object [get_cells $cell]] "name=~CK OR name=~CLOCK OR name=~CLK OR name=~clk OR name=~ck OR name=~clock OR name=~clocked_on OR name=~CP OR name=~G OR name=~CKB"]
    set true [is_connected_to_constant [get_object_name $p]]
    if {$true eq "1"} {
        redirect -variable logic_zero -append {puts $cell}
        incr logic_zero_count
    } else {
        redirect -variable others -append {puts $cell}
        incr others_count
        #-- see if p have ports in hisfanin
        set startp [ all_fanin -to [get_object_name $p] -flat ]
        set ports [filter_collection  $startp  "object_class == port"]
        if {$ports eq ""} {
            redirect -variable clockandpins -append {
                puts "CELL: $cell"
                foreach_in_collection pin $startp {
                    puts [get_object_name $pin]
                }
            }
        } else {
            redirect -variable clockandports -append {
                puts "CELL: $cell"
                foreach_in_collection port $ports {
                    puts [get_object_name $ports]
                }
            }
        }

    }
    incr i
}

if {[info exists results(output_file_name)]} {
    set OUT [open $results(output_file_name) w]
    puts ${OUT} "SUMMARY REPORT:"
    puts ${OUT} "==============="
    puts ${OUT} "Total of $i FF are unclockd"
    puts ${OUT} "$logic_zero_count FF are connected to logic zero in level one or two"
    puts ${OUT} "$others_count FF are not drived by any clock or logic zero please have a look below for details"

    puts ${OUT} "REAL UNCLOCKED REGISTERS"
    puts ${OUT} "========================="
    puts ${OUT} $others
    puts ${OUT} ""
    puts ${OUT} "FF CONNECTED TO ZERO"
    puts ${OUT} "===================="
    puts ${OUT} $logic_zero
    puts ${OUT} ""
    puts ${OUT} "FULL REPORT"
    puts ${OUT} "==========="
    puts ${OUT} ""
    puts ${OUT} "UNCLOCKED REGISTER WITH PORTS DETECTED IN THERE CLOCK PIN FANIN (probably undefined clock port)"
    puts ${OUT} "==============================================================================================="
    puts ${OUT} $clockandports
    puts ${OUT} ""
    puts ${OUT} "UNCLOCKED REGISTER WITH NO PORTS DETECTED IN THERE CLOCK PIN FANIN (probably undefined generated clock)"
    puts ${OUT} "======================================================================================================="
    puts ${OUT} $clockandpins
    puts ${OUT} ""
    close ${OUT}
} else {
    puts "SUMMARY REPORT:"
    puts "==============="
    puts "Total of $i FF are unclockd"
    puts "$logic_zero_count FF are connected to logic zero in level one or two"
    puts "$others_count FF are not drived by any clock or logic zero please have a look below for details"

    puts "REAL UNCLOCKED REGISTERS"
    puts "========================="
    puts $others
    puts ""
    puts "FF CONNECTED TO ZERO"
    puts "===================="
    puts $logic_zero
    puts ""
    puts "DETAIL REPORT"
    puts "============="
    puts ""
    puts "UNCLOCKED REGISTER WITH PORTS DETECTED IN THERE CLOCK PIN FANIN (probably undefined clock port)"
    puts "==============================================================================================="
    puts $clockandports
    puts ""
    puts "UNCLOCKED REGISTER WITH NO PORTS DETECTED IN THERE CLOCK PIN FANIN (probably undefined generated clock)"
    puts "======================================================================================================="
    puts $clockandpins
    puts ""
}

return ""
}

define_proc_attributes report_unclocked_registers \
    -info "Find unclocked register in the design. print a verbose report on the unclocked FF, \n the possible reason for the problem and relevant information for solving it" \
    -define_args {
    {output_file_name "string" "output file name. if not define output go to screen" string optional}
}

