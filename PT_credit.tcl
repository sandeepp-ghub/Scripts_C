set clock {
  clk_pll_main
  clk_core_neg_div2
  clk_core_neg_div4
  clk_core_pos_div2
  clk_core_pos_div4
  clk_cp
  clk_flash
  clk_sclk
  clk_flash_legacy
  clk_sclk_legacy
  clk_main_neg_div2
  clk_main_neg_div4
  clk_main_pos_div2
  clk_main_pos_div4
  clk_mdc
  clk_nws_apb
}
regsub -all {\*} [lindex $clock 0] {} clkfile

#set paths [gtp -to i_ecore/i_epath0/i_vmain1_pd/i_sem_pd_core_ps/i_sem_fast_i_sem_pd_core_pb_samp_sem_pd_sem_pb_sync_error_reg_56_/D]
#set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -group **async_default** -start_end_pair -slack_less -0.1 -to i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_ts_pd/i_rbct/i_rbc_rst_ts_pd_i_m_syncffr_rst_n_tsem_track_i_resync_cell/R]
#picks up all subtypes:
#set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -start_end_pair -slack_less -0.1]
#set paths [gtp -group $clock -start_end_pair -slack_less -0.1]

set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -max_paths 10000 -slack_less -0.0]

set global_skew 0.3
set mm_per_ns 2.7
set flight_penalty 1.0

array unset corrected_slack_of
array unset slack_of

#set pathsfile credit_paths.rpt
set pnum 1
#file delete -force $pathsfile
foreach_in_collection path $paths {
  set pg [get_object_name [get_attribute $path path_group]]
  set save_path $path
  set t [lindex [get_period $path] 0]
  set keep_path $path
  set travel [expr double([lindex [path_travel $path] 0])/1000.0]
  set skew [skew_of $path]

  set sp [get_object_name [get_attribute $path startpoint]]
  #set sphier [hier_of $sp]

  set ep [get_object_name [get_attribute $path endpoint]]
  #set ephier [hier_of $ep]
  set epc [get_cells -of [get_pins $ep]]
  set epo [get_pins -of $epc -filter "direction==out && defined(max_slack)"]
  set mineposlack [get_attribute [gtp -thro $epo] slack]

  set slack [get_attribute $path slack]
  set corrected_slack [expr $slack - $skew - $global_skew]
  if {$t == "UNKNOWN"} {
    set t 0.0
  }
  set max_travel [expr $mm_per_ns * $flight_penalty * $t]
  #set keep_path $path
  if {[regexp clock_gating_default $pg]} {
    set note "GATER- MOVE UPSTREAM PATH"
  } elseif {$mineposlack > [expr abs($slack)] } {
    set note "USEFUL SKEW_FIX- (PUSH ENDPT)"
  } elseif {$travel > $max_travel} {
    set note "TOO_FAR- PIPELINE (TRAVEL=$travel/$max_travel)"
  } else {
    set note "BAD_DATA PATH? (TRAVEL=$travel/$max_travel)"
  }
  set str "$slack,$note,$sp,$ep,$skew,$t,$travel,$corrected_slack"
  set corrected_slack_of($str) $corrected_slack
  set slack_of($str) $slack
  incr pnum 1

}

proc by_slack {A B} {
  upvar slack_of slack_of
  if {$slack_of($A) > $slack_of($B)} { return 1 } else { return -1 }
}

proc by_corr_slack {A B} {
  upvar corrected_slack_of corrected_slack_of
  if {$corrected_slack_of($A) > $corrected_slack_of($B)} { return 1 } else { return -1 }
}

#set v [get_top_version]
set v {}

set fout [open categorized_paths_${clkfile}_${v}_${run_type_specific}.csv w]
puts $fout "SLACK,NOTE,STARTPOINT,ENDPOINT,SKEW,PERIOD,TRAVEL,SKEW_CORRECTED_SLACK"
foreach el [lsort -command by_slack [array names corrected_slack_of]] {
  puts $fout $el
}
close $fout
