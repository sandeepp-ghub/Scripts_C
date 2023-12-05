#foreach to_remove {
#  i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_logic_inst
#  i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_pads_inst
#  i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_logic_inst
#} {
#  set rindex [lsearch -exact $refkeys $to_remove]
#  if {$rindex > -1} {
#    set refkeys [lreplace $refkeys $rindex $rindex]
#  }
#}

proc overall_latency {CLOCK} {
  upvar refkeys refkeys
  upvar pnr_blks pnr_blks
  upvar grout_partitions grout_partitions
  upvar TOP TOP
  redirect -variable text {report_clock_timing -clock $CLOCK -launch -type latency -nworst 10000000 -nosplit}
  #redirect -variable text {report_clock_timing -clock $CLOCK -launch -type latency -nworst 100 -nosplit}
  foreach line [split $text "\n"] {
    if {[regexp {(\S+)\s+(\S+)\s+([0-9]+\.[0-9]+)\s+([0-9]+\.[0-9]+)\s+([0-9]+\.[0-9]+)\s+(\S+)} $line match name tran source lat total edge]} {
      set hier [hier_of [get_pins $name]]
      #puts "$hier $total"
      if {![info exists total_of($hier)]} { set total_of($hier) $total } else { set total_of($hier) [expr $total_of($hier) + $total] }
      if {![info exists total_of(TOTAL)]} { set total_of(TOTAL) $total } else { set total_of(TOTAL) [expr $total_of(TOTAL) + $total] }
      if {![info exists count_of($hier)]} { set count_of($hier) 1      } else { incr count_of($hier) 1 }
      if {![info exists count_of(TOTAL)]} { set count_of(TOTAL) 1      } else { incr count_of(TOTAL) 1 }
    } else {
      #puts "NOT RECOGNIZED: $line"
    }
  }
  #i_ecore/i_nm/i_nm_pd_e0/i_nig/i_nig_rt/i_nig_lb_LB_PORT_INST_3__i_nig_lb_port/i_out_metadata_d1_out_reg_29__i_out_metadata_d1_out_reg_26_/CK 0.0588 0.0000 3.1584 3.1584 rp-+
  foreach hier [array names count_of] {
    set avg_of($hier) [format "%0.2f" [expr $total_of($hier)/double($count_of($hier))]]
  }
  proc by_avg {A B} {
    upvar avg_of avg_of
    if {$avg_of($B) < $avg_of($A)} { return 1 } else { return -1 }
  }

  regsub -all {/} $CLOCK {_} cfilename
  set fout [open overall_latency_${cfilename}_[get_top_version].rpt w]
  puts $fout "AVG_LAT,HIERARCHY,SAMPLES"
  foreach hier [lsort -command by_avg [array names count_of]] {
    puts $fout "$avg_of($hier),$hier,$count_of($hier)"
  }
  close $fout

  set fout [open latency_adjustments_${cfilename}_[get_top_version].ptanno w]
  foreach hier [lsort -command by_avg [array names count_of]] {
    if {$hier != "top" && $hier != "TOTAL"} {
      set cell [get_cells $hier]
      set pins [get_pins -of $cell -filter "direction==in"]
      foreach_in_collection pin $pins {
        set driver [get_pins -quiet -leaf -of [get_nets -quiet -of $pin] -filter "direction==out"]
        set loads  [get_pins -quiet -leaf -of [get_nets -quiet -of $pin] -filter "direction==in"]
        set drivername [get_object_name $driver]
        set to_apply [expr $avg_of(TOTAL) - $avg_of($hier)]
        foreach_in_collection load $loads {
          if {[lsearch -exact [get_object_name [get_attribute -quiet $load clocks]] $CLOCK] > -1} {
            puts $fout "set_annotated_delay $to_apply -net -from $drivername -to [get_object_name $load] -incr ; # THROUGH PIN: [get_object_name $pin]"
          }
        }
      }
    }
  }
  close $fout
}

overall_latency clk_pll_main
overall_latency clk_tck
overall_latency clk_pll_storm
overall_latency clk_st_div2
overall_latency clk_cam_vfc
overall_latency clk_sclk_pem
overall_latency gen_clk_i_pcie_phy_top/gsern/qlm3/lane0/wrap/svc_clk
overall_latency clk_svc
overall_latency pcie16_gen_clk_i_pcie_phy_top/gsern/qlm3/lane0/_fr_qlm0/lane0_wrap/txdivclkx16
overall_latency pcie16_gen_clk_i_pcie_phy_top/gsern/qlm3/lane0/_fr_qlm2/lane0_wrap/txdivclkx8
overall_latency pcie16_gen_clk_i_pcie_phy_top/gsern/qlm3/lane0/_fr_qlm3/lane0_wrap/txdivclkx1
overall_latency pcie16_gen_clk_i_pcie_phy_top/gsern/qlm3/lane0/_fr_qlm3/lane0_wrap/txdivclkx2
overall_latency pcie16_gen_clk_i_pcie_phy_top/gsern/qlm3/lane0/_fr_qlm3/lane0_wrap/txdivclkx4
overall_latency pcie16_gen_clk_i_pcie_phy_top/gsern/qlm0/lane0/wrap/txdivclkx1

