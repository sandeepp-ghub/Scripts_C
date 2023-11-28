set ifile [open /user/lioral/budget_min r]
#set ifile [open /user/lioral/setup_in r]
#set ifile [open /user/lioral/tmp r]
set inp ""
set inc ""
set onp ""
set onc ""
while { [gets $ifile line] >= 0 } {
    set line       [join $line " "]
    set port       [lindex $line 0]
    if {[get_attr [get_ports $port] direction] =="out"} {continue}
    set slack      [expr [lindex $line 1] - 0.00]
    set tp         [get_timing_path -delay_type min -from $port -to [get_clocks *rclk*]]
    if {$tp eq ""} {
        puts "LIORAL-INFO: $port"    
        continue
    }
    set cur_budgt  [get_attr $tp startpoint_input_delay_value]
    set cur_slack  [get_attr $tp slack]
    set cur_clock  [get_attr $tp endpoint_clock_latency]
    set cur_arr    [get_attr $tp arrival]
    echo $port
    set cur_unct   0.015
    set cur_jit    0.010
    set cur_data   [expr $cur_arr - $cur_budgt]
    set period     [get_attr [get_clocks rclk] period]
    set setupt     [get_attr $tp endpoint_setup_time_value]
    echo "CUR_BUD:$cur_budgt"
    echo "CUR_SLK: $cur_slack"
    echo "CUR_CLK: $cur_clock"
    echo "UNC      $cur_unct"
    echo "JIT      $cur_jit"
    echo "PERI      $period"
    echo "ARR:     $cur_arr"
    echo "DATA:    $cur_data"
    echo "SLACK    $slack"

    lappend inp $port
#echo "$cur_clock + $period  -$cur_jit -$cur_unct - $cur_data - $slack - $setupt"
    #set new_val [expr $cur_clock + $period  -$cur_jit -$cur_unct - $cur_data - $slack ] ;# slakc is neg
    set new_val [expr $cur_budgt - ($cur_slack - $slack) ] ;# slack is neg
#     echo "$cur_clock + $period  -$cur_jit -$cur_unct - $cur_data - $slack  = $new_val"
    echo "$cur_budgt - \($cur_slack -$slack\) = $new_val" 
    lappend inc "set_input_delay $new_val -min -clock rclk \[get_ports $port\] ;# slack $slack "
#lappend inc "set_input_delay $new_val -max -clock scan_atspeed_capture_rclk_pllout \[get_ports $port\] ;# slack $slack "
#    echo "$inc"

}
close $ifile

foreach i $inc {
    echo $i >> rclk_budget_input_file.tcl
#   eval $i
}

echo $inp

#remove_path_group INPUT
#group_path -name rclk_in_rebudget -from [get_ports $inp]
#group_path -name INPUT -from [remove_from_collection [all_inputs ] [get_ports $inp]]
#
##out
#set ifile [open /user/lioral/setup_out r]
#while { [gets $ifile line] >= 0 } {
#    echo $line
#    set line       [join $line " "]
#    set port       [lindex $line 0]
#    set slack      [expr [lindex $line 1] - 0.01]
#    set tp         [get_timing_path -to $port -from [get_clocks rclk]]
#    set cur_budgt  [get_attr $tp endpoint_output_delay_value]
#    set cur_slack  [get_attr $tp slack]
#    set cur_clock  [get_attr $tp startpoint_clock_latency]
#    set cur_arr    [get_attr $tp arrival]
#    echo $port
#    set cur_unct   0.015
#    set cur_jit    0.010
#    set cur_data   [expr $cur_arr - $cur_budgt]
#    set period     [get_attr [get_clocks rclk] period]
#    echo "CUR_BUD:$cur_budgt"
#    echo "CUR_SLK: $cur_slack"
#    echo "CUR_CLK: $cur_clock"
#    echo "UNC      $cur_unct"
#    echo "JIT      $cur_jit"
#    echo "PERI      $period"
#    echo "ARR:     $cur_arr"
#    echo "DATA:    $cur_data"
#    echo "SLACK    $slack"
#    lappend onp $port
#    set new_val [expr $cur_clock + $period  -$cur_jit -$cur_unct - $cur_data - $slack] ;# slakc is neg
#    lappend onc "set_input_delay $new_val -max -clock rclk \[get_ports $port\] \n"
#
#}
#
