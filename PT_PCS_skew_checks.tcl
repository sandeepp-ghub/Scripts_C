set interface_skew 0.0
set pma_skew_value 0.0

proc afe_clk_txdata_pins_of_clock {CLOCK} {
  upvar clock_of_afe_clk_txdata_pin clock_of_afe_clk_txdata_pin
  set findclocks [get_object_name [get_clocks $CLOCK]]
  set result [add_to_collection {} {}]
  set all_clk_pins [get_pins -hier */afe_ln?_clk_txdata_i]
  foreach_in_collection clkpin $all_clk_pins {
    set clocks [get_object_name [get_attribute $clkpin clocks]]
    set addme 0
    foreach clkpat $findclocks {
      if {[lsearch -exact $clocks $clkpat] > -1} {
        set addme 1
        set clock_of_afe_clk_txdata_pin([get_object_name $clkpin]) $clkpat
      }
    }
    if {$addme} {
      append_to_collection result $clkpin
    }
  }
  return [sort_collection $result full_name]
}

set fout [open data_checks_${TOP}_${run_type_specific}.pt w]

foreach clock {
PIPE4_pma0_PCS_CLK_RATE2DIV_DIV2__PIPE0_CLK_TX

PIPE4_pma0_PCS_CLK_RATE1_DIV1__PIPE0_PCLK_LNx_i

PIPE16_pma0_PCS_CLK_RATE2DIV_DIV2__PIPE2_CLK_TX
PIPE16_pma1_PCS_CLK_RATE2DIV_DIV2__PIPE0_CLK_TX
PIPE16_pma2_PCS_CLK_RATE2DIV_DIV2__PIPE1_CLK_TX
PIPE16_pma3_PCS_CLK_RATE2DIV_DIV2__PIPE3_CLK_TX

PIPE16_pma0_PCS_CLK_RATE1_DIV1__PIPE2_PCLK_LNx_i
PIPE16_pma1_PCS_CLK_RATE1_DIV1__PIPE0_PCLK_LNx_i
PIPE16_pma2_PCS_CLK_RATE1_DIV1__PIPE1_PCLK_LNx_i
PIPE16_pma3_PCS_CLK_RATE1_DIV1__PIPE3_PCLK_LNx_i

} {
  if {[sizeof_collection [get_clocks -quiet $clock]] > 0} {
    set all_dchk_pins [afe_clk_txdata_pins_of_clock $clock]
    puts $fout "#CHECKS FOR $clock :"
    puts $fout "# CLOCK $clock checks ([sizeof_collection $all_dchk_pins] pins):"
    foreach_in_collection pin $all_dchk_pins {
      set cell_of_pin [get_object_name [get_cells -of $pin]]
      set other_dchk_pins [sort_collection [remove_from_collection $all_dchk_pins $pin] full_name]
      foreach_in_collection opin $other_dchk_pins {
        set cell_of_opin [get_object_name [get_cells -of $opin]]
        if {$cell_of_opin == $cell_of_pin} {
          puts $fout "set_data_check [expr -1.0 * $pma_skew_value] -setup -rise_from [get_object_name $pin] -rise_to [get_object_name $opin] -clock $clock_of_afe_clk_txdata_pin([get_object_name $opin]) ; # SAME PMA"
        } else {
          puts $fout "set_data_check [expr -1.0 * $interface_skew] -setup -rise_from [get_object_name $pin] -rise_to [get_object_name $opin] -clock $clock_of_afe_clk_txdata_pin([get_object_name $opin]) ; # DIFFERENT PMA"
        }
      }
    }
  }
}

close $fout
