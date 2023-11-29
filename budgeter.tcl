# Main gui
set setup_margin 0.020
set hold_margin  0.020
proc budgeter {args} {
    global setup_margin
    global hold_margin
    global BDB
    # Bulding BDB dict
    if {[info exists BDB]} {unset BDB}
    parse_proc_arguments -args $args results

    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }
    if {[info exists i_mrt_setup_file_path]} {
        puts "Info:: Input file  $i_mrt_setup_file_path"
        collect_mrt_file_data $i_mrt_setup_file_path
    }
    if {[info exists i_mrt_hold_file_path]} {
        puts "Info:: Input file  $i_mrt_hold_file_path"
        collect_mrt_file_data $i_mrt_hold_file_path
    }
    2d_dict_print $BDB
    # Start working on paths
    add_partition_level_data_to_BDB
    # Print results from infile
    2d_dict_print $BDB
    if {[info exists i_print_budget] && [info exists i_mrt_hold_file_path]} { 
        print_remove_budget_file
        print_group_paths
        print_budget_file hold
    }

    if {[info exists i_print_budget] && [info exists i_mrt_setup_file_path]} { 
        # print_remove_budget_file
        # print_group_paths
        print_budget_file setup
    }


    return 1
}

# Take data from fc run.
proc collect_mrt_file_data {args} {
    global BDB
    parse_proc_arguments -args $args results
    set IF [open $results(file_in) r]
    set id 0
    while { [gets $IF line] >= 0 } {
        set no_clock "Flase"
        if {[regexp {^[ ]*$} $line]} {continue}
        if {[regexp { NC   } $line]} {continue}
        set lline [split [join $line " "] " "]
        set port      [lindex $lline 0]
        set slack     [lindex $lline 1]
        set check     [lindex $lline 4]
        if {$check ne "min" && $check ne "max" } {set no_clock "True"}
        if {$no_clock eq "True"} {
            set clock     "NONE"
            set direction [lindex $lline 2]
            set check     [lindex $lline 3]
            set run_type  [lindex $lline 4]
            set temp_worst_ep  [lindex $lline 5]
        } else {
            set clock     [lindex $lline 2]
            set direction [lindex $lline 3]
            set check     [lindex $lline 4]
            set run_type  [lindex $lline 5]
            set temp_worst_ep  [lindex $lline 6]
        }

        #XXXXXXX#
        if {$clock eq "runt_clk3_div6"} {set clock "pi_refclk"}

        regsub {dss\d\/} $temp_worst_ep {} worst_ep ;# set partition level pin
        set ient [dict create slack $slack clock $clock run_type $run_type worst_ep $worst_ep]
        set ent  [dict create port $port  direction $direction $check $ient]
        dict set BDB $id $ent
        incr id 
    }



    close $IF
    return 1
}

# Set budget file.
proc add_partition_level_data_to_BDB { } {
    global BDB
    set keys [dict keys $BDB]
    foreach key $keys {
        echo "$key ============================++====="
        set CMD "get_timing_path "
        set sidict    [dict get $BDB $key]
        set port      [dict get $sidict "port"     ]
        puts "$$$$$ $port"
        set direction [dict get $sidict "direction"]
        if {[dict exists $sidict "min"]} {set check "min" } else {set check "max"}
        set sisidict  [dict get $sidict $check]
        set slack     [dict get $sisidict "slack"    ]
        if {$slack eq "inf"} {
            dict set BDB $key $check uncertainty "NONE"
            dict set BDB $key $check clock_path  "NONE"
            dict set BDB $key $check data_path   "NONE"
            dict set BDB $key $check shold_time  "NONE"
            dict set BDB $key $check period      "NONE"
            continue
        }
        set worst_ep  [dict get $sisidict "worst_ep" ]
        set clock_nm  [dict get $sisidict "clock" ]
        append CMD " -delay_type $check "
        if {[get_pins $worst_ep -q] ne ""} {
            if {$direction eq "in"} {
                append CMD " -from \[get_ports $port\] -to   \[get_pins $worst_ep\]"
            } else {
                append CMD " -to   \[get_ports $port\] -from \[get_pins $worst_ep\]"
            }
        } else {
            if {$direction eq "in"} {
                append CMD " -from \[get_ports $port\] "
            } else {
                append CMD " -to   \[get_ports $port\] "
            }
        }
        puts $CMD
        set tp         [eval $CMD]

        set fdata_path  [get_attr $tp arrival                     ]
        set budget      [get_attr $tp startpoint_input_delay_value]
        set data_path   [expr $fdata_path - $budget               ]        


        set uncertainty [get_attr $tp clock_uncertainty           ]
        if {$uncertainty == 0.0 ||$uncertainty == ""} {
            puts "for port $key defulte uncertainty time will be added 0.05"
            set uncertainty 0.05

        }
        set period      [get_attr $tp endpoint_clock.period       ]
        if {$period eq ""} {set period 0}   
        set clock_path  [get_attr $tp endpoint_clock_latency      ]
        if {$check eq "min"} {
            set shold_time   [get_attr $tp endpoint_hold_time_value    ]
        } else {
            set shold_time   [get_attr $tp endpoint_setup_time_value   ]
        }
        if {$shold_time eq ""} {
            puts "for port $key defulte shold time will be added 0.045"
            set shold_time 0.045
        }
        if {$clock_path eq ""} {
            puts "for port $key defulte shold time will be added 0.045"
            set clock_path 0.250
        }
       
        echo "CLOCK:        $clock_nm"
        echo "UNCERT:       $uncertainty"
        echo "PERIOD:       $period"
        echo "CLOCK PATH:   $clock_path"
        echo "DATA:         $data_path"
        echo "SHOLD TIME:   $shold_time"
        echo "NEEDED SLACK: $slack"
        dict set BDB $key $check uncertainty $uncertainty
        dict set BDB $key $check clock_path  $clock_path
        dict set BDB $key $check data_path   $data_path
        dict set BDB $key $check shold_time  $shold_time
        dict set BDB $key $check period      $period
       
    }



    return 1
}

proc print_budget_file {chk} {
    global BDB;
    global hold_margin;
    global setup_margin
    if {$chk eq "hold"} {
        set OFM [open /proj/odysseya0/extvols/wa_003/lioral/budget_files/FC/set_budget_file_min.tcl  w]
    }
    if {$chk eq "setup"} {
        set OF  [open /proj/odysseya0/extvols/wa_003/lioral/budget_files/FC/set_budget_file_max.tcl  w]
    }
    set keys [dict keys $BDB]
    foreach key $keys {
        set port        [dict get $BDB $key "port"           ]
        puts "PORT $port"
        set direction   [dict get $BDB $key "direction"      ]
        if {[dict exists $BDB $key "min"]} {set check "min" } else {set check "max"}
        set uncertainty [dict get $BDB $key $check uncertainty]
        set clock_path  [dict get $BDB $key $check clock_path ]
        set clock       [dict get $BDB $key $check clock      ]
        set data_path   [dict get $BDB $key $check data_path  ]
        set shold_time  [dict get $BDB $key $check shold_time ]
        set slack       [dict get $BDB $key $check slack      ]
        set period      [dict get $BDB $key $check period     ]
        if {$direction eq "in"  && $check eq "min"} {
            # {} mean neg value
            # slack = ${uncertainty} + ${shold_time} + $data_path - $input_delay - $clock_path
            if {$slack eq "inf"} {
                set input_delay 100
                set clock       vclk
            } else {
                puts "key         :: $key"
                puts "uncertainty :: $uncertainty"
                puts "shold_time  :: $shold_time"
                puts "data_path   :: $data_path"
                puts "slack       :: $slack"
                puts "clock_path  :: $clock_path"
                puts "port        :: $port"
                if {$slack > 0} {set ihold_margin 0} else {set ihold_margin $hold_margin}
                set input_delay [expr  $uncertainty + $shold_time - $data_path -$ihold_margin + ${slack} + $clock_path]
            }
            puts $OFM "set_input_delay $input_delay  -clock \[get_clocks $clock \] -min -add_delay \[get_ports $port\];# $slack :: input_delay = ${uncertainty}(uncent) + ${shold_time}(shold) - ${data_path}(data path) + ${slack}(slack) + ${clock_path}(clock path) - ${hold_margin}(hold margin)"
        }
        if {$direction eq "in"  && $check eq "max"} {
            puts "MAX RUN: $key"
            # {} mean neg value
            # slack = ${uncertainty} + ${shold_time} - $data_path - $input_delay + $clock_path
            if {$slack eq "inf"} {
                set input_delay 100
                set clock       vclk
            } else {
                puts "key         :: $key"
                puts "uncertainty :: $uncertainty"
                puts "shold_time  :: $shold_time"
                puts "data_path   :: $data_path"
                puts "slack       :: $slack"
                puts "clock_path  :: $clock_path"
                puts "port        :: $port"
                puts "period      :: $period"
                if {$slack > 0} {set isetup_margin 0} else {set isetup_margin $setup_margin}
                #set input_delay [expr  0 - ${uncertainty} - ${shold_time} - $data_path - $slack + $clock_path + $setup_margin]
                set input_delay [expr  0 + ${uncertainty} - $shold_time - $data_path - $slack + $clock_path + $period + $isetup_margin]
            }
            puts $OF  "set_input_delay $input_delay  -clock \[get_clocks $clock \] -max -add_delay \[get_ports $port\] ;# $slack :: input_delay = + ${uncertainty}(uncent) - ${shold_time}(shold) - ${data_path}(data path) - ${slack}(slack) + ${clock_path}(clock path) +${period}(period) + ${setup_margin}(setup margin)"
        }
        if {$direction eq "out" && $check eq "min"} {

        }
        if {$direction eq "out" && $check eq "max"} {

        }
    }


if {[info exists OFM]} {close $OFM}
if {[info exists OF ]} {close $OF}
}

# Set all start end to a group.
proc print_group_paths {args} {
    global BDB
    parse_proc_arguments -args $args results
    set rebudget_inputs  {}
    set rebudget_outputs {}
    set OF [open /proj/odysseya0/extvols/wa_003/lioral/budget_files/FC/set_group_paths.tcl  w]
    set keys [dict keys $BDB]
    foreach key $keys {
        set port      [dict get $BDB $key "port"     ]
        set direction [dict get $BDB $key "direction"]
        if {[dict exists $BDB $key "min"]} {
            set clock  [dict get $BDB $key min clock]
        } else {
            set clock  [dict get $BDB $key max clock]
        }
        if {$direction eq "in"} {
            lappend TMP(RBGT_${clock}_INPUT) $port
        } else {
            lappend TMP(RBGT_${clock}_OUTPUT) $port
        }
    }
    foreach key [array names TMP] {
        if {[regexp {OUTPUT} $key]} {continue}
        puts $OF "remove_path_group INPUT"
#puts $OF "group_path -name INPUT  -from \[remove_from_collection \[all_inputs \] \[get_ports \{$rebudget_inputs\}\]\]"
        puts $OF "group_path -name $key -from \[get_ports \{$TMP($key)\}\]"
    }
#    if {$rebudget_outputs ne ""} {
#        if {[regexp {INPUT} $key]} {continue}
#        puts $OF "remove_path_group OUTPUT"
#puts $OF "group_path -name OUTPUT -to \[remove_from_collection \[all_outputs \] \[get_ports \{$rebudget_outputs\}\]\]"
#        puts $OF "group_path -name RBGT_${clock}_OUTPUT -to \[get_ports \{$rebudget_outputs\}\]"
#    }
    close $OF
    return 1
}

proc print_remove_budget_file {} {
    global BDB
    set OF [open /proj/odysseya0/extvols/wa_003/lioral/budget_files/FC/remove_io_delay.tcl  w+]
    set keys [dict keys $BDB]
    foreach key $keys {
        set sidict    [dict get $BDB $key          ]
        set port      [dict get $sidict "port"     ]
        set direction [dict get $sidict "direction"]
        if {$direction eq "in"} {set txt "in"} else {set txt "out"}
         puts $OF "remove_${txt}put_delay \[get_ports $port\] -max"
         puts $OF "remove_${txt}put_delay \[get_ports $port\] -min"
    }
    close $OF
    return 1
}


proc 2d_dict_print {idict} {
    set keys [dict keys $idict]
    foreach key $keys {
        set sidict [dict get $idict $key]
        puts "No. $key => "
        set skeys [dict keys $sidict]
        foreach skey $skeys {
            set val [dict get $sidict $skey]
            if {$skey eq "min"||$skey eq "max"} {
                puts "\t[format %-*s 10 $skey] => "
                set siidict [dict get $sidict $skey]
                set sskeys [dict keys $siidict]
                foreach sskey $sskeys {
                    set val [dict get $siidict $sskey]
                    puts "\t\t      [format %-*s 10 $sskey] => $val"                
                }
            } else {
                puts "\t[format %-*s 10 $skey] => $val"
            }
        }
    }
   
    return ""
}


define_proc_attributes budgeter \
    -info "Set budget on partition level from FC results" \
    -define_args { \
        {-mrt_setup_file_path   "mrt_file_path"                              "get the file that mrt output as input for a run" string optional}
        {-mrt_hold_file_path    "mrt_file_path"                              "get the file that mrt output as input for a run" string optional}
        {-clock_ovrd            "clock to be used for all delays"            "clock to be used for all delays, if not def we will take the mrt one" string optional}
        {-print_budget          "print budget file"                          ""                              boolean optional}
    }

define_proc_attributes collect_mrt_file_data \
    -info "Set budget on partition level from FC results" \
    -define_args { \
         {file_in   "mrt_file_path"                              "get the file that mrt output as input for a run" string optional}
    }

#define_proc_attributes set_partition_budget \
#    -info "Set budget on partition level from FC results" \
#    -define_args { \
#    }

define_proc_attributes print_group_paths \
    -info "Set budget on partition level from FC results" \
    -define_args { \
    }
