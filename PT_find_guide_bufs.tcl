
set all_pins [get_pins -hier {*clk_gate_dff/Q *clk_gate_div2_buf/Y *clk_gate_buf/Y}]

foreach_in_collection pin [sort_collection $all_pins full_name] {
  puts "[sizeof_collection [get_attribute -quiet $pin clocks]] [get_object_name $pin]"
}
