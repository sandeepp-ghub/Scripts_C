#App variables

#This is to track all logical hier transformations per formed by the tool
set_app_var hdlin_enable_hier_map true 

#Libs
set_app_var search_path [list . $::env(SYNOPSYS)/libraries/syn]
set target_lib_list   [ipbu_get_key {SYN FLOW target_libs}]
set link_lib_list     [ipbu_get_key {SYN FLOW link_libs}]


#Analyse

analyze -format sverilog -vcs {-sverilog -f ../defacto.rtl/dataout/rnk.defacto.rtl.defacto:get_rtl.rtl_file_list}

#Elaborate

elaborate rnk
link

#Create guid_hier_map (its a verification guidance for hier designs. Captures accurate referent for each hier transformations)
set_verification_top

#Post_elab
set_fix_multiple_port_nets -all -buffer_constants
set_technology -node 5
report_hierarchy -noleaf
change_names -hier -rules verilog
write -format ddc -hierarchy -output rnk.ddc/elab.ddc
write_environment -format dctcl -o rnk.ddc/elab.env.tcl -environment_only


#Constraints , clock etc


#RNK Constraints

#UPF
load_upf ../inp/rnk.srsn.upf

#SDC, Path Group, OCV for each scenarios
create_clock -name sclk -period 0.932 -waveform {0 0.466} -add [get_ports { sclk } ] -comment clock_on_a_port
create_clock -name pi_refclk -period 9.059 -waveform {0 4.5295} -add [get_ports { refclk } ] -comment clock_on_a_port
create_clock -name noisy_ck_tp -period 45.353 -waveform {0 22.6765} -add [get_pins {ebg/ebg0/ana_rng_top_0/NOISY_CK_TP} ] -comment clock_on_a_pin
create_clock -name ck_fast_tp -period 3.614 -waveform {0 1.807} -add [get_pins {ebg/ebg0/ana_rng_top_0/FAST_CK_DIV16_TP} ] -comment clock_on_a_pin
create_clock -name brn_ck_tp -period 45.353 -waveform {0 22.6765} -add [get_pins {ebg/ebg0/ana_rng_top_0/BRN_CK_TP} ] -comment clock_on_a_pin
create_clock -name brn_ck -period 45.353 -waveform {0 22.6765} -add [get_pins {ebg/ebg0/ana_rng_top_0/BRN_CK} ] -comment clock_on_a_pin
create_generated_clock {ebg/ebg0/ebg_ds0/DS_CL_GATE/QCK} -name clk_ds -master_clock brn_ck -source [get_pins ebg/ebg0/ana_rng_top_0/BRN_CK] -divide_by 1 -add

#Clock uncertainty/transition/Latency
#:dc::common::setup_uncertainty_clk_groups_cg
#::dc::common::setup_clock_transition_latency

#Pushdown constraints for the input/delays for the IO ports or write default constraints
#::dc::common::source_pushdown_constraints
#::dc::syn::set_default_constraints

set default_input_delay 0.05
set default_input_transition 0.01
set default_input_load 0.01

set inputs_no_clk [all_inputs_but_clocks]

foreach_in_collection port $inputs_no_clk {
    set_input_transition $default_input_transition -max $portn
    set_load $default_input_load $portn
    set_input_delay $inp_delay($clk_name) -clock $clk_name -add_delay $port_name -clock_fall
}

set_input_transition $def_input_transition -max $portn
set_load $def_input_load $portn
set_input_delay $inp_delay($clk_name) -clock $clk_name -add_delay $port_name -clock_fall
set_load $def_output_load $portn
set_output_delay $out_delay($clk_name) -clock $clk_name -add_delay $port_name -clock_fall

# Dont use, don't touch, and size-only




#DRV
set_max_fanout 40 rnk
set_max_transition 0.076 rnk
set_max_capacitance 0.240 rnk
set_max_area 0
set_timing_derate 1.07 -late

#set_preferred_scenario func:max1_setup_ssgnpmax1vm40c_cworstCCwTm40c /
#set_scenario_options -scenarios func:max1_setup_ssgnpmax1vm40c_cworstCCwTm40c -setup true -hold false -dynamic false -leakage_power true -cts_mode false -cts_corner none

#Other dont_use, set_fale_path Clock gating constraints

#DEF
extract_physical_constraints -verbose ../inp/rnk.macro_with_pg.def.gz

#Interconnect
set_zero_interconnect_delay_mode true




#Verify
check_design

#Compile
compile_ultra

#compile directives
set_boundary_optimization scan_hub false
set_compile_directives -delete_unloaded_gate false -constant_propagation false -local_optimization false -critical_path_resynthesis false cn_scan_hub
set_ungroup scan_hub false
set_compile_spg_mode icc2
set_ahfs_options -constant_nets true
set_ahfs_options -preserve_boundary_phase true


compile_ultra -scan -gate_clock -no_seq_output_inversion -spg

#Writing netlist
write -format ddc -hierarchy -output rnk.ddc/compile_hier.ddc
write_environment -format dctcl -o rnk.ddc/compile_hier.env.tcl -environment_only
write -hierarchy -format verilog -output dataout/rnk.dc.syn.compile.v_mapped
write -hierarchy -format verilog -output dataout/rnk.dc.syn.syn:post_compile.v_syn_first_compile

#Multi-bit
set_dft_configuration -wrapper enable
set_wrapper_configuration -class core_wrapper -maximize_reuse enable -reuse_threshold 20
set_multibit_options -mode timing_only -critical_range 0.1
identify_register_banks -output /dataout/rnk.dc.syn.syn:post_compile.mbff_syn  

#DFT Insertion
write -format ddc -hierarchy -output rnk.ddc/pre_dft.ddc
write_environment -format dctcl -o rnk.ddc/pre_dft.env.tcl -environment_only
#::dc::dft::connect_pnr_clkdrv_icg_scan_enable
#::dc::dft::connect_scanshift_regs_to_scanmode
write -format ddc -hierarchy -output rnk.ddc/post_dft.ddc
write_test_protocol -output ./dataout//rnk.dc.syn.dft:insert.spf_scan_compress_intest -test_mode ScanCompression_mode
write_test_protocol -output ./dataout//rnk.dc.syn.dft:insert.spf_scan_bypass_intest -test_mode CW_Intest
write_test_protocol -output ./dataout//rnk.dc.syn.dft:insert.spf_scan_bypass_extest -test_mode CW_Extest
write_test_protocol -output ./dataout//rnk.dc.syn.dft:insert.spf_scan_compress_extest -test_mode CW_Extest_compressed
change_names -hier -rules verilog
write_scan_def -output dataout/rnk.dc.syn.insert.def_scan_dft
write_test_model -format ctl -output dataout/rnk.dc.syn.insert.ctl_dft
write -hierarchy -format verilog -output dataout/rnk.dc.syn.insert.v_dft

#Incr Compile with scan logic
set_compile_spg_mode icc2
set_ahfs_options -constant_nets true
set_ahfs_options -preserve_boundary_phase true
report_ahfs_options
compile_ultra -incr -scan -gate_clock -no_seq_output_inversion -spg
change_names -hier -rules verilog
write -hierarchy -format verilog -output dataout/rnk.dc.syn.opt.opt_v_mapped

#Uniquify
uniquify -force

#Reporting

write_scan_def -output dataout/rnk.dc.syn.finish.def_scan
write_test_model -format ctl -output dataout/rnk.dc.syn.finish.ctl_dft
write_def -components -unit 2000 -pins -output dataout/rnk.dc.syn.finish.place.def
write -hierarchy -format verilog -output dataout/rnk.dc.syn.finish.v_syn
write -format ddc -hierarchy -output rnk.ddc/finish.ddc
write_environment -format dctcl -o rnk.ddc/finish.env.tcl -environment_only
write_script -format dctcl -nosplit -output dataout/rnk.dctcl.tcl
current_design rnk


#Creating all the scenarios

update_timing

#Repeat for all scenarios
set_operating_conditions ssgnp_0p675v_m40c_cworst_CCworst_T
set_voltage 0.675 -obj vdd_sys
set_voltage 0.0 -obj gnd
source ./sdc/rnk.dc.syn.final.func:max1.setup.sdc.cc
source ./sdc/generated_clocks.sdc
source ./sdc/rnk.dc.syn.final.func:max1.setup.sdc
source ./sdc/generic.sdc
source config/finish_constraints.tcl
set_max_fanout 40 rnk
set_max_transition 0.076 rnk
set_max_capacitance 0.240 rnk
set_max_area 0
set_timing_derate 1.07 -late
set_preferred_scenario func:max1_setup_ssgnpmax1vm40c_cworstCCwTm40c
set_scenario_options -scenarios func:max1_setup_ssgnpmax1vm40c_cworstCCwTm40c -setup true -hold false -dynamic false -leakage_power true -cts_mode false -c
set_false_path -from {jtg__hub_scan_ctl[6]}
set_false_path -from {jtg__hub_scan_ctl[7]}
set_false_path -from {jtg__hub_scan_ctl[9]}
set_false_path -from {jtg__hub_scan_ctl[8]}
report_clocks -nosplit
report_case_analysis -nosplit
write_sdc -nosplit dataout/rnk.dc.syn.finish.func:max1.setup.sdc

#Exit
quit


#puts "DFT-INFO: Searching for rtl coded clock gating modules"
#set cond_clkdrv_designs [get_cells -hier -quiet -filter {@name =~ *cmicg*}]
#set sc [sizeof_collection $cond_clkdrv_designs]
#if {$sc == 0} {
#    puts "DFT-INFO: did not find any rtl coded clock gating modules"
#    return
#}
#puts "DFT-INFO: found $sc RTL coded clock gating modules."
#foreach_in_collection icgcell $cond_clkdrv_designs {
#    set o_icgcell [get_object_name $icgcell]
#    set se_pin    [get_pins -of $icgcell -filter "direction==in && clock_gate_test_pin==true"]
#    if {$se_pin == {}} {
#        puts "DFT-ERROR: $o_icgcell does not have a clock_gate_test_pin , there is a problem with the .lib"
#    } else {
#        set se_pin_name [get_object_name $se_pin] 
#        set pin_name    [get_attribute $se_pin name]
#        set pin_net     [get_nets -of $se_pin]
#        set driving_pin [get_pins -of $pin_net -filter "direction==out"]
#        set driving_pin_name [get_attribute $driving_pin name]
#        puts ";## disconnect_net $pin_net $se_pin"
#        disconnect_net $pin_net $se_pin
#        puts ";## set_dft_clock_gating_pin $o_icgcell -pin_name $pin_name -control_signal ScanEnable"
#        set_dft_clock_gating_pin $icgcell -pin_name $pin_name -control_signal ScanEnable
#                                                                                                                                      
#    }
#}
#puts "DFT-INFO: Searching for rtl coded clock gating modules that are controlled by uncompressed chain"
#set enff [get_cells -quiet -hier * -filter "name=~*en_ff_noscan_reg*"]
#if [sizeof $enff] {
#    set cmicg_to_enff \
#        [get_cells -quiet \
#             [all_fanout -flat -only_cells -trace_arcs all -endpoints -from \
#                  [get_pin -quiet -of_objects $enff -filter "name=~Q* && direction==out"]] -filter "name=~*cmicg*"]
#    if [sizeof $cmicg_to_enff] {
#        set cmicg_to_enff_te_pins [get_pins -quiet -of $cmicg_to_enff -filter "direction==in && clock_gate_test_pin==true"]
#        if {$cmicg_to_enff_te_pins == {}} {
#            puts "DFT-ERROR: [get_object_name $cmicg_to_enff] does not have a clock_gate_test_pin , there is a problem with the .lib"
#        } else {
#            foreach_in_collection pin $cmicg_to_enff_te_pins {
#                set se_pin_name [get_object_name $pin] 
#                set pin_name    [get_attribute $pin name]
#                set pin_net     [get_nets -of $pin]
#                set driving_pin [get_pins -of $pin_net -filter "direction==out"]
#                set driving_pin_name [get_attribute $driving_pin name]
#                puts ";## connect_pin -from $scan_enable  -to $se_pin_name -port_name cmicg_to_enff_te_pins"
#                connect_pin -from $scan_enable  -to $pin -port_name cmicg_to_enff_te_pins
#            }
#        }
#    } else {
#        puts "DFT-INFO: No ICG found that are driven by uncompressed chain"
#    }
#} else {
#    puts "DFT-INFO: No ICG found that are driven by ucompressed chain"
#}
#
#set scanshift_regs [get_cells -hier -quiet *_scanshift_* -filter "is_sequential==true"]
#puts "DFT-INFO: scanshift_regs count baseline   : [sizeof_col $scanshift_regs]"
##IPBUBF-1838 Script modification needed to make SE pin of "*bist_dp_bist_q_flop*" flops connect to scan_enable
##append_to_collection scanshift_regs -unique [get_cells -hier -quiet *_bist_dp_bist_q_flop_* -filter "is_sequential==true"]
##puts "DFT-INFO: scanshift_regs count w/ bist_dp : [sizeof_col $scanshift_regs]"
#append_to_collection scanshift_regs -unique [get_cells -quiet [::dc::dft::cvm_cam_macro_xfanout]]
#puts "DFT-INFO: scanshift_regs count w/ hitvec  : [sizeof_col $scanshift_regs]"
#if {[sizeof_collection $scanshift_regs] > 0} {
#    puts "DFT-INFO: Connecting regs with *_scanshift_* SE pins to scan mode"
#    if {$SCAN_HUB != {}} {
#        set scan_mode [get_object_name [get_pins ${SCAN_HUB_INST}/$hub_scan_mode_pin]]
#    } else {
#        set scan_mode [get_object_name [get_ports -regexp $SCAN_MODE_REGEXP]]
#    }
#    set scan_mode_port punch_scan_mode
#    puts "DFT-INFO: scan_mode : $scan_mode        port_name: $scan_mode_port"
#    foreach_in_collection reg $scanshift_regs {            
#        set se_pin [get_pins -of $reg -filter "direction==in && signal_type==test_scan_enable"]
#        set opin [get_object_name $se_pin]
#        set se_net [get_nets -of $se_pin]
#        set onet [get_object_name $se_net]
#        if $FLOW(debug) {
#            puts "debug: reg: [get_object_name $reg]"
#            puts "debug: se_pin: $opin"
#            puts "debug: se_net: $onet"
#        }
#        disconnect_net $se_net $se_pin
#        connect_pin -from $scan_mode -to $se_pin -port $scan_mode_port
#    }
