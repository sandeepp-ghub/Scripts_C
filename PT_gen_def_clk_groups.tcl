proc gen_default_clock_group {REMAPS} {
  upvar group_name_of_master group_name_of_master
  #gser_rx_clk_dcc_shift90 gser_rx_clk_dcc
  array unset master_of
  redirect -variable master_info {report_clock_hierarchy}
  foreach line [split $master_info "\n"] {
    if {[regexp {^.*\+-(\S+)} $line match clock]} {
      set master_of($clock) $master
      lappend gen_clocks_of($master) $clock
    } elseif {[regexp {^\s*$} $line]} {
      #puts "EMPTY: $line"
    } else {
      set new_master $line
      foreach {frompat topat} $REMAPS {
        regsub $frompat $new_master $topat new_master
      }
      if {$new_master != $line} {
        puts "INFO: REMAPPING MASTER: $line -> $new_master"
        set master $new_master
        lappend gen_clocks_of($master) $line
      } else {
        set master $line
        set master_of($line) $line
        set seen_master($line) $line
      }
    }
  }

  set fn default_clock_group.pt
  set f2 cn_pt_set_clock_groups.pt
  #set fout [open $fn w]
  set fo2  [open $f2 w]
  set csv [open root_master_info.csv w]
  puts $csv "CLOCK,SOURCE(S),ROOT_MASTER_CLOCK,NOTES"
  #puts $fout "set_clock_groups -asynchronous -name DEFAULT \\"
  set i 0
  foreach mclk [lsort [array names seen_master]] {
    if {![info exists group_name_of_master($mclk)]} {
      puts "WARNING: Autonaming $mclk ... group"
      set groupsname M$i
	  set groupsname ${mclk}_MASTER
      incr i 1
    } else {
      set groupsname $group_name_of_master($mclk)
    }
    puts $fo2 "\n# MASTER CLOCK: $mclk"
    set src [get_object_name [get_attribute [get_clocks $mclk] sources]]
    puts $csv "$mclk,$src,$mclk,ROOT"
    if {[info exists gen_clocks_of($mclk)]} {
      #puts $fout "  -group \[list $mclk \\"
      puts $fo2  "cn_pt_set_clock_groups -type async -name TOP -group_name $groupsname -clocks \[list $mclk\] ; # Master Clock"
      foreach gclk [lsort $gen_clocks_of($mclk)] {
        #puts $fout "               $gclk \\"
        puts $fo2  "cn_pt_set_clock_groups -type async -name TOP -group_name $groupsname -clocks \[list $gclk\]"
        set src [get_object_name [get_attribute [get_clocks $gclk] sources]]
        puts $csv "$gclk,$src,$mclk,"
      }
      #puts $fout "         \]"
    } else {
      #puts $fout "  -group $mclk \\"
      puts $fo2  "cn_pt_set_clock_groups -type async -name TOP -group_name $groupsname -clocks \[list $mclk\] ; # A lone clock"
    }
  }
  #close $fout
  close $fo2
  #source $fn
  close $csv
}

array unset group_name_of_master
set group_name_of_master(bts_clk) BTS_CLK
foreach qlm {0 1} {
  set group_name_of_master(gser__gsern/qlm${qlm}/com/gser_com_gser_fbclk) GSER_Q${qlm}_COM_FBCLK
  set group_name_of_master(gser__gsern/qlm${qlm}/com/gser_pll_ref_clk) GSER_Q${qlm}_COM_PLL_REF_CLK
  set group_name_of_master(gser__gsern/qlm${qlm}/com/gser_refc_clk) GSER_Q${qlm}_COM_REFC_CLK
  foreach lane {0 1 2 3} {
    set group_name_of_master(eth25_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)       ROC_ETH25_RX_Q${qlm}_L${lane}
    set group_name_of_master(eth25_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)       ROC_ETH25_TX_Q${qlm}_L${lane}
    set group_name_of_master(sgmii2p5_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)    ROC_SGMII2P5_RX_Q${qlm}_L${lane}
    set group_name_of_master(sgmii2p5_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)    ROC_SGMII2P5_TX_Q${qlm}_L${lane}
    set group_name_of_master(sata6_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)       ROC_SATA6_RX_Q${qlm}_L${lane}
    set group_name_of_master(sata6_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)       ROC_SATA6_TX_Q${qlm}_L${lane}
    set group_name_of_master(pcie16_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)      ROC_PCIE16_RX_Q${qlm}_L${lane}
    set group_name_of_master(pcie16_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)      ROC_PCIE16_TX_Q${qlm}_L${lane}
    set group_name_of_master(gser__gsern/qlm${qlm}/lane${lane}/gser_fbclk)                  ROC_GSER_Q${qlm}_L${lane}_FBCLK
  }
}

set group_name_of_master(pi_bts_bfn_clk) PI_BTS_BFN_CLK
set group_name_of_master(pi_bts_extref0_clk) PI_BTS_EXTREF0_CLK
set group_name_of_master(pi_bts_extref1_clk) PI_BTS_EXTREF1_CLK
set group_name_of_master(pi_bts_extref2_clk) PI_BTS_EXTREF2_CLK
set group_name_of_master(pi_ejtck) PI_EJTCK
set group_name_of_master(pi_ncsi_ref_clk) PI_NCSI_REF_CLK
set group_name_of_master(pi_refclk) PI_REFCLK
set group_name_of_master(pi_tck) PI_TCK
set group_name_of_master(pulse_osc_clk) PULSE_OSC_CLK
set group_name_of_master(rclk_clu0) RCLK
set group_name_of_master(rclk_early) RCLK
set group_name_of_master(rclk_iobn0) RCLK
set group_name_of_master(sclk) SCLK
#NEW FOR GSERR
set group_name_of_master(cpu_clk) CPU_CLK

#RUN IT!
gen_default_clock_group {gser_rx_clk_dcc_shift90 gser_rx_clk_dcc}
