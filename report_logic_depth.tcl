proc report_timing_path_info {timing_paths} {
set fp [open "report_timing_path_info.rpt" w]
set formatStr {%-50s%-50s%-20s%-20s%-20s%-20s%-20s%-20s}
puts $fp [format $formatStr "Start_Point" "\tEnd_Point" "\tTotal_Depth" "\tBuf_Inv_Count" "\tPath_Cell_Delay" "\tPath_Net_Delay" "\tSlack" "\tSkew"]
foreach_in_collection timing_path $timing_paths    { 
set total_logic_depth [get_property $timing_path num_cell_arcs]
set start [get_object_name [get_property $timing_path launching_point]]
set end [get_object_name [get_property $timing_path capturing_point]]
set path_cell_delay [get_property $timing_path path_cell_delay]
set path_net_delay [get_property $timing_path path_net_delay]
set slack [get_property $timing_path slack]
set skew [get_property $timing_path skew]

set bufinv 0
foreach_in_collection tp [get_property [get_property $timing_path timing_points] pin] {        
if { [get_property $tp object_type]=="pin" && [sizeof_collection [filter_collection [get_cells -of_object $tp] "is_buffer==true||is_inverter==true"]]} { incr bufinv }}
set buf_inv [expr $bufinv/2]
puts $fp [format $formatStr \t$start \t$end \t$total_logic_depth \t$buf_inv \t$path_cell_delay \t$path_net_delay \t$slack \t$skew]
}
close $fp
puts ####################
puts "INFO :: Check \"report_timing_path_info.rpt\" for timing path info."
puts ####################

}
