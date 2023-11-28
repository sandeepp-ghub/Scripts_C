#===================Util Procs=================================#


#===================Collect ports==============================#
set all_outputs [all_outputs]
set all_inputs  [get_ports -filter "direction==in" ]
set all_io      [get_ports -filter "direction==io" -q ]
set all_clks    [get_clocks                        ]      
set all_inputs_but_clocks [remove_from_collection $all_inputs [get_property [get_clocks] sources -q]] 
set all_clocks_sources [get_property [get_clocks] sources -q]

set analysis_views [get_db [get_db analysis_views -if ".is_active==true&&.name==*setup*"] .name] ;# setup as budget is only for setup mode. hold for io is FP. also invv mode is setup so report timing wont work.


#===================IN=========================================#
foreach_in_collection input $all_inputs_but_clocks {
    set input_name [get_object_name $input]
    puts "Info-Budget: Input port name:: $input_name"
    dict set BDB $input_name {}
    dict set BDB $input_name "direction"     "in"
    dict set BDB $input_name "analysis_views" {}
    foreach analysis_view $analysis_views {
        dict set BDB $input_name "analysis_views" $analysis_view {}
        set fanout [all_fanout -from $input -endpoints_only -view $analysis_view]
        if {$fanout eq ""} {
            puts "Info-Budget: Input:: $input_name is not connected or blocked by case value"
            continue
        }
        set fo_pins [get_object_name [filter_collection $fanout "object_class==pin"]]
        if {$fo_pins eq ""} {
            puts "Info-Budget fanout include only ports this is a FT port"
            continue
        }
        # Trim fanout.
        if {[sizeof_collection $fo_pins] > 100 } {
            set fo_pins [range_collection $fo_pins 0 99]
        }
        # Get the right clock/s for the port.
        set fo_ff  [get_cells -of $fo_pins    ]
        set fo_ckp [get_pins -of $fo_ff -filter "name=~*clocked_on*||name=~*CK*||name=~*CLK*||name=~*CP*" -q]
        set fo_ck  [get_property $fo_ckp clocks -view $analysis_view -q]
        set fo_ckn [lsort -unique [get_object_name $fo_ck    ] ]
        puts "Info-Budget for port $input_name and view $analysis_view we get the next clocks $fo_ckn"
        foreach clk $fo_ckn {
            dict set BDB $input_name "analysis_views" $analysis_view $clk {}
            dict set BDB $input_name "analysis_views" $analysis_view $clk "slack" "N/A"
            dict set BDB $input_name "analysis_views" $analysis_view $clk "budget" "N/A"
            set rt [report_timing -from $input_name -to $clk -collection -view $analysis_view]
            set slack  [get_property $rt slack]
            set budget [get_property $rt launching_input_delay]
            dict set BDB $input_name "analysis_views" $analysis_view $clk "slack" $slack
            dict set BDB $input_name "analysis_views" $analysis_view $clk "budget" $budget

        }
    }
}

#===================OUT=========================================#
foreach_in_collection output $all_outputs {
    set output_name [get_object_name $output]
    puts "Info-Budget: Output port name:: $output_name"
    dict set BDB $output_name {}
    dict set BDB $output_name "direction"     "out"
    dict set BDB $output_name "analysis_views" {}
    foreach analysis_view $analysis_views {
        dict set BDB $output_name "analysis_views" $analysis_view {}
        set fanin [all_fanin -to $output -startpoints_only -view $analysis_view]
        if {$fanin eq ""} {
            puts "Info-Budget: Output:: $output_name is not connected or blocked by case value"
            continue
        }
        set fi_pins [get_object_name [filter_collection $fanin "object_class==pin"]]
        if {$fi_pins eq ""} {
            puts "Info-Budget fanin include only ports this is a FT port"
            set fi_ckn [lsort -unique [get_object_name [get_property $fanin arrival_clocks -view $analysis_view]]]
            foreach clk $fi_ckn {
                dict set BDB $output_name "analysis_views" $analysis_view $clk {}
                dict set BDB $output_name "analysis_views" $analysis_view $clk "slack" "N/A"
                dict set BDB $output_name "analysis_views" $analysis_view $clk "budget" "N/A"
                
                set rt [report_timing -to $output_name -from $clk -collection -view $analysis_view]
                set slack  [get_property $rt slack]
                set budget [get_property $rt external_delay]
                dict set BDB $output_name "analysis_views" $analysis_view $clk "slack" $slack
                dict set BDB $output_name "analysis_views" $analysis_view $clk "budget" $budget
            }
            continue
        }
        # Trim fanout.
        if {[sizeof_collection $fi_pins] > 100 } {
            set fo_pins [range_collection $fi_pins 0 99]
        }
        # Get the right clock/s for the port.
        set fi_ff  [get_cells -of $fi_pins    ]
        set fi_ckp [get_pins -of $fi_ff -filter "name=~*clocked_on*||name=~*CK*||name=~*CLK*||name=~*CP*" -q]
        set fi_ck  [get_property $fi_ckp clocks -view $analysis_view -q]
        set fi_ckn [lsort -unique [get_object_name $fi_ck    ] ]
        puts "Info-Budget for port $output_name and view $analysis_view we get the next clocks $fi_ckn"
        foreach clk $fi_ckn {
            dict set BDB $output_name "analysis_views" $analysis_view $clk {}
            dict set BDB $output_name "analysis_views" $analysis_view $clk "slack" "N/A"
            dict set BDB $output_name "analysis_views" $analysis_view $clk "budget" "N/A"
            set rt [report_timing -to $output_name -from $clk -collection -view $analysis_view]
            set slack  [get_property $rt slack]
            set budget [get_property $rt external_delay]
            dict set BDB $output_name "analysis_views" $analysis_view $clk "slack" $slack
            dict set BDB $output_name "analysis_views" $analysis_view $clk "budget" $budget

        }
    }
}



#===================Print for debug==========================#
set OF [open /user/lioral/set_current_budget_wns_to_zero.log w]
foreach port [dict keys $BDB] {
    puts $OF $port
    puts $OF "Direction:       [dict get $BDB $port direction]"
    puts $OF "analysis_views:" 
    foreach analysis_view [dict keys [dict get $BDB $port "analysis_views"]] {
        puts $OF "\t\t $analysis_view"
        puts $OF "\t\t Clocks:"
        foreach clk [dict keys [dict get $BDB $port "analysis_views" $analysis_view]] {
            puts $OF "\t\t\t $clk"
            puts $OF "\t\t\t\t  slack: [dict get $BDB $port analysis_views $analysis_view $clk slack]"
            puts $OF "\t\t\t\t budget: [dict get $BDB $port analysis_views $analysis_view $clk budget]"
        }
    }
}

close $OF

#===================Print Budget Files======================#
if {[info exists TARGET_SLACK]} {
    puts "target slack is set to :: $TARGET_SLACK"
} else {
    puts "target slack is set to :: 0"
    set TARGET_SLACK 0
}
if {[info exists OFDB]} {unset OFDB}
foreach port [dict keys $BDB] {
    foreach analysis_view [dict keys [dict get $BDB $port analysis_views]] {
        # Bug fix reset port but if clk if > 1 we kill the first budget
        set clk_no 0
        foreach clk [dict keys [dict get $BDB $port analysis_views $analysis_view]] {
            incr clk_no
            # check if output file scenario exists.
            if {![info exists OFDB($analysis_view)]} {
                set  OFDB($analysis_view) [open ./rebudget__${analysis_view}.sdc w] 
            }
            # Write to file.
            
            set direction      [dict get $BDB $port direction]
            set slack          [dict get $BDB $port analysis_views $analysis_view $clk slack]  
            set current_budget [dict get $BDB $port analysis_views $analysis_view $clk budget]
            puts "DBG-INFO:: port           == $port"
            puts "DBG-INFO:: slack          == $slack"
            puts "DBG-INFO:: current_budget == $current_budget"
            puts "DBG-INFO:: analysis_view  == $analysis_view"

            if {[info exists WORK_ON_POS_PATHS]} {
            } else {
                set WORK_ON_POS_PATHS 0
            }
            if {$slack >=0 && $WORK_ON_POS_PATHS eq 0} {
                # Dont rebudget pos values.
                continue
            }

            if {$slack eq "" || $slack eq "N/A"} {
                puts "DBG-INFO:: Port $port have a clock related to him but no slack. prob a false path."
                puts $OFDB($analysis_view) "# DBG-INFO:: Port $port have a clock related to him but no slack. prob a false path."
                continue
            }


            if {1} {
            # if more then one clk only the first line get reset
                if {$direction eq "out"} {
                    puts $OFDB($analysis_view) "reset_output_delay $port "
                } else {
                    puts $OFDB($analysis_view) "reset_input_delay $port "
                }
            }



            set POS_PATHS_EXTRA_MARGIN 0
            if {$slack >=0 && $WORK_ON_POS_PATHS eq 1 && [info exists POS_PATHS_EXTRA_MARGIN]} {
                set INT_POS_PATHS_EXTRA_MARGIN $POS_PATHS_EXTRA_MARGIN       
            } else {
                set INT_POS_PATHS_EXTRA_MARGIN 0
            }
            set updated_budget [expr $current_budget + $slack - $TARGET_SLACK - $INT_POS_PATHS_EXTRA_MARGIN] ;# slack is neg
            puts $OFDB($analysis_view) "set_${direction}put_delay $updated_budget -max  -clock $clk -add_delay \[get_ports $port\] ;# $current_budget (cur budget) + $slack (slack)  = $updated_budget (updated_budget) "
            
            
        }
    }
}

foreach OF [array names OFDB]  {
    close $OFDB($OF)
}


#===================Print Budget master Files===============#
set  OF [open ./rebudget__main.sdc w]
puts $OF ""
puts $OF "#---------------------------------------------#"
puts $OF "# Set current budget wns to zero main script  #"
puts $OF "#---------------------------------------------#"
puts $OF ""

puts $OF "set script_path \[ file dirname \[ file normalize \[ info script \] \] \]"
puts $OF "puts \$script_path"
puts $OF ""
foreach analysis_view [array names OFDB] {
    puts $OF "#Info:: analysis_view   $analysis_view"
    set constraint_mode_names [get_db [get_db analysis_views $analysis_view] .constraint_mode.name]
    foreach constraint_mode_name $constraint_mode_names {
        puts $OF "#Info:: constraint_mode $constraint_mode_name"
        puts $OF "set_interactive_constraint_modes \[get_db constraint_modes  $constraint_mode_name\]"
        puts $OF "source -e -v \$\{script_path\}/rebudget__${analysis_view}.sdc"
        puts $OF "set_interactive_constraint_modes \"\""
        puts $OF "#--"
    }
}
close $OF


puts "================================================================================="
source -e -v ./rebudget__main.sdc

