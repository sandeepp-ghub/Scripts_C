
# Description: find unconstraint ports in the design and budget      #
#====================================================================#
# Example: soc_find_unconstraint_ports -budget_unconstraint          #
#====================================================================#


proc soc_find_unconstraint_ports {args} {

    redirect -file soc_find_unconstraint_ports.rpt {puts "" }
    parse_proc_arguments -args ${args} results
    set input_recordes       NO
    set output_recordes      NO
    set clock_ports          ""
    set not_connected_input  ""
    set not_connected_output ""
    set FT_clock_out_port    ""
    set real_input_ports     ""
    set real_output_ports    ""


    redirect -file soc_find_unconstraint_ports_temp_report {report_port -verbose -nosplit } 
    set file_as_list [file_to_list ./soc_find_unconstraint_ports_temp_report]
    foreach line $file_as_list {
        if {[regexp {Input Delay}  $line]} {set input_recordes  YES}
        if {[regexp {Output Delay} $line]} {set output_recordes YES}
        if {$line eq "" }                 {set input_recordes NO; set output_recordes NO}
        set line_list [split [join $line " "] " "]
        if {$input_recordes eq "YES" } {
            if {[lindex $line 5] eq "--"} {
                set inport [lindex $line 0]
                if {[soc_is_clock_port $inport -no_verbose]} { lappend clock_ports $inport; continue}
                if {[afo $inport] eq ""} {lappend not_connected_input $inport; continue }
                lappend  real_input_ports $inport
            }

        }
         if {$output_recordes eq "YES" } {
             if {[lindex $line 5] eq "--"} {
                 set outport [lindex $line 0]
                 if {[afi $outport] eq ""} {
                     lappend not_connected_output $outport; continue 
                 } else {
                    set cont 0
                    foreach_in_collection fi [afi $outport] {
                        if {[soc_is_clock_port $fi]} {
                            lappend FT_clock_out_port $outport; set cont 1; continue;
                        }
                    }
                    if {$cont eq "1"} {continue }
                 }

                lappend  real_output_ports $outport
            }
        }



    }
    redirect -file soc_find_unconstraint_ports.rpt -append {
        puts "INPUT CLOCK PORTS"
        puts "================="
        pl   "$clock_ports"
        puts ""
        puts "NOT CONNECTED INPUT"
        puts "==================="
        pl   "$not_connected_input"
        puts ""
        puts "NOT CONNECTED OUTPUT"
        puts "===================="
        pl   "$not_connected_output"
        puts ""
        puts "FT CLOCK OUT PORT"
        puts "================="
        pl "$FT_clock_out_port"
        puts ""
        puts "UNCONSTRAINT INPUT PORTS"
        puts "========================"
        pl "$real_input_ports"   
        puts ""
        puts "UNCONSTRAINT OUTPUT PORTS"
        puts "========================="
        pl "$real_output_ports"    
    } 
    sh rm ./soc_find_unconstraint_ports_temp_report
    #-- at this point we have all the unconstraint ports this is the time to print a constraint file
    #-- start with inputs
    if {[info exists results(-budget_unconstraint)]} {
         set fileId [open ./soc_find_unconstraint_ports_budget_file.tcl "w"]
       
            puts $fileId "\# input delay"
            foreach p $real_input_ports {
                foreach c [soc_find_possible_clocks $p] {
                    set per   [get_attr [get_clocks $c] period]
                    set perd3 [expr {$per * 0.65}]
                    puts $fileId "set_input_delay ${perd3} -clock \[get_clocks $c\] \[get_ports $p\] -add"
                }
            }
            #-- output delay
            puts $fileId "\# output delay"
            foreach p $real_output_ports {
                foreach c [soc_find_possible_clocks $p] {
                    set per   [get_attr [get_clocks $c] period]
                    set perd3 [expr {$per * 0.65}]
                    puts $fileId "set_output_delay ${perd3} -clock \[get_clocks $c\] \[get_ports $p\] -add"
                }
            }
         close $fileId 
    };#end if
    return ""
}


define_proc_attributes soc_find_unconstraint_ports \
    -info "report unconstraint port -help" \
    -define_args {
        
{-budget_unconstraint  "output a budget tcl file for the unconstraint ports"    "" boolean optional}
}

