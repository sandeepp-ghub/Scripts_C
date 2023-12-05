set workhorse 0.375

file mkdir flight
set fout [open flight.csv w]
puts $fout "INDEX,TRAVEL,PERIOD,REQUIRED_RATE,REQUIRED_CYCLES,SKEW,STARTPOINT,ENDPOINT,PATH_GROUP"

set i 0
foreach_in_collection p [sort_collection [get_timing_paths -include -slack_less -1.0 -max_paths 1000] slack] {
  set p$i $p
  set raw_period [get_period $p]
  set period [lindex $raw_period 0]
  set slack [get_attribute $p slack]
  set raw_travel [path_travel $p]
  if {[lindex $raw_travel 0] != "UNKNOWN"} {
    set travel [expr [lindex $raw_travel 0] /1000.0]
    set rate [format "%0.4f" [expr $period / $travel]]
  } else {
    set travel UNKNOWN
    set rate UNKNOWN
  }
  set skew [format "%0.1f" [lindex $raw_period 1]]
  if {$period > 0.0} {
    if {$rate != "UNKNOWN"} {
      set cycles [format "%0.1f" [expr $workhorse/$rate]]
    } else {
      set cycles UNKNOWN
    }
    #puts "Travel $travel mm in $period ns skew $skew @ $rate [get_object_name [get_attribute $p startpoint]] to [get_object_name [get_attribute $p endpoint]] [get_object_name [get_attribute $p path_group]]"
    puts $fout "$i,$travel,$period,$rate,$cycles,$skew,[get_object_name [get_attribute $p startpoint]],[get_object_name [get_attribute $p endpoint]],[get_object_name [get_attribute $p path_group]]"
    report_timing -nosplit -input $p > flight/p${i}.rpt
  } else {
  }
  incr i 1
}

close $fout
