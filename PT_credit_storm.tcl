set clock {
  clk_pll_storm
  clk_st_div2
  clk_cam_vfc
}
regsub -all {\*} [lindex $clock 0] {} clkfile

#set paths [gtp -to i_ecore/i_epath0/i_vmain1_pd/i_sem_pd_core_ps/i_sem_fast_i_sem_pd_core_pb_samp_sem_pd_sem_pb_sync_error_reg_56_/D]
#set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -group **async_default** -start_end_pair -slack_less -0.1 -to i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_ts_pd/i_rbct/i_rbc_rst_ts_pd_i_m_syncffr_rst_n_tsem_track_i_resync_cell/R]

#picks up all subtypes:
#set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -start_end_pair -slack_less -0.1]
set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -max_paths 10000 -slack_less -0.1]
#set paths [gtp -group $clock -start_end_pair -slack_less -0.1]

set global_skew 0.3
set mm_per_ns 2.7
set flight_penalty 1.0

array unset corrected_slack_of

#set pathsfile credit_paths.rpt
set pnum 1
#file delete -force $pathsfile
foreach_in_collection path $paths {
  set save_path $path
  set t [lindex [get_period $path] 0]
  set keep_path $path
  set travel [expr double([lindex [path_travel $path] 0])/1000.0]
  set skew [skew_of $path]

  set sp [get_object_name [get_attribute $path startpoint]]
  #set sphier [hier_of $sp]

  set ep [get_object_name [get_attribute $path endpoint]]
  #set ephier [hier_of $ep]

  set slack [get_attribute $path slack]
  set corrected_slack [expr $slack - $skew - $global_skew]
  if {$t == "UNKNOWN"} {
    set t 0.0
  }
  set max_travel [expr $mm_per_ns * $flight_penalty * $t]
  #set keep_path $path
  if {$corrected_slack > 0.0} {
    set note "SKEW_FIX- (SKEW = $skew)"
  } elseif {$travel > $max_travel} {
    set note "TOO_FAR- PIPELINE (TRAVEL=$travel/$max_travel)"
  } else {
    set note "BAD_DATA PATH? (TRAVEL=$travel/$max_travel)"
  }
  set str "$corrected_slack,$slack,$note,$sp,$ep,$skew,$t,$travel"
  set corrected_slack_of($str) $corrected_slack
  incr pnum 1

}

proc by_slack {A B} {
  upvar corrected_slack_of corrected_slack_of
  if {$corrected_slack_of($A) > $corrected_slack_of($B)} { return 1 } else { return -1 }
}

set fout [open categorized_paths_${clkfile}_[get_top_version].csv w]
puts $fout "SKEW_CORRECTED_SLACK,SLACK,NOTE,STARTPOINT,ENDPOINT,SKEW,PERIOD,TRAVEL"
foreach el [lsort -command by_slack [array names corrected_slack_of]] {
  puts $fout $el
}
close $fout
