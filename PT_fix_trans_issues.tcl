set data_thr 0.1
set clock_thr 0.05
set manh_thr     0.15

set rate 0.375 ; # ns/mm

#set fout [open clip_tran_and_delay_${run_type_specific}.pt w]
set fout [open donot_pt_pre_update_timing_script.pt w]

set dout [open high_tran_data_nets.rpt w]
set cout [open high_tran_clock_nets.rpt w]

array unset seen_data_net
array unset seen_clock_net
array unset seen_data_spec
array unset seen_clock_spec
array unset seen_clock_name
puts $fout "#CLOCK:"
foreach_in_collection pin [sort_collection -desc [get_pins -hier -filter  "is_clock_network && direction==in && actual_transition_max > $clock_thr"] actual_transition_max] {
  set tmax [get_attribute $pin actual_transition_max]
  set tspec [get_attribute $pin max_transition]
  set tslack [expr $tspec - $tmax]
  if {$tslack < 0.0} {
    set keep_pin $pin
    set xy_broken false
    set topnet [get_object_name [get_nets -seg -top -of $pin]]
    if {![info exists seen_clock_net($topnet)] || $tmax > $seen_clock_net($topnet)} {
      set seen_clock_net($topnet) $tmax
      set seen_clock_spec($topnet) [get_attribute $pin max_transition]
      set seen_clock_name($topnet) [get_object_name [get_attribute $pin clocks]]
    }
    set pinx [get_attribute -quiet $pin x_coordinate]
    set piny [get_attribute -quiet $pin y_coordinate]
    if {$pinx == "" || $piny == ""} {
      puts $fout "#ERROR: Coordinates missing for [get_object_name $pin]"
      set xy_broken true
    }
    puts $fout "set_annotated_transition $data_thr \[get_pins [get_object_name $pin]\]; # CWAS: [get_attribute $pin actual_transition_min]/[get_attribute $pin actual_transition_max]"
    set drpin [get_pins -quiet -leaf -of [get_nets -of $pin] -filter "direction==out"]
    if {![sizeof_collection $drpin]} {
      set drpin [get_ports -of [get_nets -seg -top -of $pin]]
      #puts "START: [get_object_name $drpin]"
    }
    set drx [get_attribute -quiet $drpin x_coordinate]
    set dry [get_attribute -quiet $drpin y_coordinate]
    if {$drx == "" || $dry == ""} {
      puts $fout "#ERROR: Coordinates missing for [get_object_name $drpin]"
      set xy_broken true
    }
    if {!$xy_broken} {
      set manh [expr abs($pinx - $drx) + abs($piny - $dry)]
    } else {
      set manh 99999.9
    }
    if {!$xy_broken && ($manh > $manh_thr || $tmax > $clock_thr)} {
      set manh [expr (abs($drx-$pinx) + abs($dry-$piny))/1000000.0]
      set dly [format "%0.3f" [expr $manh * $rate]]
      puts $fout "set_annotated_delay $dly -net -from \[get_pins [get_object_name $drpin]\] -to \[get_pins [get_object_name $pin]\] ; # CALCULATED MANHATTAN==$manh"
    } elseif {$xy_broken} {
      puts $fout "#ERROR MISSING COORDS BETWEEN [get_object_name $drpin] AND [get_object_name $pin]"
    } else {
      puts $fout "#PASS ON [get_object_name $pin] MANHATTAN==$manh"
    }
  }
}

puts $fout "#DATA:"
foreach_in_collection pin [sort_collection -desc [get_pins -hier -filter "!is_clock_network && direction==in && actual_transition_max > $data_thr"] actual_transition_max] {
  set tmax [get_attribute $pin actual_transition_max]
  set tspec [get_attribute $pin max_transition]
  set tslack [expr $tspec - $tmax]
  if {$tslack < 0.0} {
    set xy_broken false
    set topnet [get_object_name [get_nets -seg -top -of $pin]]
    if {![info exists seen_data_net($topnet)] || $tmax > $seen_data_net($topnet)} {
      set seen_data_net($topnet) $tmax
      set seen_data_spec($topnet) [get_attribute $pin max_transition]
    }
    set pinx [get_attribute -quiet $pin x_coordinate]
    set piny [get_attribute -quiet $pin y_coordinate]
    if {$pinx == "" || $piny == ""} {
      puts $fout "#ERROR: Coordinates missing for [get_object_name $pin]"
      set xy_broken true
    }
    puts $fout "set_annotated_transition $data_thr \[get_pins [get_object_name $pin]\]; # DWAS: [get_attribute $pin actual_transition_min]/[get_attribute $pin actual_transition_max]"
    #set drpin [get_pins -leaf -of [get_nets -of $pin] -filter "direction==out"]
    set drpin [get_pins -quiet -leaf -of [get_nets -of $pin] -filter "direction==out"]
    if {![sizeof_collection $drpin]} {
      set drpin [get_ports -of [get_nets -seg -top -of $pin]]
      #puts "START: [get_object_name $drpin]"
    }
    set drx [get_attribute -quiet $drpin x_coordinate]
    set dry [get_attribute -quiet $drpin y_coordinate]
    if {$drx == "" || $dry == ""} {
      puts $fout "#ERROR: Coordinates missing for [get_object_name $drpin]"
      set xy_broken true
    }
    if {!$xy_broken && ($manh > $manh_thr || $tmax > $data_thr)} {
      set manh [expr (abs($drx-$pinx) + abs($dry-$piny))/1000000.0]
      set dly [format "%0.3f" [expr $manh * $rate]]
      puts $fout "set_annotated_delay $dly -net -from \[get_pins [get_object_name $drpin]\] -to \[get_pins [get_object_name $pin]\] ; # CALCULATED MANHATTAN==$manh"
    } elseif {$xy_broken} {
      puts $fout "#ERROR MISSING COORDS BETWEEN [get_object_name $drpin] AND [get_object_name $pin]"
    } else {
      puts $fout "#PASS ON [get_object_name $pin] MANHATTAN==$manh"
    }
  }
}

proc by_ctran {A B} {
  upvar seen_clock_net seen_clock_net
  if {$seen_clock_net($A) < $seen_clock_net($B)} {
    return 1
  } else {
    return -1
  }
}

proc by_dtran {A B} {
  upvar seen_data_net seen_data_net
  if {$seen_data_net($A) < $seen_data_net($B)} {
    return 1
  } else {
    return -1
  }
}

puts $cout "TRAN,SPEC,NET,CLOCK(s)"
foreach el [lsort -command by_ctran [array names seen_clock_net]] {
  if {![regexp SYNOPSYS_UNCON $el]} {
    puts $cout "$seen_clock_net($el),$seen_clock_spec($el),$el,$seen_clock_name($el)"
  }
}

puts $dout "TRAN,SPEC,NET"
foreach el [lsort -command by_dtran [array names seen_data_net]] {
  if {![regexp SYNOPSYS_UNCON $el]} {
    puts $dout "$seen_data_net($el),$seen_data_spec($el),$el"
  }
}

close $fout
close $cout
close $dout
