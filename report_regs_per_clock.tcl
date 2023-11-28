


# Example: report_regs_per_clock                                     #
#====================================================================#


proc report_regs_per_clock {} {
    set clocks [lsort -u [get_object_name [get_clocks *]]]
    set reg_sum "0"
    set zeros   ""
    set all_regs [all_registers]
    set none_clock_regs $all_regs
    foreach clk $clocks {
        set size "0"
        set all_regs_clock [all_registers -clock $clk]
        set size [sizeof_collection $all_regs_clock]
        if {$size == 0} { 
            lappend zeros [format "%-40s %-13s" "$clk"   "$size"]
        } else {
            echo [format "%-40s %-13s" "$clk"   "$size"]
            set none_clock_regs [remove_from_collection $none_clock_regs $all_regs_clock]
            #puts "none clock reg updated to [sizeof_collection $none_clock_regs]"
        }
        #set reg_sum [expr {$reg_sum + $size}]
    }
    foreach zero $zeros {
        echo "$zero"
    }
    puts ""
    set reg_sum [sizeof_collection $all_regs       ]
    set non_sum [sizeof_collection $none_clock_regs]
    puts "Total number of FF in the design is:  $reg_sum"
    puts "Number of registers with no clock is: $non_sum"
#foreach_in_collection  no $none_clock_regs {
#        puts "[get_object_name $no]"
#    }
    return ""
}

