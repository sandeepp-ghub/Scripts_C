

foreach block (jtg mio gibm mrml roc_ocla tsc rmf pad_iocx iocx_ch_x0 iocx_ch_y0 iocx_ch_y1 cpc efuse dro_macro_uptom4_280_wrapper iocx_dss_lv_shim)

    echo  "$block"
    cat /proj/t106a0/sta_release/sub_level_data/io_constraints/iocx/V16/${block}/func:max1_setup_ssgnpmax1vm40c_cworstCCwTm40c/${block}_func:max1_setup_ssgnpmax1vm40c_cworstCCwTm40c.tcl | grep "ipbu_set_clock_latency.*\-clock" | awk '{print $8" ===> "$12}' | sort -u | sed -ne 's/{\|}\|\]\|;//gp'
end
