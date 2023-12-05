
if {$run_type_specific == "max1"} {
  delta_finder -max_paths 100000 -nworst 5 -path_type full_clock_expanded -enhanced_clock -magnitude_filter 0.003

set ref_of(top) everest

  set fin [open delta_finder_reports/clock_xtalk_victims_by_magnitude.rpt r]
  while {[gets $fin line] >= 0} {
    if {[regexp {^#\s+(\S+)\s+(\S+)\s+(\S+?)(:\S+:\S+)*\s+(\S+)} $line match max_delta path victim victimclk vnet]} {
      set pinhier [hier_of [get_pins $victim]]
      set nethier [hier_of [get_nets $vnet]]
      if {$max_delta >= 0.003} {
        if {$pinhier == $nethier} {
          puts "IN $ref_of($pinhier): victim $victim on net $vnet ($max_delta, on clocks $victimclk)"
          puts -nonewline "  "
          aggressors_of $victim
        } else {
          puts "CROSS HIER: victim $victim in $ref_of($pinhier)  on net $vnet in $ref_of($nethier) ($max_delta, on clocks $victimclk)"
          puts -nonewline "  "
          aggressors_of $victim
        }
      }
    }
  }
  close $fin
  
  file copy -force delta_finder_reports/clock_xtalk_victims_by_magnitude.rpt delta_finder_reports/clock_xtalk_victims_by_magnitude_icc2_raw.rpt
  file copy -force delta_finder_reports/data_xtalk_victims_by_magnitude.rpt delta_finder_reports/data_xtalk_victims_by_magnitude_icc2_raw.rpt
  
  set fin [open delta_finder_reports/clock_xtalk_victims_by_magnitude_icc2_raw.rpt r]
  set fout [open delta_finder_reports/clock_xtalk_victims_by_magnitude_icc2.rpt w]
  #e5_exclude_nets
  proc cn_is_e5_custom_net {LINE} {
    upvar e5_exclude_nets e5_exclude_nets
    foreach el $e5_exclude_nets {
      if {[regexp $el $LINE]} { return 1 }
    }
    return 0
  }
  
  while {[gets $fin line] >= 0} {
    regsub {if \{0\}} $line {if {1}} line
    regsub set_coupling_separation $line {set clock_coupling_separation} line
    if {![cn_is_e5_custom_net $line]} {
      puts $fout $line
    }
  }
  close $fin
  close $fout
  
  set fin [open delta_finder_reports/data_xtalk_victims_by_magnitude_icc2_raw.rpt r]
  set fout [open delta_finder_reports/data_xtalk_victims_by_magnitude_icc2.rpt w]
  while {[gets $fin line] >= 0} {
    regsub {if \{0\}} $line {if {1}} line
    regsub set_coupling_separation $line {set data_coupling_separation} line
    if {![cn_is_e5_custom_net $line]} {
      puts $fout $line
    }
  }
  close $fin
  close $fout

} elseif {$run_type_specific == "min1"} {

  delta_finder -max_paths 100000 -nworst 5 -path_type full_clock_expanded -magnitude_filter 0.003 -delay min -rpt_dir delta_finder_reports_min1 -enhanced_clock

}
