#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: given an input pin can look for a connection to       #
# const two levels deep (return 1 if true)                           #
#====================================================================#
# Example: look_for_const top/reunit_FF123/CK                        #
#          0                                                         #
#====================================================================#


proc look_for_const {args} {
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

define_proc_attributes look_for_const \
    -info "get a pin and return 1 if this pin is connected to logic0/1 in level 1 or 2 of fanin from him -help" \
    -define_args {
    {pin_name "" "" string required}
    {-level "" "" int optional}
}

