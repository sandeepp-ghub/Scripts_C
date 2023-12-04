
# 8
set h core/qint_pipeline
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y


# 125
set h core/reb_dma
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y

#30
set h core/cqm_pipeline
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y

#4
set h core/cqm_cqe_data
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y

#1
set h core/cqm_cint_timer
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y

#3
set h core/cqm_rqmif
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y

#3
set h core/cqm_rebif
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y

#6
set h core/cqm_sqmif
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y

#====================================================================#
# 125
set h core_reb_dma_dma_stage_loop_10
gui_change_highlight -remove -all_colors
set hp [get_pins -of [get_cells $h]]
set in [filter_collection [all_fanin -to $hp -flat   -startpoints_only] "object_class==port"]
set out [filter_collection [all_fanout -from $hp -flat -endpoints_only] "object_class==port"]
zoom -port_col $in -h g
zoom -port_col $out -h r
zoom -cell_col [get_flat_cells * -filter "is_hard_macro==true&&full_name=~$h/*"] -h p
zoom -cell_col [filter_collection $memff "full_name=~$h/*" ] -h y




change_selection [filter_collection [all_registers ] full_name=~core_reb_dma_dma_stage_loop_12*mem_array_reg*]
change_selection [get_flat_cells * -filter "is_hard_macro==true&&full_name=~core_reb_dma_dma_stage_loop_12*"] -add


change_selection [filter_collection [all_registers ] full_name=~core_reb_dma_dma_stage*21*mem_array_reg*]
change_selection [get_flat_cells * -filter "is_hard_macro==true&&full_name=~core_reb_dma_dma_stage*21*"] -add


change_selection [filter_collection [all_registers ] full_name=~core_reb_dma_dma_stage*0*mem_array_reg*]
change_selection [get_flat_cells * -filter "is_hard_macro==true&&full_name=~core_reb_dma_dma_stage*0*"] -add
