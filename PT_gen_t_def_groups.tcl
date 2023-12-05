
set merge_masters_pairs {
  rclk_clu1 rclk_clu0
  rclk_clu2 rclk_clu0
  rclk_iobn0 rclk_clu0
  rclk_iobn1 rclk_clu0
  rclk_iobn2 rclk_clu0  
  uphy0_CLK480M uphy0_pll_480m_clk
  uphy0_RX0M_clk uphy0_RESREF_clk
  uphy1_CLK480M uphy1_pll_480m_clk
  uphy1_RX0M_clk uphy1_RESREF_clk
  rxp_clk1 rxp_clk0
  rxp_clk_pll rxp_clk0
}

cn_pt_create_default_clock_groups -merge_masters $merge_masters_pairs

set fout [open cn_pt_set_clock_groups.pt a]
puts $fout {
# Added clock groups (non-TOP) originally authored by Deb Dyson
# uphy0_RESREF_vs_RX0M is devoted to making it so uphy0_RESREF_clk will be asyncronous with uphy0_RX0M_clk (ignoring roc/uphy0__uphy/phy/sspx1_rx0_ana_word_clk and roc/uphy0__uphy/phy/sspx1_rx0_out_clk)
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list uphy0_RESREF_clk] ; # Master Clock
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list roc/uphy0__uphy/phy/sspx1_mpll_ana_dword_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list roc/uphy0__uphy/phy/sspx1_mpll_ana_qword_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list roc/uphy0__uphy/phy/sspx1_mpll_ana_refssc_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list roc/uphy0__uphy/phy/sspx1_mpll_ana_word_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list roc/uphy0__uphy/phy/sspx1_tx0_out_word_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list usbdrd0_rx_pclk_pipe3_0]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list usbdrd0_tx_pclk_pipe3_0]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list gen_div2_rx0_pclk_pipe3_0]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list gen_div4_rx0_pclk_pipe3_0]
#roc level copies:
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list uphy0__uphy/phy/sspx1_mpll_ana_dword_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list uphy0__uphy/phy/sspx1_mpll_ana_qword_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list uphy0__uphy/phy/sspx1_mpll_ana_refssc_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list uphy0__uphy/phy/sspx1_mpll_ana_word_clk]
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RESREF_clk_MASTER -clocks [list uphy0__uphy/phy/sspx1_tx0_out_word_clk]

cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RX0M_clk_MASTER -clocks [list uphy0_RX0M_clk] ; # Master Clock
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RX0M_clk_MASTER -clocks [list roc/uphy0__uphy/phy/RX0CLK]
#roc level copy:
cn_pt_set_clock_groups -type async -name uphy0_RESREF_vs_RX0M -group_name uphy0_RX0M_clk_MASTER -clocks [list uphy0__uphy/phy/RX0CLK]


# uphy1_RESREF_vs_RX0M is devoted to making it so uphy1_RESREF_clk will be asyncronous with uphy1_RX0M_clk (ignoring roc/uphy1__uphy/phy/sspx1_rx0_ana_word_clk and roc/uphy1__uphy/phy/sspx1_rx0_out_clk)
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list uphy1_RESREF_clk] ; # Master Clock
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list roc/uphy1__uphy/phy/sspx1_mpll_ana_dword_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list roc/uphy1__uphy/phy/sspx1_mpll_ana_qword_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list roc/uphy1__uphy/phy/sspx1_mpll_ana_refssc_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list roc/uphy1__uphy/phy/sspx1_mpll_ana_word_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list roc/uphy1__uphy/phy/sspx1_tx0_out_word_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list usbdrd1_rx_pclk_pipe3_0]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list usbdrd1_tx_pclk_pipe3_0]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list gen_div2_rx1_pclk_pipe3_0]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list gen_div4_rx1_pclk_pipe3_0]
#roc level copies:
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list uphy1__uphy/phy/sspx1_mpll_ana_dword_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list uphy1__uphy/phy/sspx1_mpll_ana_qword_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list uphy1__uphy/phy/sspx1_mpll_ana_refssc_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list uphy1__uphy/phy/sspx1_mpll_ana_word_clk]
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RESREF_clk_MASTER -clocks [list uphy1__uphy/phy/sspx1_tx0_out_word_clk]

cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RX0M_clk_MASTER -clocks [list uphy1_RX0M_clk] ; # Master Clock
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RX0M_clk_MASTER -clocks [list roc/uphy1__uphy/phy/RX0CLK]
#roc level copy:
cn_pt_set_clock_groups -type async -name uphy1_RESREF_vs_RX0M -group_name uphy1_RX0M_clk_MASTER -clocks [list uphy1__uphy/phy/RX0CLK]

}
close $fout

#ALL THE REST IS JUST FOR FILTERING OUT RAMBUS GSER*
set fin [open cn_pt_set_clock_groups.pt r]
set fout [open cn_pt_set_clock_groups.pt.new w]
set in 0
while {[gets $fin line] >= 0} {
  if {[regexp {(GSERR|PCIE)} $line] && ![regexp {cpu_clk} $line]} {
    set in 1
  } elseif {[regexp {\S+} $line] && ![regexp {(GSERR|PCIE)} $line]} {
    set in 0
  }
  if {!$in} {
    puts $fout $line
  }
}
close $fin
close $fout
set newname0 roc_cn_set_clock_groups.pt.new
set newname physconf/t98_1.0/timing/block_cfgs/roc/roc_cn_set_clock_groups.pt.new
set oldname physconf/t98_1.0/timing/block_cfgs/roc/roc_cn_set_clock_groups.pt
set oldcp   roc_cn_set_clock_groups.pt.old
puts "Copying to $newname"
file copy -force cn_pt_set_clock_groups.pt.new $newname0
file copy -force cn_pt_set_clock_groups.pt.new $newname
file copy -force $oldname $oldcp
puts "DONE!"
puts "TRY: cd physconf/t98_1.0/timing/block_cfgs/roc"
