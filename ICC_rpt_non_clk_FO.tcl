proc report_non_clock_fanout {} {
source /mrvl/users/lioral/scripts/dc/is_clock_port.tcl

set fo [open "./report_non_clock_pin_fanout.rpt" "w"]
redirect -variable sum  {puts ""}
foreach_in_collection clk [all_clocks ] {
    set s  [get_attr $clk sources]
    set sn [get_object_name $s]
    set fanout [all_fanout -from $sn -flat -endpoints_only]
    set noport [filter_collection $fanout "object_class==pin"]
    set nonClockFanOut [filter_collection $noport "name!~CK AND name!~CLOCK AND name!~CLK AND name!~clk AND name!~ck AND name!~clock AND name!~clocked_on AND name!~CP AND name!~G AND name!~CKB AND name!~WCLK AND name!~RCLK AND name!~tck_out AND name!~tckcheckpin1"]
#-- print the collection
    puts $fo "CLOCK [get_object_name $clk] HAVE THE NEXT FANOUT THAT IS NOT A CLOCK PIN"
    puts $fo "==================================================================================="
    if {$nonClockFanOut eq ""} {
        puts $fo "clean !!!!!"
    } else {
        set i 0
        set print 0
        foreach_in_collection p $nonClockFanOut {
            if {[is_clock_port [get_object_name $p] -no_verbose] eq "0"} {
                puts $fo [get_object_name $p]
                incr i
                set print 1
            }
        }
        if {$print eq 1} {
            puts $fo "##Info: for clock [get_object_name $clk] there are $i endpoint that are not clock pins"
            redirect -variable sum -append {puts "##Info: for clock [get_object_name $clk] there are $i endpoint that are not clock pins"}
        }
    }
    puts $fo ""
    puts $fo ""

}
puts $fo ""
puts $fo ""
puts $fo "SUMMARY"
puts $fo "======="
puts $fo $sum
close $fo
return ""
}
