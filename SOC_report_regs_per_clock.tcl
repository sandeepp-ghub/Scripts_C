#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: report_regs_per_clock in a table format               #
#====================================================================#
# Example: report_regs_per_clock                                     #
#====================================================================#


proc soc_report_regs_per_clock {} {
    set clocks [get_clocks *]
    set reg_sum "0"
    set tot_sum [sizeof_collection [all_registers]]
    foreach_in_collection clk $clocks {
        set size "0"
        set size [sizeof_collection [all_registers -clock $clk]]
        echo [format "%-40s %-13s" "[get_object_name $clk]"   "$size"]
        set reg_sum [expr {$reg_sum + $size}]
    }
    puts ""
    puts "Total number of clocked FF in the design is: $reg_sum"
    puts "Total number of FF in the design is: $tot_sum"
    puts "Unclocked regs:[expr $tot_sum - $reg_sum]"
    return ""
}
