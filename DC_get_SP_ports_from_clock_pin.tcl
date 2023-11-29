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


proc get_startpoint_ports_for_clock_pin { reg_file } {
    set logic_file   [open ../reports/logic_zero_unconnected_regs.rpt w]
    set uncon_file   [open ../reports/real_unconst_regs.rpt w]
    set inter_file   [open ../reports/real_unconst_regs_to_gen_clock.rpt w]
############################################
# get all clock pins of unclock cells      #
# ##########################################
#set reg_file "./unclockd_regs.rpt"
    set eplist [file_to_list $reg_file]
    
    foreach cell $eplist {
#    puts $cell
        set p [filter_collection [get_pins -of_object [get_cells $cell]] "name=~CK OR name=~CLOCK OR name=~CLK OR name=~clk OR name=~ck OR name=~clock OR name=~clocked_on OR name=~CP OR name=~G OR name=~CKB"]
        if {$p == ""} { lappend nopins $cell } else {
            lappend pins [get_object_name $p ]
        }
    }
#pl $pins
############################################
#find all start point of clock pins        #
############################################
    foreach pin $pins {
        set go 1
        set startp [ all_fanin -to $pin -flat ]
        
        foreach_in_collection sp $startp {
            set spn [get_object_name $sp ]
        puts $spn
        if {[regexp {\*\*logic_0\*\*} $spn ] || [regexp {\*\*logic_1\*\*} $spn ]} {
               puts $logic_file [ get_object_name [ get_cell -of_object [ get_pins $pin ]]]
               set go 0;
                break
            }
        }
        if {$go == 0} {continue}
        set ports ""
        set port_list ""
        set ports [filter_collection  $startp  "object_class == port"]
        foreach_in_collection port $ports {
            lappend port_list [get_object_name $port]
        }
        if {$port_list==""} {
            puts $inter_file "CELL NAME: [get_object_name [get_cell -of_object [get_pins $pin]]]"
            puts $inter_file  $pin
            foreach_in_collection start $startp {
             puts $inter_file [get_object_name $start]
             puts "---------------------------"
            }

        } else {
            puts $uncon_file "CELL NAME: [get_object_name [get_cell -of_object [get_pins $pin]]]"
            puts $uncon_file $port_list
            puts "---------------------------"

        }
        unset port_list

    }
close $logic_file
close $uncon_file
close $inter_file


}
