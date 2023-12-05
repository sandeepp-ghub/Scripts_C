set find_clocks {
sclk
}

set find_insts {}
foreach blk $pnr_blks {
    set find_insts [concat $find_insts [get_object_name [get_cells -hier -filter "ref_name==$blk"]]]
}

set ts NULL
if {$timing_all_clocks_propagated} {
  set ts "${ts}_prop"
} else {
  set ts "${ts}_ideal"
}

proc is_clock {PIN CLOCK_NAME} {
  set clist [get_object_name [get_attribute $PIN clocks]]
  if {[lsearch -exact $clist $CLOCK_NAME] > -1} {
    return 1
  } else {
    return 0
  }
}

#arrival_window                 {{{clk_ref} pos_edge {min_r_f 29.3547 32.8341} {max_r_f 70.7188 74.6592}} {{clk_ref} neg_edge {min_r_f NA 29.4711} {max_r_f NA 69.0584}} {{clk_pll_main} pos_edge {min_r_f 20.9239 24.4033} {max_r_f 21.0301 24.9705}} {{clk_pll_main} neg_edge {min_r_f NA 21.0259} {max_r_f NA 21.1232}} {{clk_ref_div3} pos_edge {min_r_f 29.484 32.9634} {max_r_f 70.8567 74.7971}} {{clk_ref_div3} neg_edge {min_r_f NA 29.5785} {max_r_f NA 70.9471}}}

proc arrival {PIN CLOCK_NAME} {
  set awindow [get_attribute $PIN arrival_window]
  foreach win $awindow {
    foreach e1 $awindow {
      foreach e2 $e1 {
        foreach {wname edge w1 w2} $e2 {
          set name [lindex $wname 0]
          if {$name == $CLOCK_NAME && $edge == "pos_edge"} {
            #puts "$name $edge $w1 $w2"
            if {[lindex $w1 0] == "max_r_f"} {
              set r [lindex $w1 1]
              set f [lindex $w1 2]
              if {$r == "NA"} { return $f } else { return $r }
            } elseif {[lindex $w2 0] == "max_r_f"} {
              set r [lindex $w2 1]
              set f [lindex $w2 2]
              if {$r == "NA"} { return $f } else { return $r }
            } else {
              return -1
            }
          }
        }
      }
    }
  }
}
foreach find_clock $find_clocks {

	set fout [open ${find_clock}_lat_${ts}.csv w]
	puts $fout "MAX_RISE,PIN,DIRECTION,INSIDE_LOADS,ALL_LOADS"
	set all_clock_pins {}
	array unset hpin_of
	array unset lat_of
	array unset string_of
	foreach blk $find_insts {
	  puts "INFO: Looking $find_clock on $blk ..."
	  set cells [get_cells -quiet $blk]
	  set pins [sort_collection [get_pins -quiet -of $cells] full_name]
	  foreach_in_collection pin $pins {
	    set pindir [get_attribute $pin direction]
	    set cellpat [get_object_name [get_attribute $pin cell]]
	    set loads [get_pins -quiet -leaf -of [get_nets -quiet -of $pin] -filter "direction==in && defined(clocks) && full_name!=*/diode_* && full_name=~${cellpat}/*"]
	    set all_loads [get_pins -quiet -leaf -of [get_nets -quiet -of $pin] -filter "direction==in && full_name!=*/diode_*"]
	    if {[sizeof_collection $loads] > 0 && [is_clock [index_collection $loads 0] $find_clock]} {
	      set total_delay 0.0
	      set n 0
	      foreach_in_collection load $loads {
	        incr n 1
	        set dly [arrival $load $find_clock]
	        if {$dly > 0.0 && $dly != "NA"} {
	          set total_delay [expr $total_delay + $dly]
	        } else {
	          puts "ERROR: No delay on [get_object_name $load] ([get_attribute $load arrival_window])"
	        }
	      }
	      set avg_insertion [expr $total_delay/double($n)]
	      set lat_of([get_object_name $pin]) $avg_insertion
	      set string_of([get_object_name $pin]) "[format "%0.3f" $avg_insertion],[get_object_name $pin],$pindir,[sizeof_collection $loads],[sizeof_collection $all_loads]"
	      #puts $fout "[format "%0.2f" $avg_insertion],[get_object_name $pin],$pindir,[sizeof_collection $loads],[sizeof_collection $all_loads]"
	    }
	  }
	}
	proc by_lat {A B} {
    upvar lat_of lat_of
	  if {$lat_of($A) > $lat_of($B)} {
	    return 1
	  } else {
	    return 0
	  }
	}
	foreach el [lsort -command by_lat [array names lat_of]] {
	  puts $fout $string_of($el)
	}
	close $fout

}
