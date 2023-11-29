set clocks_input {
dch_clk
pll__ref_ch*
rclk_ch*
refclk_ch*
top__dch_tck
top__dch__jtag_bs_tck
}

set analog_inputs {
APLL_AVDD
AVDD
}

set inputs {
dss_fo_oen_r*[*]
dss_fo_so_r*[*]
jtg__dch_hub_ctrl_bits[*]
jtg__dch_hub_latch_en[*]
jtg__dch_hub_scan_ctl[*]
jtg__hub_scan_ctl_latch[*]
msh__dss_dat_ch*[*]
msh__dss_dat_lcrdv_ch*[*]
msh__dss_linkactiveack_ch*
msh__dss_linkactivereq_ch*
msh__dss_req_ch*[*]
msh__dss_rsp_lcrdv_ch*[*]
msh__dss_sactive_ch*
pad__hub_scan_cmp_in[*]
pcl__dch_so_uncomp_r*
pcl__dss_clkdiv_rst_n_ch*
pcl__dss_early_rst_n_ch*
pcl__dss_fuse_serial_ch*[*]
pcl__dss_gib_grant_ch*
pcl__dss_hub_scan_cmp_out[*]
pcl__dss_mdc_sdi_ch*
pcl__dss_pcc_data_ch*[*]
pcl__dss_pll_dcok_ch*
pcl__dss_pll_intf_ch*[*]
pcl__dss_rml_ch*[*]
pcl__dss_rsh_drstate_ch*[*]
pcl__dss_rsh_grstate_ch*[*]
pcl__dss_so_r*[*]
tie__hub_state_bits[*]
top__dch_jtag_bsr_ctl[*]
top__dch_jtag_lobe_bsi
top__dch_jtg_en[*]
top__dch_jtg_si
top__dch_si_uncomp_r*
top__dch_tdr_ctl[*]
top__dss_pcl_si[*]
top__dss_si[*]
}





set analog_outputs {
DDR_RESET_L
}

set outputs {
dch__pcl_si_uncomp_r*
dch__top_jtag_lobe_bso
dch__top_jtg_so[*]
dch__top_so_uncomp_r*
dss__msh_dat_ch*[*]
dss__msh_dat_lcrdv_ch*
dss__msh_linkactiveack_ch*
dss__msh_linkactivereq_ch*
dss__msh_req_lcrdv_ch*
dss__msh_rsp_ch*[*]
dss__msh_sactive_ch*
dss__pcl_gib_data_ch*[*]
dss__pcl_gib_req_ch*
dss__pcl_hub_ctrl_bits[*]
dss__pcl_hub_scan_cmp_in[*]
dss__pcl_hub_scan_ctl[*]
dss__pcl_hub_scan_ctl_latch[*]
dss__pcl_mdc_sdo_ch*
dss__pcl_msc_clkout_ch*
dss__pcl_msc_lockout_ch*
dss__pcl_rsl_ch*[*]
dss__pcl_si_r*[*]
dss__pcl_tie__hub_state_bits[*]
dss__top_pcl_so_r*[*]
dss_fo_si_r*[*]
dss_so[*]
hub__pad_scan_cmp_out[*]
}



set OUT [open "budget_func_max.tcl" w]



close $OUT


foreach o $outputs {
    puts [get_object_name [filter_collection [all_fanin -to $o -flat -trace_arcs all -startpoints_only] object_class==port]]
}

set BDB('dch__pcl_si_uncomp_r*',clocks)   {}
set BDB('dch__top_jtag_lobe_bso',clocks)  {bs_tck_halfspeed pi_tck_gen}
set BDB('dch__top_jtg_so[*]',clocks)      {pi_tck_gen}


foreach p $ports {
    puts "$p [get_object_name [get_attr [index_collection [get_ports $p] 0] launch_clocks]]"
}



set_input_delay  4.47596 -clock [get_clocks {sclk}] -clock_fall -max -source_latency_included [get_ports {dss_fo_so_r0[31]}]
set_input_transition -rise -max -clock sclk -clock_fall  7.357 [get_ports {dss_fo_so_r0[31]}]
set_input_transition -fall -max -clock sclk -clock_fall  7.357 [get_ports {dss_fo_so_r0[31]}]
set_load -pin_load  0.0033 [get_ports {dss_fo_so_r0[31]}]


set_output_delay  -1.647847 -clock [get_clocks {pi_bypass_clk}] -max -source_latency_included [get_ports {dss__msh_rsp_ch0[69]}]
set_load -pin_load  0.01 [get_ports {dss__msh_rsp_ch0[69]}]




proc split_ports_to_clocks {ports_list direction} {

    foreach port $ports_list {
        set p    [index_collection [get_ports $port] 0]
        set clks [get_object_name [get_attr $p launch_clocks]]
        if {$clks eq ""} {set clk 'vBudgetClk'}
        if {[info exists BDB($clks)]} {
            lappend BDB($clks) $port
        } else {
            set  BDB($clks) $port
        }
    }
    foreach group [array names BDB] {
        set prnt "set ${direction}_ports_at_clocks"
        foreach g $group {
            set prnt "${prnt}_${g}"
        }
        set prnt "$prnt {"
        foreach p $BDB($group) {
            set prnt "$prnt $p "
        }
        set prnt "$prnt }"
        puts $prnt
    }
}
