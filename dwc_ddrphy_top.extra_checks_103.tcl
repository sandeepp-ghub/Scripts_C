################################################################################
## Copyright 2018 Synopsys, Inc. All rights reserved
################################################################################
## SDC for DDR54
##------------------------------------------------------------------------------
## File:        dwc_ddrphy_top.extra_checks.tcl
## Description: Special(extra) checks
################################################################################

################################################################################
## File Contents
##------------------------------------------------------------------------------
## 1. Pclk Latency and skew
##   1.1. Pclk Latency and skew for DBYTE
##   1.2. Pclk Latency and skew for ACX4
##
## 2. DfiClk Latency and skew
##
## 3. PllRefClk Latency
##
## 4. PllBypClk Latency
##
## 5. Skew between DfiClk and PllRefClk
##   5.1 Latency from port DfiClk to master input pin PllRefClk should be shorter than
##       the latency from port DfiClk to all HardIP's DfiClk pins 
##   5.2 Latency from port PllRefClk to master input pin PllRefClk should be shorter
##       than the latency from port DfiClk to all HardIP's DfiClk pins 
##
################################################################################
################################################################################
## Notes for customer
##------------------------------------------------------------------------------
##-- 1. PClk skew check must be covered by construction and SPICE simulation and follow the PNR guidance in the Implementation Guide.
##-- 2. The checkers for clock latency what we provided, the startpoints are from PHY_TOP clock ports 
##--    Customer should change the startpoint from SOC source (e.g. PLL output) in SOC level
################################################################################


##==============================================================================
## Suppress messages during special checks
##==============================================================================
##--    - Disable the following messages (warnings) because the cause is known 

##--    - ENV-003:  Informs for used min or max wire load model selection group chosen atomaticlly  
##--    - PTE-003:  Some timing arcs have been disabled for breaking timing loops or because of constant propagation
##--    - PTE-016:  Informs for expanding clock and calculated base period 
##--    - PTE-018:  Prime Time informs for abandoning fast timing updates in timing update.  
##--    - PTE-101:  Was not inferred clock-gating check for reported pin of cell. This is not clock tree build phase and this is not issue   
##--    - UITE-416: Some start and end points are invalid when report_timing, get_timing_paths are specified with using "*"

#-- lioral lead the snps util procs
source -e -v /user/lioral/scripts/DDR/util.tcl
# set_case_analysis static  dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/U3/S
# create_generated_clock -name atpg_PllRefClk -master_clock pll_mem_clk_ddr5   -divide_by 1  -source dwc_ddrphy_pnr_block/dss_clocks/dss_clocks_xclk/dss_clk_div_noscan/u_master_occ_div1/custom/occ_clkmux/Z [get_pins dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/atpg_PllRefClk] -add

suppress_message ENV-003
suppress_message PTE-003
suppress_message PTE-016
suppress_message PTE-018
suppress_message PTE-101
suppress_message UITE-416

##==============================================================================
## Enable reporting paths that started at inactive startpoints
##------------------------------------------------------------------------------
## From 2019.03 version of PT, inactive startpoints are ignored and
## a new variable timing_report_unconstrained_paths_from_nontimed_startpoints
## is added.
## But for extra_check, this behavioral is needed.
##==============================================================================

if {[info exists timing_report_unconstrained_paths_from_nontimed_startpoints]} {
   set reserve_value_unconstrained [get_app_var timing_report_unconstrained_paths_from_nontimed_startpoints]
   set_app_var timing_report_unconstrained_paths_from_nontimed_startpoints true
}


##==============================================================================
## Valiables setting
##==============================================================================
##-- PLL REFCLK insertion delay should be < 936ps
set PllRefClkMasterLatencyLimit 0.936

##-- PLL BypClk insertion delay should be < 936ps
set PllBpyClkMasterLatencyLimit 0.936

##-- PClk insertion delay from MASTER to ACX4 should be < 160ps
set PClkACX4LatencyLimit        0.160     

##-- PClk insertion delay from ACX4 to DBYTE should be < 280ps
set PClkDBYTELatencyLimit       0.280

##-- PClk skew should be < 20ps
set PClkSkewLimit               0.020

##-- Max skew across DfiClk inputs of all HardIP should be < 156ps
set DfiClkAllSkewLimit          0.156

##-- Insertion delay to DfiClk inputs of all HardIP should be < 936ps
set DfiClkAllLatencyLimit       0.936

##==============================================================================
## 1.1. Pclk Latency and skew for DBYTE
##------------------------------------------------------------------------------
##    - From acx4 PclkIn pin to dbyte PclkIn input pins
##==============================================================================
##-- Note: PClk skew check must be covered by construction and SPICE simulation and follow the PNR guidance in the Implementation Guide.




##==============================================================================
## 1.2. Pclk Latency and skew for ACX4
##------------------------------------------------------------------------------
##    - From master PClkOut output pins to acx4 PclkIn input pins 
##==============================================================================
##-- Note: PClk skew check must be covered by construction and SPICE simulationand and follow the PNR guidance in the Implementation Guide.





##==============================================================================
## 2. DfiClk Latency and skew
##------------------------------------------------------------------------------
##    - From DfiClk port to all dbyte and acx4 and master DfiClk pins 
##==============================================================================
##-- begin DfiClk latency/skew for all dbyte/acx4/master macros

echo ""
echo ""
echo "Latency delay from DfiClk to all dbyte and acx4 and master DfiClk pins must be less than 936ps" 
echo "Skew between all dbyte and acx4 and master DfiClk pins must be less than 156ps" 
set endp   [get_pins *u_DWC_DDRPHYDBYTE_*/DfiClk -hier]
append_to_collection endp [get_pins *u_DWC_DDRPHYACX4_*/DfiClk -hier]
append_to_collection endp [get_pins *u_DWC_DDRPHYMASTER_top*/DfiClk -hier]
append_to_collection endp   [get_pins *u_DWC_DDRPHYMASTER_top/PllRefClk -hier]
set num_endp [sizeof_collection $endp]
set startp [get_pins dwc_ddrphy_pnr_block/pll_mem_clk]
set tp     [get_timing_path -path full_clock_expanded -from $startp -rise_to $endp -max 10000 -nworst 10000 -delay max -slack_lesser_than infinity]
#report_timing -path full_clock_expanded -from $startp -rise_to $endp -max 10000 -nworst 10000 -delay max -slack_lesser_than infinity > 2.DfiClk.rpt

echo "Reporting DfiClk latency and skew to the following $num_endp pins"
report_latency_skew_endpoints $tp "DfiClk" ${DfiClkAllLatencyLimit} ${DfiClkAllSkewLimit}

##-- end DfiClk latency/skew for all dbyte/acx4/master macros


##==============================================================================
## 3. PllRefClk Latency
##------------------------------------------------------------------------------
##    - From port atpg_PllRefClk to master input pin PllRefClk 
##==============================================================================

if {0} {
##-- begin PllRefClk latency to master
echo ""
echo ""
echo "Latency delay from port atpg_PllRefClk to master input pin PllRefClk must be less than 936ps" 
set endp   [get_pins *u_DWC_DDRPHYMASTER_top/PllRefClk -hier]
set startp [get_pins dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/atpg_PllRefClk]
#lioral#report_timing -path full_clock_expanded -from $startp -rise_to $endp -delay max -slack_lesser_than infinity > 3.atpg_PllRefClk.rpt
set tp     [get_timing_path -path full_clock_expanded -from $startp -rise_to $endp -delay max -slack_lesser_than infinity]
set masterPllRefClk_arrival [get_attr $tp arrival]
echo "     PllRefClk Arrival to u_DWC_DDRPHYMASTER_top/PllRefClk: $masterPllRefClk_arrival"
echo "     PllRefClk Master Latency Limit: $PllRefClkMasterLatencyLimit "
set latency_slack [expr $PllRefClkMasterLatencyLimit - $masterPllRefClk_arrival]
if { $latency_slack < 0 } {
    echo "     latency slack (VIOLATED):   $latency_slack "
} else {
    echo "     latency slack (PASS):   $latency_slack "
}
##-- end PllRefClk latency to master
}

##==============================================================================
## 4. PllBypClk Latency
##------------------------------------------------------------------------------
##    - From port PllBypClk to master input pin PllBypClk 
##==============================================================================
##-- begin PllBypClk latency to master
echo ""
echo ""
echo "Latency delay from port PllBypClk to master input pin PllBypClk must be less than 936ps" 
set endp   [get_pins *u_DWC_DDRPHYMASTER_top/PllBypClk -hier]
set startp [get_pins dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/PllBypClk]
#lioral#report_timing -path_type full_clock_expanded -through $startp -rise_to $endp -delay max -slack_lesser_than infinity > 4.PllBypClk.rpt
set tp     [get_timing_path -path_type full_clock_expanded -through $startp -rise_to $endp -delay max -slack_lesser_than infinity]
set masterPllBypClk_arrival [get_attr $tp arrival]
echo "     PllBypClk Arrival to u_DWC_DDRPHYMASTER_top/PllBypClk: $masterPllBypClk_arrival"
echo "     PllBypClk Master Latency Limit: $PllBpyClkMasterLatencyLimit "
set latency_slack [expr $PllBpyClkMasterLatencyLimit - $masterPllBypClk_arrival]
if { $latency_slack < 0 } {
    echo "     latency slack (VIOLATED):   $latency_slack "
} else {
    echo "     latency slack (PASS):   $latency_slack "
}

##-- end PllBypClk latency to master


##==============================================================================
## 5. Skew between DfiClk and PllRefClk
##------------------------------------------------------------------------------
##   5.1 Latency from port DfiClk to master input pin PllRefClk should be shorter than
##       the latency from port DfiClk to all HardIP's DfiClk pins 
##   5.2 Latency from port PllRefClk to master input pin PllRefClk should be shorter
##       than the latency from port DfiClk to all HardIP's DfiClk pins 
##==============================================================================
##-- begin skew check between DfiClk and PllRefClk
echo ""
echo ""
#set stp [get_pins dwc_ddrphy_pnr_block/dss_clocks/dss_clocks_xclk/phy_ref_clk_mx/cn_clk_mux_v1_0_inst/clkmux2/Z]
set stp  [get_pins dwc_ddrphy_pnr_block/pll_mem_clk]
echo "Latency from port DfiClk to master input pin PllRefClk should be shortest among the paths from port DfiClk to all HardIP's DfiClk pins and master input pin PllRefClk"
set endp   [get_pins *u_DWC_DDRPHYMASTER_top/PllRefClk -hier]
#set startp [get_port DfiClk]
#lioral#report_timing -path full_clock_expanded -from $stp -rise_to $endp -delay max -slack_lesser_than infinity > 5.1_func_PllRefClk.rpt
set tp     [get_timing_path -path full_clock_expanded -from $stp -rise_to $endp -delay max -slack_lesser_than infinity]

set DfiClk_to_mPllRefClk [get_attr $tp arrival]
echo "     Latency from port DfiClk to u_DWC_DDRPHYMASTER_top/PllRefClk: $DfiClk_to_mPllRefClk"

set endp   [get_pins *u_DWC_DDRPHYMASTER_top/PllRefClk -hier]
set stp [get_pins dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/atpg_PllRefClk]
#lioral#report_timing -path full_clock_expanded -from $stp -rise_to $endp -delay max -slack_lesser_than infinity > 5.2_atpg_PllRefClk.rpt
set tp     [get_timing_path -path full_clock_expanded -from $stp -rise_to $endp -delay max -slack_lesser_than infinity]

set PllRefClk_to_mPllRefClk [get_attr $tp arrival]
echo "     Latency from port atpg_PllRefClk to u_DWC_DDRPHYMASTER_top/PllRefClk: $PllRefClk_to_mPllRefClk"




set endp   [get_pins *u_DWC_DDRPHYDBYTE_*/DfiClk -hier]
append_to_collection endp [get_pins *u_DWC_DDRPHYACX4_*/DfiClk -hier]
append_to_collection endp [get_pins *u_DWC_DDRPHYMASTER_top*/DfiClk -hier]
set num_endp [sizeof_collection $endp]
#set startp [get_port DfiClk]
#set startp [get_pins dwc_ddrphy_pnr_block/dss_clocks/dss_clocks_xclk/phy_ref_clk_mx/cn_clk_mux_v1_0_inst/clkmux2/Z]
set startp [get_pins dwc_ddrphy_pnr_block/pll_mem_clk]
#lioral#report_timing -path full_clock_expanded -from $startp -rise_to $endp -max 10000 -nworst 10000 -delay max -slack_lesser_than infinity > 5.2_dfi_clk.rpt
set tp     [get_timing_path -path full_clock_expanded -from $startp -rise_to $endp -max 10000 -nworst 10000 -delay max -slack_lesser_than infinity]

echo "Reporting DfiClk latency from DfiClk port to the following $num_endp pins"

set DfiClk_max_min_latency [report_latency $tp "DfiClk"]
set DfiClk_max_latency [lindex $DfiClk_max_min_latency 0]
set DfiClk_min_latency [lindex $DfiClk_max_min_latency 1]
echo "The shortest latency from DfiClk port to All HardIP's DfiClk input pin is : $DfiClk_min_latency "
echo ""
echo ""


set latency_slack [expr $DfiClk_min_latency - $DfiClk_to_mPllRefClk]

echo "Check the latency from port DfiClk to u_DWC_DDRPHYMASTER_top/PllRefClk should be shorter than the latency from port DfiClk to All HardIP's DfiClk pin:  "
if { $latency_slack < 0 } {
    echo "     latency slack (VIOLATED):  $latency_slack "
} else {
    echo "     latency slack (MET):  $latency_slack "
}

if {0} {
set latency_slack [expr $DfiClk_min_latency - $PllRefClk_to_mPllRefClk ]
echo "Check the latency from port atpg_PllRefClk to u_DWC_DDRPHYMASTER_top/PllRefClk should be shorter than the latency from port DfiClk to All HardIP's DfiClk pin: "
if { $latency_slack > 0 } {
    echo "     latency slack (MET):  $latency_slack "
} else {
    echo "     latency slack (VIOLATION):  $latency_slack "
}   
}

##-- end skew check between DfiClk and PllRefClk



##==============================================================================
## Unsuppress messages that suppressed during special checks
##==============================================================================
unsuppress_message ENV-003
unsuppress_message PTE-003
unsuppress_message PTE-016
unsuppress_message PTE-018
unsuppress_message PTE-101
unsuppress_message UITE-416

echo "\n"

##==============================================================================
## Recover setting for reporting paths that started at inactive startpoints
##==============================================================================

if {[info exists timing_report_unconstrained_paths_from_nontimed_startpoints]} {
   set_app_var timing_report_unconstrained_paths_from_nontimed_startpoints ${reserve_value_unconstrained}
}


echo "\n"
