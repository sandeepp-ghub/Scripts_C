
set paths [get_timing_paths -del min -slack_less 0.0 -max_paths 1000000]

array unset master_of
redirect -variable master_info {report_clock_hierarchy}
foreach line [split $master_info "\n"] {
  if {[regexp {^.*\+-(\S+)} $line match clock]} {
    set master_of($clock) $master
  } else {
    set master $line
    set master_of($line) $line
  }
}

array unset seen_crossing
foreach_in_collection path $paths {
  set sc [get_attribute $path startpoint_clock]
  set ec [get_attribute $path endpoint_clock]
  set scname [get_object_name $sc]
  set ecname [get_object_name $ec]
  if {![info exists master_of($scname)]} {
    puts "INFO: Seting master clock of $scname to NULL."
    set master_of($scname) NULL
  }
  if {![info exists master_of($ecname)]} {
    puts "INFO: Seting master clock of $ecname to NULL."
    set master_of($ecname) NULL
  }
  set key $scname:$ecname
  if {$master_of($scname) == $master_of($ecname)} {
  } elseif {$master_of($scname) == "NULL" || $master_of($ecname) == "NULL"} {
    puts "INFO: Skipping $scname:$ecname since we don't know the intended relationship."
  } elseif {$master_of($scname) != $master_of($ecname)} {
    if {![info exists seen_crossing($key)]} {
      set seen_crossing($key) 1
    } else {
      incr seen_crossing($key) 1
    }
  } else {
    #puts "OK: $scname and $ecname have the same master clock ($master_of($scname))"
  }
}

proc by_count {A B} {
  upvar seen_crossing seen_crossing
  if {$seen_crossing($A) < $seen_crossing($B)} {
    return 1
  } else {
    return -1
  }
}

set fout [open additional_hold_clock_fps.tcl w]
foreach el [lsort -command by_count [array names seen_crossing]] {
  set cks [split $el {:}]
  set ck1 [lindex $cks 0]
  set ck2 [lindex $cks 1]
  puts $fout "set_false_path -hold -from \[get_clocks $ck1\] -to   \[get_clocks $ck2\] ; # $seen_crossing($el) hold crossings between different-master clocks:"
  puts $fout "set_false_path -hold -to   \[get_clocks $ck1\] -from \[get_clocks $ck2\] ; # $master_of($ck1) != $master_of($ck2)" 
  puts $fout ""
}
close $fout
