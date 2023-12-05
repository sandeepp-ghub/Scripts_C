set fout [open min_pulse.csv w]

foreach file [glob min_pulse_sum_*.rpt] {
  set fin [open $file r]
  
  array unset count_of_clock
  array unset count_of_type
  puts $fout "SLACK,ACTUAL,LIMIT,PIN_TRANSITION,TYPE,PIN,CLOCK"
  while {[gets $fin line] >= 0} {
#rcplx/connect_rcplx_ch_clu2_auto_smmu2__smmu1_scr_chain_clu2_chan_flop_row_3__chnflop_cond_icg__cmicg/CK (low)   0.2758   0.1763  -0.0995 (VIOLATED)

    if {[regexp {(\S+)\s+\((high|low)\)\s+(\S+)\s+(\S+)\s+(\S+)\s+\(VIOLATED\)} $line match pin hilo actual limit slack]} {
      set pin_tran [get_attribute [get_pins $pin] actual_transition_max]
      set cell_type [get_attribute [get_cells -of [get_pins $pin]] ref_name]
      set clock [get_object_name [get_attribute [get_pins $pin] clocks]]
      puts $fout "$slack,$actual,$limit,$pin_tran,$cell_type,$pin,$clock"
      incr count_of_type($cell_type:$clock) 1
      incr count_of_clock($clock) 1
    } else {
      #puts "SKIP: $line"
    }
  }

close $fin

}

proc by_count_clock {A B} {
  upvar count_of_clock count_of_clock
  if {$count_of_clock($B) < $count_of_clock($A)} {
    return 1
  } else {
    return -1
  }
} 

proc by_count_type {A B} {
  upvar count_of_type count_of_type
  if {$count_of_type($B) < $count_of_type($A)} {
    return 1
  } else {
    return -1
  }
} 

puts $fout "COUNT,TYPE"
foreach el [lsort -command by_count_type [array names count_of_type]] {
  puts $fout "$count_of_type($el),$el"
}

puts $fout "COUNT,CLOCK"
foreach el [lsort -command by_count_clock [array names count_of_clock]] {
  puts $fout "$count_of_clock($el),$el"
}

close $fout
