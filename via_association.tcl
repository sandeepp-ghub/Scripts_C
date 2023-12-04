#read_physical -add_lefs /proj/cadpnr/techfiles/techFileGen/tsmc05/from_tsmc/TSMC_reference_flow/N5_HPC_DFP_v0d9_general_20190314/Cadence/Innovus/N5_H280_reference_script/via_pillar_rule_PRTF_Innovus_N5_15M_1X1Xb1Xe1Ya1Yb5Y2Yy2Z_UTRDL_M1P38_M2P40_M3P48_M4P48_M5P76_M6P76_M7P76_M8P76_M9P76_M10P76_M11P76_H280.09_1a.lef
#/mrvl2g/dc5prengvs01_s_cavm_0005/ccpd01/ccpd01/wa/ngummi/impl/inputs/via_pillar_rule_PRTF_Innovus_N5_16M_1X1Xb1Xe1Ya1Yb4Y2Yy2Yx2R_UTRDL_M1P38_M2P40_M3P48_M4P46_M5P76_M6P80_M7P76_M8P80_M9P76_M10P80_H280.lef

eval_legacy {source /proj/cadpnr/techfiles/techFileGen/tsmc05/from_tsmc/TSMC_reference_flow/N5_HPC_DFP_v0d9_general_20190314/Cadence/Innovus/N5_H280_reference_script/via_pillar_association_PRTF_Innovus_N5_15M_1X1Xb1Xe1Ya1Yb5Y2Yy2Z_UTRDL_M1P38_M2P40_M3P48_M4P48_M5P76_M6P76_M7P76_M8P76_M9P76_M10P76_M11P76_H280.09_1a.tcl}

foreach cell [get_db base_cells .name BUFFD32* ] { set_via_pillars -base_pin $cell/Z -required 1 {VPPERF_M1_M5_16_2_18_2_1 VPPERF_M1_M5_16_2_6_2_1 VPPERF_M1_M6_16_2_18_2_3_1 VPPERF_M1_M6_16_2_6_2_2_1 VPPERF_M1_M12_16_2_18_2_3_2_3_2_2_2_2_1 VPPERF_M1_M12_16_2_6_2_2_1_2_1_2_1_2_1} }
#foreach cell [get_db base_cells .name INVD32* ] { set_via_pillars -base_pin $cell/ZN -required 1 {VPPERF_M1_M12_9_2_9_2_3_2_3_2_2_2_2_1}}
foreach cell [get_db base_cells .name INVD32* ] { set_via_pillars -base_pin $cell/ZN -required 1 {VPPERF_M1_M5_16_2_18_2_1 VPPERF_M1_M5_16_2_6_2_1 VPPERF_M1_M6_16_2_18_2_3_1 VPPERF_M1_M6_16_2_6_2_2_1 VPPERF_M1_M12_16_2_18_2_3_2_3_2_2_2_2_1 VPPERF_M1_M12_16_2_6_2_2_1_2_1_2_1_2_1} }



foreach cell_pin [get_db base_cells .base_pins BUFFD32*/Z INVD32*/ZN] {
#set_db $cell_pin .stack_via_list ""
set_db $cell_pin .stack_via_required 1
}

foreach cell_pin [get_db base_cells .base_pins BUFFD32*/Z INVD32*/ZN] {
puts " $cell_pin [get_db $cell_pin .stack_via_list ]"
puts "$cell_pin [get_db $cell_pin .stack_via_required ]"
}

set mustjoinallports_is_one_pin 1
set_db opt_via_pillar_effort high
set_db add_route_vias_auto true 
set_db route_design_detail_post_route_via_pillar_effort high
set_db route_design_selected_net_only true
set_db route_design_with_timing_driven false
set_db route_design_with_si_driven false
route_global_detail -selected

    eval_legacy { setNanoRouteMode -droutePostRouteViaPillarEffort high }
    set_db opt_via_pillar_effort high
    eval_legacy {setGenerateViaMode -auto true}
    eval_legacy {setGenerateViaMode -advanced_rule true}
