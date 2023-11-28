# Re -open ULVT.
set dont_dont_use_list {*/*ULVTLL */*ULVT}
set_dont_use [get_lib_cells $dont_dont_use_list] false
set_dont_touch [get_cells -of  [get_lib_cells $dont_dont_use_list]] false 

# Set dont use list.
set dont_use_list {*/*DCCK* */CK* */*INV*D1BWP* */*DEL*  \
                  */*D18* */*D20* */*D24* */*D26* */*D28* */*D30* */*D32* */*D34* */*D36* */G* */BUFFSKFD* */BUFFSKFKAD* \
                 */BUFFSKRD* */BUFFSKRKAD* */BUFTD* */CK* */DCCK* */*MB6* \
                 */MB8* */MRVL* */*LVL* */*ELVT}

set_dont_use [get_lib_cells $dont_use_list]
set_dont_touch [get_cells -of  [get_lib_cells $dont_use_list]]


# Re -open DEL.
set dont_dont_use_list {*/*DEL*}
set_dont_use [get_lib_cells $dont_dont_use_list] false
set_dont_touch [get_cells -of  [get_lib_cells $dont_dont_use_list]] false 




# hold buffer list.
#set hold_buf {*/DEL* */BUFFD1B* */BUFFD2B* */BUFFD3B* */BUFFD4B*}

#fix_eco_timing -group {} -type setup

set hold_buf [list DELAD1BWP210H6P51CNODLVT DELBD1BWP210H6P51CNODLVT DELCD1BWP210H6P51CNODLVT DELDD1BWP210H6P51CNODLVT DELED1BWP210H6P51CNODLVT DELFD1BWP210H6P51CNODLVT DELGD1BWP210H6P51CNODLVT DELAD1BWP210H6P51CNODLVTLL DELBD1BWP210H6P51CNODLVTLL DELCD1BWP210H6P51CNODLVTLL DELDD1BWP210H6P51CNODLVTLL DELED1BWP210H6P51CNODLVTLL DELFD1BWP210H6P51CNODLVTLL DELGD1BWP210H6P51CNODLVTLL DELAD1BWP210H6P51CNODULVT DELBD1BWP210H6P51CNODULVT DELCD1BWP210H6P51CNODULVT DELDD1BWP210H6P51CNODULVT DELED1BWP210H6P51CNODULVT DELFD1BWP210H6P51CNODULVT DELGD1BWP210H6P51CNODULVT DELAD1BWP210H6P51CNODULVTLL DELBD1BWP210H6P51CNODULVTLL DELCD1BWP210H6P51CNODULVTLL DELDD1BWP210H6P51CNODULVTLL DELED1BWP210H6P51CNODULVTLL DELFD1BWP210H6P51CNODULVTLL DELGD1BWP210H6P51CNODULVTLL BUFFD1BWP210H6P51CNODLVT BUFFD1BWP210H6P51CNODLVTLL BUFFD1BWP210H6P51CNODULVT BUFFD1BWP210H6P51CNODULVTLL BUFFD2BWP210H6P51CNODLVT BUFFD2BWP210H6P51CNODLVTLL BUFFD2BWP210H6P51CNODULVT BUFFD2BWP210H6P51CNODULVTLL BUFFD3BWP210H6P51CNODLVT BUFFD3BWP210H6P51CNODLVTLL BUFFD3BWP210H6P51CNODULVT BUFFD3BWP210H6P51CNODULVTLL BUFFD4BWP210H6P51CNODLVT BUFFD4BWP210H6P51CNODLVTLL BUFFD4BWP210H6P51CNODULVT BUFFD4BWP210H6P51CNODULVTLL]
set hold_buf [list DELAD1BWP210H6P51CNODLVT DELBD1BWP210H6P51CNODLVT DELCD1BWP210H6P51CNODLVT DELDD1BWP210H6P51CNODLVT DELED1BWP210H6P51CNODLVT DELFD1BWP210H6P51CNODLVT DELGD1BWP210H6P51CNODLVT DELAD1BWP210H6P51CNODULVT DELBD1BWP210H6P51CNODULVT DELCD1BWP210H6P51CNODULVT DELDD1BWP210H6P51CNODULVT DELED1BWP210H6P51CNODULVT DELFD1BWP210H6P51CNODULVT DELGD1BWP210H6P51CNODULVT DELAD1BWP210H6P51CNODULVTLL DELBD1BWP210H6P51CNODULVTLL DELCD1BWP210H6P51CNODULVTLL DELDD1BWP210H6P51CNODULVTLL DELED1BWP210H6P51CNODULVTLL DELFD1BWP210H6P51CNODULVTLL DELGD1BWP210H6P51CNODULVTLL BUFFD1BWP210H6P51CNODLVT BUFFD1BWP210H6P51CNODLVTLL BUFFD1BWP210H6P51CNODULVT BUFFD1BWP210H6P51CNODULVTLL BUFFD2BWP210H6P51CNODLVT BUFFD2BWP210H6P51CNODLVTLL BUFFD2BWP210H6P51CNODULVT BUFFD2BWP210H6P51CNODULVTLL BUFFD3BWP210H6P51CNODLVT BUFFD3BWP210H6P51CNODLVTLL BUFFD3BWP210H6P51CNODULVT BUFFD3BWP210H6P51CNODULVTLL BUFFD4BWP210H6P51CNODLVT BUFFD4BWP210H6P51CNODLVTLL BUFFD4BWP210H6P51CNODULVT BUFFD4BWP210H6P51CNODULVTLL]
fix_eco_timing -group {dwc_ddrphy_pnr_block_INTERNAL_*core*_*phy_ref* dwc_phy_ref_clk_ddr4t dwc_ddrphy_pnr_block_INTERNAL_*phy_ref*_*phy_ref*} -type hold -methods insert_buffer -buffer_list $hold_buf
#remote_execute {source /user/lioral/scripts/DDR/avis_dont_touch_nets.tcl  } -verbose
#remote_execute {source /user/lioral/scripts/DDR/set_dont_use1.tcl} -verbose
#remote_execute {source /user/lioral/scripts/DDR/set_dont_use2.tcl} -verbose
source /user/lioral/scripts/DDR/write_eco_files.tcl
#fix_eco_timing -group {} -type setup
set eco_instance_name_prefix PT_ECO_0225_inst
set eco_net_name_prefix PT_ECO_0225_net



  set save_scenarios [current_scenario]
  current_scenario [index_collection $save_scenarios 0]
  set_distributed_variables pteco_physical_mode
  remote {
    if {$pteco_physical_mode == "none"} {
      write_changes -output ../../changes.pteco
    } else {
      file mkdir ../../eco_split
      if {![info exists pteco_alt_phys_eco_format]} { set pteco_alt_phys_eco_format icc2 }
      write_changes -format icc2 -output ../../eco_split/phys.icc2eco
      write_changes -format eco  -output ../../eco_split/phys.eco
      write_changes -format aprtcl -output ../../eco_split/apr.eco
    }
  }
  current_scenario $save_scenarios

  #Dump if !$PT_PNR_BLOCK_LEVEL_RUN
  remote { if {![info exists PT_PNR_BLOCK_LEVEL_RUN]} { set PT_PNR_BLOCK_LEVEL_RUN false } }
  unset -nocomplain PT_PNR_BLOCK_LEVEL_RUN
  get_distributed_variables -merge_type unique_list PT_PNR_BLOCK_LEVEL_RUN

  #Split the eco only if it's a partition:
  #if {!$PT_PNR_BLOCK_LEVEL_RUN} { cn_split_eco }
  cn_split_eco


  source /user/avalent/dmc/HS_ENV/dev_cui/hs_procs.tcl

  set pg [list **async_default** **clock_gating_default** **default** AC_TIMING_IN AC_TIMING_OUT INPUT IO OUTPUT SNPS_MAX_DELAY UcClk_ddr4 UcClk_ddr4t UcClk_ddr5 UcClk_ddr5t bs_tck_halfspeed ddrphy_TO_dmc_ch0 ddrphy_TO_dmc_ch1 ddrphy_TO_dss_dch_top dmc0_apb_clk_ddr4 dmc0_apb_clk_ddr4t dmc0_apb_clk_ddr5 dmc0_apb_clk_ddr5t dmc0_mc_core_clk_ddr4 dmc0_mc_core_clk_ddr4t dmc0_mc_core_clk_ddr5 dmc0_mc_core_clk_ddr5t dmc0_mct_clk_ddr4 dmc0_mct_clk_ddr4t dmc0_mct_clk_ddr5 dmc0_mct_clk_ddr5t dmc0_phy_ref_clk_ddr4 dmc0_phy_ref_clk_ddr4t dmc0_phy_ref_clk_ddr5 dmc0_phy_ref_clk_ddr5t dmc0_pll_div2_clk_ddr4 dmc0_pll_div2_clk_ddr4t dmc0_pll_div2_clk_ddr5 dmc0_pll_div2_clk_ddr5t dmc1_apb_clk_ddr4 dmc1_apb_clk_ddr4t dmc1_apb_clk_ddr5 dmc1_apb_clk_ddr5t dmc1_mc_core_clk_ddr4 dmc1_mc_core_clk_ddr4t dmc1_mc_core_clk_ddr5 dmc1_mc_core_clk_ddr5t dmc1_mct_clk_ddr4 dmc1_mct_clk_ddr4t dmc1_mct_clk_ddr5 dmc1_mct_clk_ddr5t dmc1_phy_ref_clk_ddr4 dmc1_phy_ref_clk_ddr4t dmc1_phy_ref_clk_ddr5 dmc1_phy_ref_clk_ddr5t dmc1_pll_div2_clk_ddr4 dmc1_pll_div2_clk_ddr4t dmc1_pll_div2_clk_ddr5 dmc1_pll_div2_clk_ddr5t dmc_ch0_INTERNAL dmc_ch0_TO_ddrphy dmc_ch0_TO_dss_dch_top dmc_ch1_INTERNAL dmc_ch1_TO_ddrphy dmc_ch1_TO_dss_dch_top dss_dch_top_INTERNAL dss_dch_top_TO_ddrphy dss_dch_top_TO_dmc_ch0 dss_dch_top_TO_dmc_ch1 dwc_apb_clk_ddr4 dwc_apb_clk_ddr4t dwc_apb_clk_ddr5 dwc_apb_clk_ddr5t dwc_ddrphy_pnr_block_INTERNAL dwc_mc_core_clk_ddr4 dwc_mc_core_clk_ddr4t dwc_mc_core_clk_ddr5 dwc_mc_core_clk_ddr5t dwc_mct_clk_ddr4 dwc_mct_clk_ddr4t dwc_mct_clk_ddr5 dwc_mct_clk_ddr5t dwc_phy_ref_clk_ddr4 dwc_phy_ref_clk_ddr4t dwc_phy_ref_clk_ddr5 dwc_phy_ref_clk_ddr5t dwc_pll_div2_clk_ddr4 dwc_pll_div2_clk_ddr4t dwc_pll_div2_clk_ddr5 dwc_pll_div2_clk_ddr5t pi_refclk pi_tck pi_tck_gen pll_mem_clk_ddr4 pll_mem_clk_ddr4t pll_mem_clk_ddr5 pll_mem_clk_ddr5t pll_ref rclk sclk]
  foreach pg $pgs {

  }
