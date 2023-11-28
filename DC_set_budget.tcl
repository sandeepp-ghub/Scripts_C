proc set_budget {args} {
    global env
    set mode ""
    uplevel 1 {set budget_mode   [mExtractFromScenario $scenario mode]; puts "budget_mode :: $budget_mode & scenario :: $scenario "}
    upvar 1 budget_mode budget_mode_internal
    puts "LIORAL-DEBUG:: budget running at mode $budget_mode_internal"
#============================================#
# Set a budget on a block ports at dc stage  #
#============================================#
puts "LIORALL-Info:: Creating ./${budget_mode_internal}_auto_budget.sdc..."
#===================Util proc==================================#
proc get_overide_pr {u_name clk IOEXP} {
    if {[dict exists $IOEXP DLY]} {
        foreach exp_name [dict keys [dict get $IOEXP DLY]] {
            puts "dbg:: $exp_name"
            if {[regexp {(.+?)(\[)} $exp_name -> base index]} {
                set exp_u_name $base
    
            } else {
                set exp_u_name $exp_name
            }
    
            if {[string match $exp_u_name $u_name] && [lindex [dict get $IOEXP DLY $exp_name] 1] eq $clk} {
                puts "Info proc get_overide_pr port name match a user overide ${exp_name}\(exp\) ==> ${u_name}\(port\)"
                return [dict get $IOEXP DLY $exp_name]
            }
        }
    }
    return 0
}
 

#===================Collect ports==============================#
set all_outputs [get_ports -filter "direction==out"]
set all_inputs  [get_ports -filter "direction==in" ]
set all_io      [get_ports -filter "direction==io" ]
set all_clks    [get_clocks                        ]      
set all_inputs_but_clocks [remove_from_collection $all_inputs [get_attr [get_clocks] sources -q]] 
set all_clocks_sources [get_attr [get_clocks] sources -q]
#===================Read input file============================#
set ifile $env(PWD)/../config/params.tcl
set IF   [open $ifile r]
while { [gets $IF line] >= 0 } {
    #set line       [join $line " "]
    #set port       [lindex $line 0]
    if {[regexp {dict set IOEXP} $line]} {
        puts "$line"
        eval $line
    }

}
close $IF

#===================Pre-set====================================#
# get all clocks DC.
dict set BDB "clocks"  {}
dict set BDB "inputs"  {}
dict set BDB "outputs" {}
dict set BDB "ftp"     {} ;#FT pair

set dflt_budget 0.5
if {[info exists IOEXP]} {
    if {[dict exists $IOEXP BUD "ALL"]} {
        set dflt_budget [dict get $IOEXP BUD "ALL"]
    }
}

foreach_in_collection clk $all_clks {
    set cn     [get_object_name $clk]
    set period [get_attr $clk period]
    dict set BDB clocks $cn {}
    dict set BDB clocks $cn period $period
    dict set BDB clocks $cn budget $dflt_budget
    if {[info exists IOEXP]} {
        if {[dict exists $IOEXP BUD $cn]} {
            dict set BDB clocks $cn budget [dict get $IOEXP BUD $cn]
        }
    }
}

#===================IN=========================================#

foreach_in_collection input $all_inputs_but_clocks {
    set input_name [get_object_name $input]
    puts "Info-Budget: Input port name:: $input_name"
    set fanout [all_fanout -from $input -endpoints_only -flat]
    # Filter inputs with no fanout
    if {$fanout eq ""} {
        puts "Info-Budget: Input:: $input_name is not connected or blocked by case value"
        continue
    }
    # filter inputs that are FT ports
    set fo_pins [filter_collection $fanout "object_class==pin"]
    if {$fo_pins eq ""} {
        puts "Info-Budget fanout include only ports this is a FT port"
        continue
    }
    # Trim fanout.
    if {[sizeof_collection $fo_pins] > 100 } {
        set fo_pins [index_collection $fo_pins 0 99]
    }
    # Get the right clock/s for the port.
    set fo_ff  [get_cells -of $fo_pins    ]
    set fo_ckp [get_pins -of $fo_ff -filter "name=~*clocked_on*||name=~*CK*||name=~*CP*"]
    set fo_ck  [get_attr $fo_ckp clocks -q]
    set fo_ckn [lsort -unique [get_object_name $fo_ck    ] ]
    puts "Info-Budget $fo_ckn"
    if {[regexp {(.+?)(\[)} $input_name -> base index]} {
        set input_u_name $base

    } else {
        set input_u_name $input_name
    }
    if {[dict exists $BDB inputs $input_u_name]} {
        puts [dict get $BDB "inputs" $input_u_name "ports"]
        dict set BDB "inputs" $input_u_name "ports" [concat [dict get $BDB "inputs" $input_u_name "ports"] $input_name]
        dict set BDB "inputs" $input_u_name "clocks" [lsort -unique [concat [dict get $BDB "inputs" $input_u_name "clocks"] $fo_ckn]]
    } else {
        dict set BDB "inputs" $input_u_name {}
        dict set BDB "inputs" $input_u_name "ports"  $input_name
        dict set BDB "inputs" $input_u_name "clocks" $fo_ckn
    }
}

#===================OUT=========================================#
foreach_in_collection output $all_outputs {
    set output_name [get_object_name $output]
    puts "Info-Budget: Output port name:: $output_name"
    set fanin [all_fanin -to $output -startpoints_only -flat]
    # Filter outputs with no fanout
    if {$fanin eq ""} {
        puts "Info-Budget: Output:: $output_name is not connected or blocked by case value"
        continue
    }
    # filter outputs that are FT ports
    set fi_pins [filter_collection $fanin "object_class==pin"]
    if {$fi_pins eq ""} {
        puts "Info-Budget fanin include only ports this is a FT port"
        set fanin [remove_from_collection $fanin $all_clocks_sources]
        if {$fanin eq ""} {
            continue
        }
        dict set BDB "ftp" $output_name [get_object_name $fanin]
        continue
    }
    # Trim fanout.
    if {[sizeof_collection $fi_pins] > 100 } {
        set fi_pins [index_collection $fi_pins 0 99]
    }
    # Get the right clock/s for the port.
    set fi_ff  [get_cells -of $fi_pins    ]
    set fi_ckp [get_pins -of $fi_ff -filter "name=~*clocked_on*||name=~*CK*||name=~*CP*"]
    set fi_ck  [get_attr $fi_ckp clocks -q]
    set fi_ckn [lsort -unique [get_object_name $fi_ck    ] ]
    puts "Info-Budget $fi_ckn"
    if {[regexp {(.+?)(\[)} $output_name -> base index]} {
        set output_u_name $base

    } else {
        set output_u_name $output_name
    }
    if {[dict exists $BDB outputs $output_u_name]} {
        puts [dict get $BDB "outputs" $output_u_name "ports"]
        dict set BDB "outputs" $output_u_name "ports" [concat [dict get $BDB "outputs" $output_u_name "ports"] $output_name]
        dict set BDB "outputs" $output_u_name "clocks" [lsort -unique [concat [dict get $BDB "outputs" $output_u_name "clocks"] $fi_ckn]]
    } else {
        dict set BDB "outputs" $output_u_name {}
        dict set BDB "outputs" $output_u_name "ports"  $output_name
        dict set BDB "outputs" $output_u_name "clocks" $fi_ckn
    }
}

#===================If re-budget moved to sep scr================#
#if { $argc != 1 || $argc != 0 } { 
#    puts "ERROR:: The only arg this scripts get is -rebudget when the user (you) like to set budget to give zero slack at current stage .."
#} elseif {$argc == 1 && [lindex $argv 0] eq "-rebudget"} {
#    puts "Info:: going to zero up the budget slack."
#    return 0
#}
#===================Print Budget file============================#
set OF   [open ./${budget_mode_internal}_auto_budget.sdc w]
puts $OF "# Auto budget file ..."
puts $OF "#==============Remove any existing io delay================#"
puts $OF "remove_input_delay  \[all_inputs \]"
puts $OF "remove_output_delay \[all_outputs\]"
puts $OF ""

puts $OF "#==============Hold  FP================#"
puts $OF "set_false_path -hold -to    \[all_outputs\]"
puts $OF "set_false_path -hold -from  \[remove_from_collection \[all_inputs\] \[get_ports -q \[get_attribute \[get_clocks *\] sources -q\]\]\]"
puts $OF ""
puts $OF "#==============FT budget===============#"
if {[llength [dict get $BDB ftp]] > 0} {
    puts $OF "# creating a V clock to max delay to the FT paths."
    puts $OF "if \{\[get_clocks VFT_clock -q\] eq \"\"\} \{"
    puts $OF "     create_clock -period 1 -name VFT_clock"
    puts $OF "\}"
    foreach out [dict keys [dict get $BDB ftp]] {
        # fix only for dmc FT clock paths.
        if {[regexp {dch__phy_ft_out\[233\]} $out]} {continue}
        if {[regexp {dch__phy_ft_out\[257\]} $out]} {continue}
        if {[regexp {dch__phy_ft_out\[239\]} $out]} {continue}
        # end of fix
        puts $OF "set_output_delay 0 -max -clock VFT_clock -add_delay  \[get_ports $out\]"
        foreach in [dict get $BDB ftp $out] {
            puts $OF "set_input_delay 0 -max -clock VFT_clock -add_delay \[get_ports $in\]"
            puts $OF "set_max_delay 0.65  -from \[get_ports $in\] -to \[get_ports $out\]"
            puts $OF "#\-\-"
        }
    }


} else {
    puts $OF "# No FT ports exists ..."
}
puts $OF " "
puts $OF "#==============Inputs==================#"
foreach input_u_name [lsort [dict keys [dict get $BDB "inputs"]]] {
    puts "DBG:: $input_u_name"
    # see if bus or not.
    if {[llength [dict get $BDB "inputs" $input_u_name "ports"]] > 1} {
        set in "${input_u_name}\[\*\]"
    } else {
        set in $input_u_name
    }
#foreach in [dict get $BDB "inputs" $input_u_name "ports"] {}
    foreach cn [dict get $BDB "inputs" $input_u_name "clocks"] {
        set per [dict get $BDB clocks $cn period]   
        set bud [dict get $BDB clocks $cn budget]
        if {[info exists IOEXP]} {
            set bud_over [get_overide_pr $input_u_name $cn $IOEXP]
            if {$bud_over ne "0"} {
                set bud [lindex $bud_over 0]
            }
        }
        set pr  [expr $per * $bud]
        
        puts $OF "set_input_delay $pr -max -clock $cn -add_delay \[get_ports $in\]"
    }
}
puts $OF " "
puts $OF "#==============Outputs=================#"
foreach output_u_name [lsort [dict keys [dict get $BDB "outputs"]]] {
    puts "DBG:: $output_u_name"
    # see if bus or not.
    if {[llength [dict get $BDB "outputs" $output_u_name "ports"]] > 1} {
        set out "${output_u_name}\[\*\]"
    } else {
        set out $output_u_name
    }
#foreach out [dict get $BDB "outputs" $output_u_name "ports"] {}
    foreach cn [dict get $BDB "outputs" $output_u_name "clocks"] {
        set per [dict get $BDB clocks $cn period]   
        set bud [dict get $BDB clocks $cn budget]
        if {[info exists IOEXP]} {
            set bud_over [get_overide_pr $input_u_name $cn $IOEXP]
            if {$bud_over ne "0"} {
                set bud [lindex $bud_over 0]
            }
        }
        set pr  [expr $per * $bud]
        puts $OF "set_output_delay $pr -max -clock $cn -add_delay \[get_ports $out\]"
    }
}
#set fp_str ""
#if {[info exists IOEXP]} {
#    if {[dict exists $IOEXP FP]} {
#        foreach fp  [dict keys [dict get $IOEXP FP]] {
#            set val [dict get $IOEXP FP $fp]
#            if {[llength $val] == 0} {
#                append fp_str "set_false_path -to [lindex $fp 0]\n"   
#            }
#        }
#    }
#
#    puts $OF " "
#    puts $OF "#==============False Paths=================#"
#    puts $OF $fp_str
#    puts $OF " "
#    puts $OF "#==============MC Paths====================#"
#}




#print_bdb
close $OF
#===================UTIL=========================================#

proc print_bdb {} {
    global BDB 
    
    puts "BDB"
    foreach key [dict keys $BDB] {
        puts "\t=> $key"
        if {$key eq "clocks"} {
            foreach ikey [dict keys [dict get $BDB clocks]] {
                puts "\t\t=> $ikey \n\t\t\t=> [dict get $BDB clocks $ikey]"
            }
        }
        continue
        if {$key eq "inputs"} {
            foreach ikey [dict keys [dict get $BDB inputs]] {
                puts "\t\t=> $ikey"
                puts "\t\t\t\t ports(in) =>"
                foreach p [dict get $BDB inputs $ikey ports] {
                    puts "\t\t\t\t\t => $p"
                }
                puts "\t\t\t\t clocks =>"
                foreach c [dict get $BDB inputs $ikey clocks] {
                    puts "\t\t\t\t\t => $c"
                }
            }
        }
        if {$key eq "outputs"} {
            foreach ikey [dict keys [dict get $BDB outputs]] {
                puts "\t\t=> $ikey"
                puts "\t\t\t\t ports(out) =>"
                foreach p [dict get $BDB outputs $ikey ports] {
                    puts "\t\t\t\t\t => $p"
                }
                puts "\t\t\t\t clocks =>"
                foreach c [dict get $BDB outputs $ikey clocks] {
                    puts "\t\t\t\t\t => $c"
                }
            }
        }
        if {$key eq "ftp"} {
            foreach ikey [dict keys [dict get $BDB ftp]] {
                puts "\t\t=> port(out) => $ikey"
                puts "\t\t\t\t ports(in) =>"
                foreach p [dict get $BDB ftp $ikey] {
                    puts "\t\t\t\t\t => $p"
                }
            }
        }

    }
}

proc get_worst_path_stat {} {


}

puts "LIORALL-Info:: sourcing ./${budget_mode_internal}_auto_budget.sdc start..."
source ./${budget_mode_internal}_auto_budget.sdc
puts "LIORALL-Info:: sourcing ./${budget_mode_internal}_auto_budget.sdc end..."
}
