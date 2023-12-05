
set fout [open clock_muxes.rpt w]
set all_mux_pins {}
foreach_in_collection op [sort_collection [get_pins -hier -filter "direction==out && defined(clocks)"] full_name] {
  set cs [get_attribute $op clocks]
  set oclknum [sizeof_collection $cs]
  if {$oclknum > 1} {
    unset -nocomplain minc
    set ipclkpins [get_pins -quiet -of [get_cells -quiet -of $op] -filter "direction==in && defined(clocks)"]
    foreach_in_collection ip $ipclkpins {
      set clks [get_attribute $ip clocks]
      set iclknum [sizeof_collection $clks]
      if {![info exists minc] || $iclknum < $minc} { set minc $iclknum }
    }
    if {[info exists minc]} {
      if {$minc < $oclknum} {
        set all_mux_pins [add_to_collection $all_mux_pins $op]
        puts $fout "MUX:"
        puts $fout "Output [get_object_name $op] has clocks: [get_object_name $cs]"
        puts $fout "Inputs with clocks:"
        foreach_in_collection ip $ipclkpins {
          puts $fout "  [get_object_name $ip] has clocks: [get_object_name [get_attribute $ip clocks]]"
        }
      }
    } else {
      puts $fout "ERROR: [get_object_name $op] has clocks but no inputs have clocks!"
    }
  }
}

set allconfigps [sort_collection [filter_collection [all_fanin -flat -to $all_mux_pins -startpoints_only ] !defined(clocks)] full_name]

puts $fout "Total Mux count: [sizeof_collection $all_mux_pins]"
puts $fout "Potential Case Analyses ports or CK pins (move to Q pin):"
foreach_in_collection p $allconfigps {
  puts $fout "  [get_object_name $p]"
}
