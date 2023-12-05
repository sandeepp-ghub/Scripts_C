#set paths [gtpm -slack_less 0.0 -start_end_pair]
set paths [gtpm -slack_less 0.0 -group clk_pll_main -max_paths 5000 -attr {startpoint_clock endpoint_clock slack points object path_group endpoint}]

set paths [sort_collection $paths slack]

#set mypaths [index_collection $paths 0 5000]
set mypaths $paths

set fout [open test_in_max1.pt w]
puts $fout "array unset fail_of"
puts $fout "set rpt \[open window.rpt w\]"
foreach_in_collection path $mypaths {
  set tpt [index_collection [get_attribute $path points] 1]
  set tpin [get_object_name [get_attribute $tpt object]]
  set epin [get_object_name [get_attribute $path endpoint]]
  set slack [get_attribute $path slack]
  set lc [get_object_name [get_attribute $path startpoint_clock]]
  set cc [get_object_name [get_attribute $path endpoint_clock]]
  set pg [get_object_name [get_attribute $path path_group]]
  puts $fout "set minslack $slack"
  puts $fout "set path \[get_timing_paths -attr slack -thro $tpin -to $epin\]"
  puts $fout "set maxslack \[get_attribute -quiet \$path slack\]"
  puts $fout "if {\$maxslack == \"\"} {set maxslack 100.0}"
  puts $fout "puts -nonewline \$rpt \"TESTING TP=$tpin to EP=$epin in min1/max1 == \$minslack/\$maxslack LC=$lc CC=$cc PG=$pg ...\""
  puts $fout "set test \[expr (2.0 * \$minslack) + \$maxslack]"
  puts $fout "if {\$test < 0.0} {puts \$rpt \"FAIL\"; set fail_of\($epin) \$test} else {puts \$rpt \"\"}"
}

puts $fout "close \$rpt"

puts $fout {
proc by_fail {A B} {
  upvar fail_of fail_of
  if {$fail_of($B) < $fail_of($A)} {
    return 1
  } else {
    return -1
  }
}

set fo2 [open window_sorted.rpt w]
foreach el [lsort -command by_fail [array names fail_of]] {
  puts $fo2 "$fail_of($el) $el"
}
close $fo2
}
close $fout
