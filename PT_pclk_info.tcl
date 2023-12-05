set regs [all_registers -clock_pins]

set rx0 [filter_collection $regs "full_name=~*i_pipe_gser__pemx_rx*gen_array_0*"]
set rx1 [filter_collection $regs "full_name=~*i_pipe_gser__pemx_rx*gen_array_1*"]

set tx0 [filter_collection $regs "full_name=~*i_pipe_pemx__gser_tx*gen_array_0*"]
set tx1 [filter_collection $regs "full_name=~*i_pipe_pemx__gser_tx*gen_array_1*"]

puts "RX LAYER 0 [sizeof_collection $rx0]:"
foreach_in_collection pin $rx0 {
  redirect -variable co {clocks_of $pin}
  puts "  [get_object_name $pin]:"
  foreach el $co { puts "   $el" } 
}

puts "RX LAYER 1 [sizeof_collection $rx1]:"
foreach_in_collection pin $rx0 {
  redirect -variable co {clocks_of $pin}
  puts "  [get_object_name $pin]:"
  foreach el $co { puts "   $el" } 
}

puts "TX LAYER 0 [sizeof_collection $tx0]:"
foreach_in_collection pin $rx0 {
  redirect -variable co {clocks_of $pin}
  puts "  [get_object_name $pin]:"
  foreach el $co { puts "   $el" } 
}

puts "TX LAYER 1 [sizeof_collection $tx1]:"
foreach_in_collection pin $rx0 {
  redirect -variable co {clocks_of $pin}
  puts "  [get_object_name $pin]:"
  foreach el $co { puts "   $el" } 
}
