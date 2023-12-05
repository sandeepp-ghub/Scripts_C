foreach to_remove {
  i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_logic_inst
  i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_pads_inst
  i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_logic_inst
} {
  set rindex [lsearch -exact $refkeys $to_remove]
  if {$rindex > -1} {
    set refkeys [lreplace $refkeys $rindex $rindex]
  }
}
set fout [open interblock_by_path_[get_top_version].csv w]
puts $fout "SLACK,SKEW,SKEW_ADJUSTED_SLACK,ENDPT,HPIN_CHAIN,HIER_CHAIN"
set paths [gtp -max_paths 10000 -from [get_clocks clk_pll_main] -to [get_clocks clk_pll_main]]
#set paths [gtp -to i_ecore/i_nm/i_nw_pd/i_nwm/i_rce_4ch_eth_chan_i_pcs_chan_wrap_core_i1_pcs_chan_core_i1_pcs_chan_rx_inst_fec_rx_wrap_inst_fec_100g_rs_decoder_4ch_fec_100g_rs_decoder_4ch_inst_rs_berlekamp_massey_decoder_4ch_i2_t_x_poly_reg_0__rs_reg_ctrl__15__5__i_rce_4ch_eth_chan_i_pcs_chan_wrap_core_i1_pcs_chan_core_i1_pcs_chan_rx_inst_fec_rx_wrap_inst_fec_100g_rs_decoder_4ch_fec_100g_rs_decoder_4ch_inst_rs_berlekamp_massey_decoder_4ch_i2_t_x_poly_reg_0__rs_reg_ctrl__15__2_/D1]
array unset count_of
foreach_in_collection path $paths {
  set last_hier NONE
  set hier NONE
  set hier_chain {}
  set hpin_chain {}
  foreach_in_collection pt [get_attribute $path points] {
    set obj [get_attribute $pt object]
    set ishier [get_attribute $obj is_hierarchical]
    if {$ishier} {
      set last_hier $hier
      set hier [hier_of $obj]
      regsub -all {\/} $hier {.} hier
      if {$hier != $last_hier} {
        if {$hier_chain == ""} {
          set hier_chain $hier
        } else {
          set hier_chain "$hier_chain:$hier"
        }
        if {$hier != "top"} {
          set hpinn [get_object_name $obj]
          if {$hpin_chain == ""} {
            set hpin_chain $hpinn
          } else {
            set hpin_chain "$hpin_chain:$hpinn"
          }
        }
      }
    }
  }
  set ep [get_attribute $path endpoint]
  if {$hier_chain== ""} {
    set hier_chain INTRA:[hier_of $ep]
    regsub -all {\/} $hier {.} hier
  }
  set slack [get_attribute $path slack]
  set skew  [skew_of $path]
  if {[regexp {^INTRA:} $hier_chain]} {
    set skew 0.0
  }
  set zero_skew_slack [expr $slack - $skew]
  puts $fout "$slack,$skew,$zero_skew_slack,[get_object_name $ep],$hpin_chain,$hier_chain"
  if {![info exists count_of($hier_chain)]} {
    set count_of($hier_chain) 1
  } else {
    incr count_of($hier_chain) 1
  }
}
close $fout

proc by_count {A B} {
  upvar count_of count_of
  if {$count_of($A) < $count_of($B)} {
    return 1
  } else {
    return -1
  }
}

set fout [open interblock_summary_[get_top_version].csv w]
puts $fout "COUNT,CHAIN"
foreach chain [lsort -command by_count [array names count_of]] {
  puts $fout "$count_of($chain),$chain"
}
close $fout
