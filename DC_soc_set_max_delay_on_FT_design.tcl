#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 4/11/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: write a FT max delay file for current cel             #
#====================================================================#
# Example:soc_set_max_delay_on_FT_in_the_design -keep_current_max_delay
#====================================================================#

#-- create a long max delay file. max delay will be input+output delay + 0.33*clock period
proc soc_set_max_delay_on_FT_in_the_design {args} {
    redirect -file ./FT_file_out_temp {puts ""}
    parse_proc_arguments -args ${args} results
    set inputs [all_inputs]
    puts "LIORAL-Info: find all IN-->OUTs pr"
    foreach_in_collection in $inputs {
        set in_name [get_object_name $in]
        #-- filter clocks input
        if {[soc_is_clock_port $in_name -no_verbose]} {puts "LIORAL-Info: port $in_name is clock input port no action done..";continue}
        set outs [filter_collection [all_fanout -from $in_name -flat -endpoints_only] object_class==port]
        if {$outs eq ""} {continue}
        set db($in_name) $outs
    }
    foreach in_name [array names db] {
        foreach_in_collection out_col $db($in_name) {
            #-- see if  max_delay exists b p_in --> p_out on the ports
            if {[info exists results(-keep_current_max_delay)]} {
                redirect -variable temp {
                    report_timing -from $in_name -to $out_col
                }
                if {[regexp {max_delay[ ]+[\-0-9\.]+[ ]+[\-0-9\.]+} $temp]} {
                    puts "LIORAL-Info: $in_name --> [get_object_name $out_col] have prev max delay no action done..."
                    continue;
                }
            }
            #-- get input clock
            set path        [get_timing_path -from $in_name -to $out_col -max_path 1 -slack_lesser_than 10]
            set spointClock   [get_attr $path startpoint_clock]           ;# path start point clock
            if {$spointClock eq ""} {puts "LIORAL-Warning: no clock for port $in_name"; continue;}
            set spointClock [index_collection $spointClock 0]
            set spointClockP  [get_attr [get_clocks $spointClock] period]
            #-- look for start and end point delay for max_delay calc
            set sdel [get_attr $path startpoint_input_delay_value]
            if {$sdel eq ""} {puts "LIORAL-Warning: no input delay for port $in_name"; continue;}
            set sdel [lindex $sdel 0]
            set edel [get_attr $path endpoint_output_delay_value]
            if {$edel eq ""} {puts "LIORAL-Warning: no output delat for port [get_object_name $out_col]"; continue;}
             set edel [lindex $edel 0]
            #-- if max_del not set in the past set it so data will have 0.33 clock p
            puts "$in_name $sdel [get_object_name $out_col] $edel $spointClock $spointClockP"
            set delay [expr {$sdel - $edel + $spointClockP*0.33}]
            redirect -file ./FT_file_out_temp -append -tee {
                puts "set_max_delay $delay -from $in_name -to [get_object_name $out_col]"
            }
        }
    };# end of run on all I/O ports
    merge_FT_file "./FT_file_out_temp" > FT_file_merge 
    #-- probeb dot working

}; #end of proc
define_proc_attributes soc_set_max_delay_on_FT_in_the_design \
    -info "return a FT max delay file for current design" \
    -define_args {
    {-keep_current_max_delay  "don't change existing max delay"  "" boolean optional}
  }




#-- merge bus signal to [*] to get a smaller file
proc merge_FT_file { input_file } {
    redirect -file out_file { puts ""}
    set budget_list [file_to_list $input_file]
    foreach l $budget_list {
        if {$l eq ""}           {continue}
        if {[regexp {^(#)} $l]} {continue}
        set ll [split $l]    
        regexp {([^[]*)} [lindex $ll 3] --> bus_nameA
        regexp {([^[]*)} [lindex $ll 5] --> bus_nameB
        set     port_table($bus_nameA$bus_nameB,A)         $bus_nameA   
        set     port_table($bus_nameA$bus_nameB,B)         $bus_nameB
        set db($bus_nameA,$bus_nameB) $ll
    }
    foreach l [array names db] {
        if {[regexp {\[} [lindex $db($l) 3] ]} {set db($l,A,is_bus) yes} else {set db($l,A,is_bus) no}
        if {[regexp {\[} [lindex $db($l) 5] ]} {set db($l,B,is_bus) yes} else {set db($l,B,is_bus) no}
        regexp {([^[]*)} [lindex $db($l) 3] --> bus_nameA
        regexp {([^[]*)} [lindex $db($l) 5] --> bus_nameB
        if {$db($l,A,is_bus) eq "yes"} {lset db($l) 3 "${bus_nameA}[*]"}
        if {$db($l,B,is_bus) eq "yes"} {lset db($l) 5 "${bus_nameB}[*]"}
        puts [join $db($l)]
    }

return 0
}


proc soc_is_clock_port {args} {
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

define_proc_attributes soc_is_clock_port \
    -info "get a pin|port name go over all clocks sources and look for a match." \
    -define_args {
    {pin_name string "pin OR port name" string required}
    {-no_verbose  "do not print clock name only return value"  "" boolean optional}

  }

