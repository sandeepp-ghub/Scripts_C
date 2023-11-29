#--------------------------------------------------------------------
# Basic LEC setup file
#
# Version 2017_07_25
#
#--------------------------------------------------------------------

#--------------------------------------------------------------------
# General
#--------------------------------------------------------------------
# Set top module
set lec_vars(root_module_name) apn810
set lec_vars(root_module_name_revised) $lec_vars(root_module_name)


# Set search paths for library and design (optional)
# Example: set lec_vars(search_path) "$env(LIBRARY_PATH)/lib"
set lec_vars(search_path) ""





# No translate modules (black boxes)
# Note (1): specify RAMs, IPs, etc. that need not be compared
# Note (2): if using '*', make sure you don't catch other modules, besides those you intended to
# Note (3): Specified modules will first be parsed and then become black-boxed, so
#           reading the module definition is required!
# Examples: set lec_vars(notrans_modules) {sr1p* sr2p* rf1p* rf2p* MISL_0028HPM*_DRO}
#set lec_vars(notrans_modules) {MISL_T0016FF*DRO TS*N16FFCLL* *apn807_msoc_macro* *apn807_c2c_cp_macro* *apn807_dfx_server_macro* *apn807_dss_macro*  *apn807_dss_phy_dig_macro* *apn807_ihb_macro* *apn807_nb_macro* DBYTE_Channel0* *PAD1618AS25_VDDFB* *PAD1618AS25_ANA18_DIODE* PV_PAD1618AS25_ANA18_DIODE PV_PAD1618AS25_ANA18_DIODE_TP  *DBYTE_Channel0_v_w_bumps* *DBYTE_Channel0_w_bumps* *dwc_ddrphydbyte_top* *dwc_ddrphyacx4_top* *DBYTE* dwc_ddrphymaster_top ana_grp_w_xtal dwc_ddrphyacx4_top ihb_refclk_w_bumps LF3P_TSMC MISL_0016FF_ANALOG_PG MISL_0016FFC_V_PIDI_RX MISL_0016FFC_V_PIDI_TX MISL_0016_RDL_VDD_SENSE MISL_T0016FF_IO_DRO MISL_T0016FFPLUSLL_VERSION_MACRO_11ML_2XA1XD3XE2Y2R PH_PAD1618AS25_AVDD18_AVSS_50_CP PH_PAD1618AS25_VSS_D_CP pidi_16FFC_quatro PV_PAD1618AS25_ANA18_DIODE PV_PAD1618AS25_ANA18_DIODE_TP PV_PAD1618AS25_AVDD18_AVSS_50 PV_PAD1618AS25_VDDFB_VSS_65 PV_PAD1618AS25_VSS_D TEF16FCLLESD_P_V TSENE_ADC  }
set lec_vars(notrans_modules) {
cmos_16FFC_v_12io
cmos_16FFC_v_special_12io
sdh_phy_top_11p_w_bumps
pidi_16FFC_quatro
cmos_16FFC_h_8io
PH_PAD1618AS25_AVDD18_AVSS_50_CP
PH_PAD1618AS25_VSS_D_CP
PHI_PAD1618AS25_ANA18_DIODE
PHO_PAD1618AS25_ANA18_DIODE
PHO_PAD1618AS25_ANA18_DIODE_TP
PH_PAD1618AS25_VDDFB_VSS_65
PH_PAD1618AS25_ANA18_NP_AVSS_50
PH_PAD1618AS25_AVDD18_AVSS_50
PH_PAD1618AS25_VSS_D
MISL_0016FFC_PIDI_INPUT
MISL_0016FFC_PIDI_OUTPUT
PH_PADXDC_IOB_DZZ
PH_PADXDC_IOB_DZZ_CP
PH_PADXDC_VDD_LV
PH_PADXDC_VDDO
PH_PADXDC_VDDO_CP
PH_PADXDC_VSS
PH_PADXDC_VSSO
PH_PADXDC_VSSO_CP
PH_PADXDC_VSSO_POR_CP
PHS_PADXDC_NOREF
PHS_PADXDC_PDB_INT
PHS_PADXDC_V18EN_LVL_CP
PHS_PADXDC_ZPZN_LVL
PV_PADXDC_IOB_DPD1M_OD_3VFS_CP
PV_PADXDC_IOB_DZZ
PV_PADXDC_IOB_DZZ_CP
PV_PADXDC_VDD_LV
PV_PADXDC_VDDO
PV_PADXDC_VDDO_CP
PV_PADXDC_VSENSOR_CP
PV_PADXDC_VSS
PV_PADXDC_VSSO
PV_PADXDC_VSSO_CP
PV_PADXDC_VSSO_POR
PVS_PADXDC_NOREF
PVS_PADXDC_PDB_INT
PVS_PADXDC_ZPZN_LVL
apn810_pll_ro_wrapper
apn810_sp_smc_macro
ana_grp_w_xtal 
analog_mux2to1_narrow_a_v 
analog_mux2to1_narrow_b_v 
apn810_a2_macro 
apn810_dfx_server_macro
apn810_dss_phy_dig_macro 
apn810_dss_x2_macro 
apn810_eip197_macro 
apn810_ihb0_macro 
apn810_ihb1_macro 
apn810_mcip_macro 
apn810_msoc_macro 
apn810_nic_macro 
apn810_sp_smc_macro 
MISL_0016FFC_AVS
IHB_16G_X4_PHY_V
MISL_0016FF_ANALOG_PG
MISL_0016_RDL_VDD_SENSE 
MISL_0016FFC_V_PIDI_TX
MISL_0016FFC_V_PIDI_RX
MISL_T0016FFPLUSLL_VERSION_MACRO_11ML_2XA1XD3XE2Y2R 
REFCLK_RX_W_CLKDET 
refclk_buffer_two_clock_narrow_a_h 
refclk_buffer_two_clock_narrow_a_v 
refclk_buffer_two_clock_narrow_b_h 
refclk_buffer_two_clock_narrow_b_v 
TSENE_ADC
MISL_T0016FF_IO_DRO
CORESD_0P8V_H50W40_SVT
CORESD_LV_CONFIG
EM_DATA_SUBPHY_VSEN
MISL_0016FFC_APLL
DDRPHYACX4_x7_DDR0
DDRPHYACX4_x7_DDR1
DDRPHYACX4_x3_DDR1
DDRPHYACX4_x3_DDR0
DBYTE_Channel0_v_w_bumps
DBYTE_Channel0_w_bumps
DBYTE_Channel1_v_w_bumps
DBYTE_Channel1_w_bumps
dwc_ddrphymaster0_top_w_bumps
dwc_ddrphymaster1_top_w_bumps
dwc_ddrphy_decapvddq_ew
dwc_ddrphy_decapvddq_ns
DDR34_CAL_IO_SINGLE_4P
DDR34_CAL_IO_SINGLE
DDR34_H_IO_SINGLE
DDR_CAL_IO_SINGLE
LF3P_TSMC
clkdiv_ro_wrapper
nova_bonds
ana_pads_pad
ihb_refclk_w_bumps
ap810_h_ana_pads
avs_h_16FFC_model_wpads
analog_power
apn810_pad1618_avdd_avss
PH_PAD1618AS25_AVDD18_AVSS_50_CP
PH_PAD1618AS25_VSS_D_CP
GAPH_8UM_1618AS25_GR
apn810_ana_grp_w_bump}


set lec_vars(add_renaming_rules) {
    add_renaming_rule M_SYNC_R1       {m_sync_interrupt_%d/m/%wsdsync%w_inst/U%d}            {m_sync_interrupt[@1]/d@4_ff/q_reg} -revised    
    add_renaming_rule SYNC_R1         {msil_sync2/%wd_%wsync%w_inst/U%d}                       {ff@4_reg}              -revised
    add_renaming_rule SYNC_R2         {m/%wd_%wsync%w_inst/U%d}                                {d@4_ff/q_reg}          -revised    
    add_renaming_rule SYNC_R3         {sync2/msil_sync2_with_clr/%wsdsync%w_inst/U%d}          {sync2/ff@3_reg}        -revised
    
    add_renaming_rule ARRAY_LATCH_R1 {array_latch_%d/generic_cell_latch/U\$%d/U\$%d}   {array_latch\[@1\]/Q_reg} -revised
    add_renaming_rule SCAN_OBSERVE_R1 {scan_observe_ff/generic_cell_dff/U\$%d/U\$%d}   {scan_observe_ff/Q_reg} -revised
    add_renaming_rule TLATNTSCA_R1    {m_tlatntsca/m/U\$%d/U\$%d}                      {m_tlatntsca/q_reg} -revised
   add_renaming_rule R1 {reg_%d__%d_} {reg\[@1\]\[@2\]} -revised
   add_renaming_rule R2 {reg_%d_} {reg\[@1\]} -revised


    # fix for last unmapped points
    add_renaming_rule FIXME {_reg_%d_/U\$%d/U\$%d}                                     {_reg\[@1\]}         -revised
}



# Optional - set Verilog2k library files to read with read_library command
# Note: If not used - specify the library files in the rtl_file / gtl_file
#
# Example:
# set lec_vars(verilog_library_files_golden) [ join [ concat "
#  $env(LIBRARY_PATH)/vg/gtl/m9lzd_std_formal.v
#  $env(LIBRARY_PATH)/vg/gtl/m9szd_std_formal.v
# "]]
set lec_vars(verilog2k_library_files_golden) [ join [ concat "
"]]

set lec_vars(verilog2k_library_files_revised) [ join [ concat "
"]]

set lec_vars(read_v2k_library_extra_flags_golden) ""
set lec_vars(read_v2k_library_extra_flags_revised) ""


set lec_vars(exit_condition)  "off"			;# set "eq" to exit session in case of Equivalent compare results
											;# set "on" to exit session, at the end, in any case


set lec_vars(aborts) 1    ;# Set "1" to run analyze_aborts, otherwise "0"
                           # (1) It may take long time for large designs or if many aborts exists!
                           # (2) In hier compare - "analyze_abort" will not be executed automatically on the top module


set lec_vars(save_checkpoint_db) "no"	;# Set to "always" -  in order to save "Checkpoint" database, at the end of each run.
										;# Set to "on_exit" - in order to save "Checkpoint" database, before exiting the session, 
										;#                    if the exit condition, as set by $lec_vars(exit_condition), was met.
										;# To Open a DB, run: mqsub <options> -int lec <lec options> -restart_checkpoint <pointer_to_DB>



set lec_vars(liberty_library_files_for_power_golden) [ join [ concat "
/project/galileo102/apn810/libset/libs_apn810_B0_16FFC_180219_7p5t/model/lib/MISL_0016FFC_PIDI_tt1v85c.lib
/project/galileo102/apn810/libset/libs_apn810_B0_16FFC_180219_7p5t/model/lib/MISL_T0016FFPLUSLL_VERSION_MACRO_11ML_2XA1XD3XE2Y2R_tt1p0v25c.lib
/project/galileo102/apn810/libset/libs_apn810_B0_16FFC_180219_7p5t/model/lib/MISL_0016FF_ANALOG_PG_typ1p0v85.lib
/project/galileo102/apn810/libset/libs_apn810_B0_16FFC_180219_7p5t/model/lib/dwc_ddrphymaster_top_typical0p9v25.lib
/libraries/TSMC/0.016FFC-LL/IO/MAPL/PAD1618ANAS25/rev3.0.3_2_20Dec17/lib/pad1618anas25_typ1p8v0p7v25.lib
/libraries/TSMC/0.016FFC-LL/Modules/MSI/ANA_GRP_W_XTAL/rev1.3.1_22Jan17/lib/ana_grp_w_xtal_ssgnp0p72vm40c.lib
/libraries/TSMC/0.016FFC-LL/Modules/SYNOPSYS/DWC_DDR43_PHY/rev1.0.2_23Jul17/lib/dwc_ddrphyacx4_top_ew_typical0p9v25.lib
/libraries/TSMC/0.016FFC-LL/Modules/SYNOPSYS/DWC_DDR43_PHY/rev1.0.2_23Jul17/lib/dwc_ddrphyacx4_top_ns_typical0p9v25.lib
/libraries/TSMC/0.016FFC-LL/Modules/SYNOPSYS/DWC_DDR43_PHY/rev1.0.2_23Jul17/lib/dwc_ddrphydbyte_top_ns_typical0p9v25.lib
/libraries/TSMC/0.016FFC-LL/Modules/SYNOPSYS/DWC_DDR43_PHY/rev1.0.2_23Jul17/lib/dwc_ddrphydbyte_top_ew_typical0p9v25.lib
"]]

set lec_vars(liberty_library_files_for_power_revised) $lec_vars(liberty_library_files_for_power_golden)



#--------------------------------------------------------------------


#--------------------------------------------------------------------
# DATAPATH (for RTL vs. GL only)
#--------------------------------------------------------------------

# Turn on datapath analysis (helps to solve aborts)
set lec_vars(datapath) No		;# Valid values are "No" or "Basic" or "Advanced" (longer run time!)

# For Hierarchical run - set datapath analysis method
set lec_vars(datapath_hier) No	;# Valid values are "No" or "Basic" or "Advanced" (longer run time!)
								;# NOTE: by default, "analyze_datapath -effort high" is executed on every module,
								;# even when this variable is set to "No".

set lec_vars(dp_resource_file) {}	;# Adding the resource file from DC synthesis (usually located under
									;# report directory. Example: /report/dct_2_synt/<macro>.resources.gz)
									;# might improve analyze_datapath command
									;# Note: Please gunzip the file!

#--------------------------------------------------------------------


#--------------------------------------------------------------------
# DESIGN READING
#--------------------------------------------------------------------

set lec_vars(rtl_vs_rtl) 1


# point to the Verilog2k / SV (SystemVerilog) / SVA (SystemVerilog Assertion) / VHDL
# files to read as the Golden design
set lec_vars(vhdl_golden) "../script/vhdl_golden"
set lec_vars(sv_golden) "../script/sv_golden"
set lec_vars(sv_assert_golden) "../script/sv_assert_golden"
set lec_vars(v2k_golden) "../script/v2k_golden"

# If Revised design is also RTL - use bellow variables
set lec_vars(vhdl_revised) "../script/vhdl_revised"
set lec_vars(sv_revised) "../script/sv_revised"
set lec_vars(sv_assert_revised) "../script/sv_assert_revised"
set lec_vars(v2k_revised) "../script/v2k_revised"

# If Revised design is a netlist
#set lec_vars(gtl_revised) "../script/gtl_revised"
set lec_vars(sv_revised) "../script/sv_revised"

# If required, specify additional flags to be added to the "read_design -golden" command(s)
set lec_vars(read_design_v2k_extra_flags) {-nobboxempty -define SYNTHESIS}
set lec_vars(read_design_vhdl_extra_flags) {-nobboxempty}
set lec_vars(read_design_sv_extra_flags) {-nobboxempty -define SYNTHESIS}
set lec_vars(read_design_sva_extra_flags) {-nobboxempty -define SYNTHESIS}

# If required, specify additional flags to be added to the "read_design -revised" command(s)
set lec_vars(read_design_v2k_extra_flags_revised) {-nobboxempty -define SYNTHESIS}
set lec_vars(read_design_vhdl_extra_flags_revised) {-nobboxempty}
set lec_vars(read_design_sv_extra_flags_revised) {-sensitive -nobboxempty -define SYNTHESIS}
set lec_vars(read_design_sva_extra_flags_revised) {-nobboxempty -define SYNTHESIS}

# If required, specify additional flags to be added to the "read_design -revised" command
# when revised is a netlist
set lec_vars(read_design_gtl_revised_extra_flags) {}

#--------------------------------------------------------------------


#--------------------------------------------------------------------
# CONSTRAINTS
#--------------------------------------------------------------------


# (1) Important: DO NOT constraint signals like scan_mode_, because they control
#     logic which exist in both golden and revised designs!
#
# (2) Important: DO NOT constraint scan_shift when comparing Gate-level vs. Gate-level!
#     However, it might be needed if the scan chains order was changed.
#
# (3) constrain pin 'cg_bypass' (test enable of clock gates) in designs with automatic clock-gating
#     Important: Avoid constraining cg_bypass when comparing Gate-level vs. Gate-level!
#
# (4) Important: DO NOT constraint edt_bypass if both golden and revised contain EDT logic!

# Specify pin constraint (on Primary inputs)
# Format: {<primary input>} {<value> <both|golden|revised>}
# Example: {scan_shift} {0 both}
set lec_vars(add_pin_constraints) {
 {scan_shift} {0 both}
 {cg_bypass}  {0 both}
 {edt_bypass} {1 both}
}


# Ignore ports
# Example: Ignore scan out ports, when comparing RTL vs. Gate-level with scan chains
set lec_vars(ignore_output) [ join [ concat "
*scan_out*
"]]




#--------------------------------------------------------------------


#--------------------------------------------------------------------
# VDD / VSS HANDLING
#--------------------------------------------------------------------

set lec_vars(include_vddvss) 0    ;# Set "1" to enable VDD & VSS (ports / pins) handling

# Handling Black-Boxed modules with POWER / GROUND ports in Netlist
# (1) If BBOX modules in the Revised include VDD / VSS pins, which DO NOT
#     exist in the matching Golden modules - ignore these pins.
# (2) Do not ignore ports which exist in both Golden and Revised!
# (3) If library includes non-functional cells (like caps) with input VDD / VSS pins - add it too!
#     Example: For TSMC 16nm libraries - add "DCAP*", "TAPCELL*", "BOUNDARY_*", "FILL*", "fzd_sdlcap*" 
# 	  and similar modules to below variable.
set lec_vars(bbox_modules_ign_vddvss_in_rev) {}

#--------------------------------------------------------------------


#--------------------------------------------------------------------
# MODELING
#--------------------------------------------------------------------

# Setup information file
# Point to any of the following file types:
# RC logfile, DC logfile or VSDC (a DC output)
# This can help LEC undrstand seq constant propagation, seq merge, seq X modeling, etc...
set lec_vars(setup_info_files) {}


# Note: the two settings below are unrelated to each other!
set lec_vars(analyze_setup_iterations) "0"    		;# If set to "1" or higher number, will execute "analyze_setup -verbose" N times
                                               		;# (N is the variable value). Can help with mapping and modeling issues

set lec_vars(analyze_setup_ultra_iterations) "0"    ;# If set to "1" or higher number, will execute "analyze_setup -verbose -effort ultra" N times
                                                    ;# (N is the variable value). Can help with mapping and modeling issues

#--------------------------------------------------------------------


#--------------------------------------------------------------------
# USER COMMAND
#--------------------------------------------------------------------
#
# Specify commands to be executed during the flow.
#
# Example 1: Note the ";" at the end of each command!
#
# set lec_vars(cmd_) [ join [ concat "
#   report_design_data;
#   dofile ../script/myfile.tcl;
# "]]
#
# Example 2: Using curly brackets instead of [ join [ concat "..."]] - to avoid variable interprating
#
# set lec_vars(cmd_before_write_hier_dofile) {
#   set_parallel_option -threads 0,$comp_threads;
# }
#
#
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy_0  -revised;
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy_1  -revised;
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy_2  -revised;
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy_3  -revised;
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy_4  -revised;
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy_5  -revised;
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy_6  -revised;
#add_primary_output -pin apn807_dss_phy_dig_macro/scan_shift_2dss_phy  -golden;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_0  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_1  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_2  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_3  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_4  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_5  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_6  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_7  -revised;
# add_output_equivalences apn807_dss_phy_dig_macro/scan_shift_2dss_phy  apn807_dss_phy_dig_macro/scan_shift_2dss_phy_8  -revised;
# add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_0 -module apn807_dss_phy_dig_macro  -revised;
 set lec_vars(cmd_before_write_hier_dofile) {
uniquify -all -nolib;add_primary_input -pin /device_io/pidi_16FFC_jtg_slave3_pad/bi_ser_sel_p0 -both;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_1 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_2 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_3 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_4 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_5 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_6 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_7 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_8 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_1 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_2 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_3 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_4 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_5 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_6 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_7 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_8 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy_  scan_mode_2dss_phy_0 -module apn807_dss_phy_dig_macro   -revised;
 }
#
# Tip: Can be used to source a file, whose content you can modify during the run!

# Specify file to be sourced before reading in libraries and designs
# set lec_vars(cmd_before_read_libs_designs)  [ join [ concat "
# "]]

# Specify file to be sourced right before entering LEC mode
set lec_vars(cmd_before_lec_mode)  [ join [ concat "
uniquify -all -nolib;add_primary_input -pin /device_io/pidi_16FFC_jtg_slave3_pad/bi_ser_sel_p0 -both;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_0 -module apn807_dss_phy_dig_macro  -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_1 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_2 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_3 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_4 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_5 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_6 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_7 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_shift_2dss_phy  scan_shift_2dss_phy_8 -module apn807_dss_phy_dig_macro   -revised;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_0 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_1 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_2 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_3 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_4 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_5 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_6 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_7 -module apn807_dss_phy_dig_macro   -revised ;
 add_output_equivalences scan_mode_2dss_phy  scan_mode_2dss_phy_8 -module apn807_dss_phy_dig_macro   -revised ;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY8  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY7  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY6  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY5  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY4  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY3  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY2  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY1  -revised;
add_primary_input -pin apn807_dss_phy_dig_macro/TIEforYY0  -revised;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY8   -revised; 
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY7   -revised ;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY6   -revised ;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY5   -revised ;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY4   -revised ;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY3   -revised ;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY2   -revised ;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY1   -revised ;
 add_pin_constrain 0  apn807_dss_phy_dig_macro/TIEforYY0   -revised ;

 "]]

# Specify file to be sourced right after entering LEC mode
set lec_vars(cmd_after_lec_mode)  [ join [ concat "
"]]

# Specify file to be sourced right before "compare"
set lec_vars(cmd_before_compare)  [ join [ concat "
add_mapped_points apn807_dss_phy_dig_macro apn807_dss_phy_dig_macro  -output scan_mode_2dss_phy_ scan_mode_2dss_phy -invert;
"]]

# Specify file to be sourced right before "write_hier_compare_dofile" (in hierarchical run)
# (Tip: can be used to add "add_noblack_box <module name> -both", to speed up next run!)
set lec_vars(cmd_before_write_hier_dofile)  [ join [ concat "
"]]

#--------------------------------------------------------------------


#--------------------------------------------------------------------
# MAPPING
#--------------------------------------------------------------------

set lec_vars(map_bbox_no_name_match) 0    	;# Set "1" to allow mapping black-boxe instances, which have different module names.
                                           	;# Warning: Review design code to verify that the BBOX modules are Ok!


set lec_vars(mapping_for_debug) 0    		;# Use if there are mapping issues
set lec_vars(analyze_setup_mapping_for_debug) 1
set lec_vars(analyze_setup_mapping_for_debug_flags) {} ;# Add "-effort ultra" if required


# For multi-bit cells or other cutom mapping
set lec_vars(use_mapping_file) 0

# Specify mapping file. It should contain commands in the format of:
# add mapped points <golden point> <revised point>
set lec_vars(mapping_file) {}

#--------------------------------------------------------------------


#--------------------------------------------------------------------

# Specify pointer and label name of the Genus DB directory, from which tool will read the .json file
# Format: 
#set lec_vars(implementation_information) {
# {<genus_db_directory>} {<label>}
#}
# Example
#set lec_vars(implementation_information) {
# {/store/genus/r2/dataout/rc_2_synt/} {rc_2_synt}
#}
set lec_vars(implementation_information) {}

# point to the change_name logfile, which Genus creates in all stages up to (and including) the stages
# at which the netlist was created
# ADD IT IN REVERSE ORDER OF STAGES!!!!
set lec_vars(change_name_logs) {
}

#--------------------------------------------------------------------


#--------------------------------------------------------------------
# HIERARCHICAL RUN
#--------------------------------------------------------------------

# Flat or Hierarchical
set lec_vars(hierarchical) 0    			;# Set "1" to run hierarchical compare. Default (0) is Flat compare

# If some modules are aborted during hierarchical compare (or get stuck on comparison, during hier compare)
# Specify a REG-EXP pattern for the module names, to allow special handling for them.
# Example: set lec_vars(aborted_modules_name) {mbu|ctrl_.*_top}
# This will match modules named: "xmbuy", "ctrl_1_top", "ctrl_2x_top", etc...
set lec_vars(aborted_modules_name) {}

#--------------------------------------------------------------------

#--------------------------------------------------------------------
# LEC-LP (Low-Power Equivalence Check)
#--------------------------------------------------------------------

set clp_vars(lp_checks) 0 						;# set 1 to turn on Low-Power features. Set 0 to run regular LEC

#--------------------
#
# Set design style based on the degree of Power-Ground information available in the design.
# Power-Ground information in a design implies connection of power and ground nets and the power switch cells.
#
# logical  - netlists without pwr/gnd
# hybrid   - netlists with partial pwr/gnd
# physical - post P&R netlists with full pwr/gnd
#
# For 1801_flow: see in $LEC_TEMPLATE/setup_lec.advanced.tcl
#
set clp_vars(design_style_golden)  "logical"	;# logical / hybrid / physical
set clp_vars(design_style_revised) "physical"	;# logical / hybrid / physical
#--------------------

# (1) DO NOT read LEF if the matching lib file includes "pg_pin" definitions for the power / ground ports
# (2) For macro models (for which you read also cpf) - read LEF only (not liberty)
set clp_vars(lef_library_files_golden) [ join [ concat "
"]]

set clp_vars(lef_library_files_revised) [ join [ concat "
"]]


set clp_vars(verilog2k_library_files_golden) [ join [ concat "
"]]

set clp_vars(verilog2k_library_files_revised) [ join [ concat "
"]]


set clp_vars(liberty_library_files_golden) [ join [ concat "
"]]

set clp_vars(liberty_library_files_revised) [ join [ concat "
"]]


set clp_vars(read_v2k_library_extra_flags_golden) ""	;# Specify additional flags for "read_library -verilog2k -golden"
set clp_vars(read_v2k_library_extra_flags_revised) ""	;# Specify additional flags for "read_library -verilog2k -revised"

set clp_vars(read_liberty_extra_flags_golden) "" 		;# Specify additional flags for "read_library -liberty -golden"
set clp_vars(read_liberty_extra_flags_revised) "" 		;# Specify additional flags for "read_library -liberty -revised"


set clp_vars(extract_lp) "no"					;# Should the tool extract LP info from the liberty files:
												;# Values: no | all	| std
												;# no - use it if using all required tech-CPF files exist
												;# std - extract standard low power cells (isolation, level shifter, always on, retention, power switch, and ground switch cells)
												;# all - same as "std", but also extract IO Pad, and macro model cells
												;# WARNING: "all" and "std" options will *override* tech-CPF definitions!

set clp_vars(insert_iso) "no"					;# Valid values: no | golden | revised | both
												;# Set to value other than "no" in order to add "-insert_isolation" to "commit_power_intent" command
												;# Use it if you read a design to which isolation cells have not yet been inserted.
												;# In 1801_flow, this will add "-insert_isolation" to "read_power_intent"


# Speficy Power Intent info (To be used for BOTH Golden & Revised
# Or only Golden - depending on the Revised setting below)
#
set clp_vars(power_intent_file) ""				;# pointer to the power intent file
set clp_vars(power_intent_format) "cpf"			;# allowed values: cpf | upf
set clp_vars(read_pi_extra_flags) ""			;# specify extra flags for "read_power_intent" command


# NOTE: if the Power Intent file is the same for both Golden
# and Revised - leave the below settings (for Revised) empty!
#
set clp_vars(power_intent_file_revised) ""		;# pointer to the Revised power intent file
set clp_vars(power_intent_format_revised) ""	;# allowed values: cpf | upf
set clp_vars(read_pi_extra_flags_revised) ""	;# specify extra flags for "read_power_intent" command for Revised design

set clp_vars(commit_pi_extra_flags_golden) "" 	;# specify extra flags for "commit_power_intent" command - golden
set clp_vars(commit_pi_extra_flags_revised) "" 	;# specify extra flags for "commit_power_intent" command - revised

set clp_vars(skip_lib_cell_voltage_check) 0		;# May need to set to "1" if issues with voltage check of
												;# power domain vs. library nominal voltage exist

#--------------------------------------------------------------------
