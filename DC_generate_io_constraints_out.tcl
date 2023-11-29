###################################################
# get unconst port file and put const             #
###################################################

set port_file "../reports/dct/temp_out"
redirect  ../work/no_good_ports_out.tcl   {puts ""}
redirect  ../work/output_del_out.tcl      {puts ""}
redirect  ../work/internal_clock_driving_out_ports.rpt  {puts ""}
set port_list [file_to_list $port_file]
foreach port $port_list {
############################################################
# getting all valid start point for port (reg clk pins)    #
# ##########################################################
    set brk "0"
    set clkPortsCol [filter_collection \
                        [filter_collection [ \
                            all_fanin -to $port -flat -startpoints_only \
                        ] "name==CK OR name==CP OR name==clocked_on"] \
                     "name!=\*\*logic_0\*\* AND name!= \*\*logic_1\*\*"]
    if {$clkPortsCol ==""} {puts "no valid startpoint to $port"; continue } 
#######################################################
# going over every clock pin and look for clock ports # 
#                                                     #
#######################################################
    unset -nocomplain clkpn
    foreach_in_collection clkpobj $clkPortsCol {
       lappend clkpn [get_object_name $clkpobj]
    } 
# all clock pins of regs 
       set clock_drivers_col [all_fanin -to $clkpn -flat -startpoints_only]
       set clock_driver_ports_col [filter_collection  $clock_drivers_col  "object_class == port"]
       unset -nocomplain temp
       foreach_in_collection clkp $clock_driver_ports_col {
            foreach_in_collection clk [all_clocks] {
                set clk_source [get_object_name [get_attr $clk sources]]
                if {$clk_source eq [get_object_name $clkp]} {
                    append_to_collection temp $clkp
                    break
                }
            }        
       }
       if {[info exists temp]} {
            set clock_driver_ports_col $temp
            puts "1"
       } else {
           redirect -append ../work/internal_clock_driving_out_ports.rpt { 
                pc $port;                                          
                pc $clock_drivers_col;
                puts "==========================" ;
           }
           continue ; # noting to do with port have no clock port driver go to next one
       }
       set oldClock [index_collection $clock_driver_ports_col 0]
#################################################
# going over clock ports and look for conflicts #
# ###############################################
       foreach_in_collection clockPort $clock_driver_ports_col {
            if {[compare_collection $oldClock $clockPort]=="0"} {
            } else {
                redirect -append ../work/no_good_ports_out.tcl {puts "port $port is been drived by two clocks ports [get_object_name $oldClock] [get_object_name $clockPort]"; pc $clock_driver_ports_col}; 
                set brk 1; 
                break; 
            }
       }
        
    
if {$brk == "1"} {continue }
########################################################
# going from clock port to clock name and get period  #
# ######################################################
  foreach_in_collection clk [all_clocks] {
        set clk_source [get_object_name [get_attr $clk sources]]
        if {$clk_source eq [get_object_name $oldClock]} {
            set oldClock $clk
            break
        }
    }

  set clock_period [get_attr $oldClock period]
  set const "set_output_delay \[expr 0.65 * $clock_period\] -clock \[get_clocks [get_object_name $oldClock]\] \[get_ports $port\]"
  redirect -append ../work/output_del_out.tcl {puts $const}
}

