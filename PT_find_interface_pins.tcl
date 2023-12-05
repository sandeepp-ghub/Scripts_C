
foreach io {
GPIO_23
P1_SIGDET
P0_SPD2_LED_B
P1_SPD0_LED_B
P1_SPD1_LED_B
} {
  set inpin [filter_collection [all_fanout -flat -from [get_ports $io] -endpoints_only ] lib_pin_name==pi_scan_clock]
  set outpin [get_pins -of [get_cells -of $inpin] -filter "lib_pin_name==pll_interface_out"]
  if {[sizeof_collection $outpin] == 1} {
    puts "cn_pt_create_clock -name scan_$io -at_pins [get_object_name $outpin]"
  } else {
    set i 0
    foreach_in_collection p [sort_collection $outpin full_name] {
    puts "cn_pt_create_clock -name scan_${io}${i} -at_pins [get_object_name $p]"
    incr i 1
    }
  }
}
