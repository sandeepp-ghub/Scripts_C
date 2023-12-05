
set make 0
set broken 0
set slack_thr 0.0
set margin 0.1
# ALSO USEFUL: [get_pins -hier */*_feed*]
set pipedq [sort_collection [get_pins -hier -filter "max_slack<$slack_thr && (lib_pin_name==D || lib_pin_name==Q || lib_pin_name==QN) && full_name=~*i_*pipe*gen_array*_reg_*"] full_name]
#set pipedq [get_pins i_pcie_phy_top/i_pipe_pemx__gser_tx_x4_grp3/genblk1_ff_gen_array_1__i_m_enffr/out_reg_9_/Q]

proc pipehier {PIN} {
  set i 0
  set nlist [file split [get_object_name $PIN]]
  foreach el $nlist {
    if {[regexp gen_array $el]} {
      return [join [lrange $nlist 0 [expr $i -1]] {/}]
    }
    incr i 1
  }
  return 0
}

array unset move
foreach_in_collection pin $pipedq {
  if {[get_attribute $pin lib_pin_name] == "Q"} {
    set dpin [get_pins -of [get_cells -of $pin] -filter "lib_pin_name==D"]
    set qpin $pin
  } else {
    set dpin $pin
    set qpin [get_pins -of [get_cells -of $pin] -filter "lib_pin_name==Q||lib_pin_name==QN"]
  }
  set cell [get_cells -of $pin]
  #puts "INFO: Testing Cell: [get_object_name $cell] pin==[get_object_name $pin]"
  set dslack [get_attribute -quiet $dpin max_slack]
  set qslack [get_attribute -quiet $qpin max_slack]
  if {$dslack == ""} {
    puts "WARNING: D pin unconstrained on [get_object_name $cell]"
  } elseif {$qslack == ""} {
    puts "WARNING: Q pin unconstrained on [get_object_name $cell]"
  } else {
    set dpath [gtp -to $dpin]
    set qpath [gtp -thro $qpin]
    if {[sizeof_collection $dpath] > 0 && [sizeof_collection $qpath] > 0} {
      set dskew [skew_of $dpath]
      set qskew [skew_of $qpath]
      set dslack [expr $dslack - $dskew - $margin]
      set qslack [expr $qslack - $qskew - $margin]
      set sum [expr $dslack + $qslack]
        set p1 [get_attribute $dpath startpoint]
          set p1x [format "%0.0f" [expr [get_attribute $p1 x_coordinate]/1000.0]]]
          set p1y [format "%0.0f" [expr [get_attribute $p1 y_coordinate]/1000.0]]]
        set p2 [get_attribute $dpath endpoint]
          set p2x [format "%0.0f" [expr [get_attribute $p2 x_coordinate]/1000.0]]]
          set p2y [format "%0.0f" [expr [get_attribute $p2 y_coordinate]/1000.0]]]
        set p3 [get_attribute $qpath endpoint]
          set p3x [format "%0.0f" [expr [get_attribute $p3 x_coordinate]/1000.0]]]
          set p3y [format "%0.0f" [expr [get_attribute $p3 y_coordinate]/1000.0]]]
        set p1t [lindex [path_travel $dpath] 0]
        set p2t [lindex [path_travel $qpath] 0]
        set tt [expr $p1t + $p2t]
        set at [expr $tt/2.0]
        set dt [expr $p2t - $at]
        if {0} {
        set p1h [pipehier $p1]
        set p2h [pipehier $p2]
        set p3h [pipehier $p3]
        if {$p1h == 0} {set p1h [hier_of $p1]}
        if {$p2h == 0} {set p2h [hier_of $p2]}
        if {$p3h == 0} {set p3h [hier_of $p3]}
        }
        set p1h [get_object_name [get_cells -of $p1]]
        set p2h [get_object_name [get_cells -of $p2]]
        set p3h [get_object_name [get_cells -of $p3]]
        if {$dt < 0} {set dest $p1h} else {set dest $p3h}
        set dtabs [expr abs($dt)]
        if {$sum > 0.0} {
          set mkey "$dtabs,$p2h,$dest,CENTER_LENGTH"
        } else {
          set mkey "$dtabs,$p2h,$dest,BROKEN- DOES NOT MAKE BOTH CYCLES"
        }
        if {! [info exists move($mkey)]} {
          set move($mkey) 1
        } else {
          incr move($mkey) 1
        }
        incr make 1
    } else {
      if {[sizeof_collection $dpath] == 0} {puts "WARNING: No path to [get_object_name $dpin]"}
      if {[sizeof_collection $qpath] == 0} {puts "WARNING: No path thro [get_object_name $qpin]"}
    }
  }
}

#puts "WILL MAKE: $make"
#puts "BROKEN:    $broken"

set fout [open pipe_eval.rpt w]
puts $fout "MOVE,MOVE_REGISTER,TOWARD_REGISTER,NOTES"
foreach el [lsort [array names move]] {
  #puts "$move($el) $el"
  puts $fout "$el"
}
close $fout
