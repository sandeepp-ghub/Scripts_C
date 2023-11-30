
# Description: report_regs_per_clock in a table format               #
#====================================================================#
# Example: report_regs_per_clock                                     #
#====================================================================#


proc report_regs_per_clock {} {
    set clocks [get_clocks *]
    set reg_sum "0"
    foreach_in_collection clk $clocks {
        set size "0"
        set size [sizeof_collection [all_registers -clock $clk]]
        echo [format "%-40s %-13s" "[get_object_name $clk]"   "$size"]
        set reg_sum [expr {$reg_sum + $size}]
    }
    puts ""
    puts "Total number of FF in the design is: $reg_sum"
    return ""
}
