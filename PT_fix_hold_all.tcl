proc fix_hold_all {} {
    redirect -file fix_hold_all.log {puts [date]}
    redirect -file fix_hold_all.tcl {puts ""}
    set SES /nfs/pt/tmp_dumps/areas/prj_supp_aman_il/lioral/PT_SESSIONS/
    set func_session_list [list \
        kw28_alpha_macro_overdrive/hold/func/fast_n40_overdrive/bc/Min_Min20/ \
        kw28_alpha_macro_overdrive/hold/func/fast_n40_overdrive/brc/Min_Min20/ \
        kw28_alpha_macro_nomdrive/hold/func/fast_n40/bc/Min_Min20/ \
        kw28_alpha_macro_nomdrive/hold/func/fast_n40/brc/Min_Min20/ \
        kw28_alpha_macro_nomdrive/hold/func/slow/wc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/func/slow/wrc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/func/slow_n40/wc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/func/slow_n40/wrc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/func/typ/tc/Typ_Typ20/ \
        ]
    set scan_session_list [list \
        kw28_alpha_macro_overdrive/hold/scan/fast_n40_overdrive/bc/Min_Min20/ \
        kw28_alpha_macro_overdrive/hold/scan/fast_n40_overdrive/brc/Min_Min20/ \
        kw28_alpha_macro_nomdrive/hold/scan/fast_n40/bc/Min_Min20/ \
        kw28_alpha_macro_nomdrive/hold/scan/fast_n40/brc/Min_Min20/ \
        kw28_alpha_macro_nomdrive/hold/scan/slow/wc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/scan/slow/wrc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/scan/slow_n40/wc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/scan/slow_n40/wrc/Max_Max20/ \
        kw28_alpha_macro_nomdrive/hold/func/typ/tc/Typ_Typ20/ \
    ]
redirect -file fix_hold_all.log -append {puts "Info collecting data ..."}
    foreach s $func_session_list {
        redirect -file fix_hold_all.log -append {puts "restoring session ${SES}${s}"}
        restore_session ${SES}${s}
        set_false_path -hold -from [all_inputs ]
        set_false_path -hold -to  [all_outputs ]
        # set disable clock gating to kill ~-20n hold path in P.T from r2f need app 2.6.13 lior
set_disable_clock_gating_check kw28_sata3_wrap0/FULL_BLOCK_sata3_host_ctrl_top/sata_chnl1_top/plt_top/plt_mux/X17X/B1
set_disable_clock_gating_check kw28_sata3_wrap1/FULL_BLOCK_sata3_host_ctrl_top/sata_chnl0_top/plt_top/plt_mux/X17X/B1
set_disable_clock_gating_check kw28_sata3_wrap0/FULL_BLOCK_sata3_host_ctrl_top/sata_chnl0_top/plt_top/plt_mux/X17X/B1
set_disable_clock_gating_check kw28_sata3_wrap1/FULL_BLOCK_sata3_host_ctrl_top/sata_chnl1_top/plt_top/plt_mux/X17X/B1
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac16_single_rx_mux/serdes2mac_core_clk_mux/TREE_LEVEL_1__WORD_MUX_2__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac5_single_rx_mux/serdes2mac_rxdclk_2x_mux/TREE_LEVEL_1__WORD_MUX_1__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac4_single_rx_mux/serdes2mac_rxdclk_2x_mux/TREE_LEVEL_1__WORD_MUX_2__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac4_single_rx_mux/serdes2mac_rxdclk_2x_mux/TREE_LEVEL_1__WORD_MUX_1__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac16_single_rx_mux/serdes2mac_core_clk_mux/TREE_LEVEL_1__WORD_MUX_1__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac14_single_rx_mux/serdes2mac_core_clk_mux/TREE_LEVEL_1__WORD_MUX_1__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac15_single_rx_mux/serdes2mac_core_clk_mux/TREE_LEVEL_0__WORD_MUX_0__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac6_single_rx_mux/serdes2mac_rxdclk_2x_mux/TREE_LEVEL_1__WORD_MUX_2__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check comphys_muxes_wrap/comphys_muxes_top/mac6_single_rx_mux/serdes2mac_rxdclk_2x_mux/TREE_LEVEL_1__WORD_MUX_1__BIT_MUX_0__mux/m/S
set_disable_clock_gating_check kw28_ad_top_wrap/FULL_BLOCK_ad_top/ad_audio_top/ad_audio_rx/cwda16/u1/X87X/A2

        set paths [get_timing_paths -slack_lesser_than 0 -max_path 100000 -delay_type min -group [remove_from_collection [get_path_group] [get_path_groups {IN OUT INOUT}]]]

        foreach_in_collection p $paths {
            set epoint        [get_object_name [get_attr $p endpoint  ]]
            set slack         [get_attr $p slack]
            if {$slack < -0.12} {
                redirect -file fix_hold_all.log -append {puts "Warning: there are some big slack in here $slack \n ${SES}${s}"}
                continue
            } ;# dont work on probebly not real val
            if {[info exists endpoint_table($epoint,name)]} {
                redirect -file fix_hold_all.log -append {puts "Info: going over existing end point $epoint"}
                #-- slack is in neg -0.003
                if {$endpoint_table($epoint,slack) > $slack} { 
                    redirect -file fix_hold_all.log -append {puts "Info: end point $epoint have new slack $endpoint_table($epoint,slack) --> $slack"}
                    set endpoint_table($epoint,slack) $slack
                    set number_of_bufs 1 ;#[expr {round($slack/0.030)}]
                    if {$slack < -0.025} {set number_of_bufs 2}
                    if {$slack < -0.80} {set number_of_bufs 3}
                    set endpoint_table($epoint,buf_num) $number_of_bufs
                    redirect -file fix_hold_all.log -append {puts "Info: old endpoint new vals slack $slack number of buf to add $number_of_bufs"}
                }
            } else {
                set endpoint_table($epoint,name)  $epoint
                set endpoint_table($epoint,slack) $slack
                set number_of_bufs 1 ;#[expr {round($slack/0.030)}]
                if {$slack < -0.025} {set number_of_bufs 2}
                if {$slack < -0.80} {set number_of_bufs 3}
                set endpoint_table($epoint,buf_num) $number_of_bufs
                lappend endpoint_list $epoint
                redirect -file fix_hold_all.log -append {puts "Info: new endpoint $epoint slack $slack number of buf to add $number_of_bufs"}
            }
        }
    }; # end of collecting data for func
    

    foreach s $scan_session_list {
        redirect -file fix_hold_all.log -append {puts "restoring session ${SES}${s}"}
        restore_session ${SES}${s}
        set_false_path -hold -from [all_inputs ]
        set_false_path -hold -to  [all_outputs ]
        set paths [get_timing_paths -slack_lesser_than 0 -max_path 100000 -delay_type min -group [remove_from_collection [get_path_group] [get_path_groups {IN OUT INOUT}]]]

        foreach_in_collection p $paths {
            set epoint        [get_object_name [get_attr $p endpoint  ]]
            set lib_pin_name [get_attr [get_attr $p endpoint] lib_pin_name]
#if {$lib_pin_name ne "SI" } {
#                redirect -file fix_hold_all.log -append {puts "Warning:$epoint is not an SI pin on a scan hold path"}
#                if {$slack < -0.1} {continue; } ;# dont work on not si paths you cant fix with 1 buf
#            } else {
#                redirect -file fix_hold_all.log -append {puts "Info:$epoint is an SI pin on a scan hold path"}
#            }
            set slack         [get_attr $p slack]
            if {$slack < -0.12} {
                redirect -file fix_hold_all.log -append {puts "Warning: there are some big slack in here $slack \n ${SES}${s}"}
                continue
            } ;# dont work on probebly not real val
            if {[regexp {/memory/} $epoint]} {puts "memory"; continue}
            if {[info exists endpoint_table($epoint,name)]} {
                redirect -file fix_hold_all.log -append {puts "Info: going over existing end point $epoint"}
                #-- slack is in neg -0.003
                if {$endpoint_table($epoint,slack) > $slack} { 
                    redirect -file fix_hold_all.log -append {puts "Info: end point $epoint have new slack $endpoint_table($epoint,slack) --> $slack"}
                    set endpoint_table($epoint,slack) $slack
                    set number_of_bufs 1 ;#[expr {round($slack/0.030)}]
                    if {$slack < -0.025} {set number_of_bufs 2}
                    if {$slack < -0.80} {set number_of_bufs 3}
                    set endpoint_table($epoint,buf_num) $number_of_bufs
                    redirect -file fix_hold_all.log -append {puts "Info: old endpoint new vals slack $slack number of buf to add $number_of_bufs"}
                }
            } else {
                set endpoint_table($epoint,name)  $epoint
                set endpoint_table($epoint,slack) $slack
                set number_of_bufs 1 ;#[expr {round($slack/0.030)}]
                if {$slack < -0.025} {set number_of_bufs 2}
                if {$slack < -0.1} {set number_of_bufs 3}
                set endpoint_table($epoint,buf_num) $number_of_bufs
                lappend endpoint_list $epoint
                redirect -file fix_hold_all.log -append {puts "Info: new endpoint $epoint slack $slack number of buf to add $number_of_bufs"}
            }
        }
    }; # end of collecting data for scan


    


    #-- making a change file
    foreach e $endpoint_list {
        for {set i 1} {$i<=$endpoint_table($e,buf_num)} {incr i} {
            redirect -file fix_hold_all.tcl -append {puts "insert_buffer $e szd_sbufx2 ; #$endpoint_table($e,slack)"}
        }
    }


}; #end of proc

