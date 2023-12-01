proc round {number {digits 0}} {
 if { $digits} {
    return [expr {round(pow(10,$digits)*$number)/pow(10,$digits)}]
 } else {
    return [ int [expr {round(pow(10,$digits)*$number)/pow(10,$digits)}]]
 }
}

proc report_slack_histogram {{max_slack 0} {step 0.025}} {

set paths [report_timing -max_paths 10000 -max_slack $max_slack -collection]
set worst_slack [get_property [report_timing -collection] slack]

set bin_top [format %.3f [round [expr $worst_slack-0.005] 2]]
set bin_bottom [format %.3f [expr $bin_top+$step]]
set bin_top_orig $bin_top
set bin_bottom_orig $bin_bottom
set count($bin_top) 0

foreach_in_collection path $paths {
  set slack [get_property $path slack]
  set found 0
  while {!$found} {
    if {$slack >= $bin_top && $slack < $bin_bottom} {
      set count($bin_top) [expr $count($bin_top) + 1]
      set found 1
    } else {
      set bin_top $bin_bottom
      set bin_bottom [format %.3f [expr $bin_bottom+$step]]
      set count($bin_top) 0
    }
  }
}
set bin_top_final $bin_top
set bin_bottom_final $bin_bottom
set bin_top $bin_top_orig
set bin_bottom $bin_bottom_orig
set sum 0
puts "-----------------------------------------"
puts "| Slack Range (ns)\t| Count\t| Sum\t|"
puts "-----------------------------------------"
while {$bin_bottom <= $bin_bottom_final} {
  set sum [expr $count($bin_top)+$sum]
  puts "| ($bin_top ~ $bin_bottom]\t| $count($bin_top)\t| $sum\t|"
  set bin_top $bin_bottom
  set bin_bottom [format %.3f [expr $bin_bottom+$step]]
}
puts "-----------------------------------------"
}
