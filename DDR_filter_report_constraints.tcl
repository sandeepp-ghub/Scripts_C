#======================================================================#
# setting the filter regexp list for each type of report               #
#======================================================================#
set clock_tree_pulse_width_filter_list {
}
set sequential_clock_min_period_filter_list {
}
set sequential_clock_pulse_width_filter_list {
}
set min_capacitance_filter_list {
}
set min_transition_filter_list {
}

#=======================================================================#
# added procs if needed get $slack $Related_clock $pin                  #
# return 1/0 when 1 is to filter                                        #
#=======================================================================#

set min_capacitance_CMD {
# filter cap < -1p
if {$slack > -0.001} {set CMD_result 1; }
}

set sequential_clock_pulse_width_CMD {

set pidi_pin_list {
}
if {[regexp $pin $pidi_pin_list]} {
#    echo DEBUG: $pin
    if {$Related_clock eq "pidi_apll_clk0"} {set CMD_result 1;}
    if {$Related_clock eq "pidi_apll_clk1"} {set CMD_result 1;}
}


# ddr clock uncert is too high moving from -80 to -60
set ddr_phys_pin_list {
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x3_DDR1/u_DWC_DDRPHYACX4_0/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x3_DDR1/u_DWC_DDRPHYACX4_1/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x3_DDR1/u_DWC_DDRPHYACX4_2/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x7_DDR1/u_DWC_DDRPHYACX4_3/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x7_DDR1/u_DWC_DDRPHYACX4_4/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x7_DDR1/u_DWC_DDRPHYACX4_5/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x7_DDR1/u_DWC_DDRPHYACX4_6/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x7_DDR1/u_DWC_DDRPHYACX4_7/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x7_DDR1/u_DWC_DDRPHYACX4_8/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/DDRPHYACX4_x7_DDR1/u_DWC_DDRPHYACX4_9/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_v_w_bumps_7/u_DWC_DDRPHYDBYTE/atpg_RDQSClk
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_4/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_5/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x3_DDR0/u_DWC_DDRPHYACX4_0/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x3_DDR0/u_DWC_DDRPHYACX4_1/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x3_DDR0/u_DWC_DDRPHYACX4_2/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x7_DDR0/u_DWC_DDRPHYACX4_3/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x7_DDR0/u_DWC_DDRPHYACX4_4/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x7_DDR0/u_DWC_DDRPHYACX4_5/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x7_DDR0/u_DWC_DDRPHYACX4_6/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x7_DDR0/u_DWC_DDRPHYACX4_7/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x7_DDR0/u_DWC_DDRPHYACX4_8/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/DDRPHYACX4_x7_DDR0/u_DWC_DDRPHYACX4_9/PclkIncheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_4/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_5/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_6/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_7/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_8/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_v_w_bumps_0/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_v_w_bumps_1/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_v_w_bumps_6/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_v_w_bumps_7/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_2/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_3/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top_0/dwddrphy_core_top/u_DWC_DDRPHYMASTER_w_bumps_top/u_DWC_DDRPHYMASTER_top/Pclkcheckpin1
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_v_w_bumps_0/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_1/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_2/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_3/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYDBYTE_w_bumps_8/u_DWC_DDRPHYDBYTE/PclkIn
apn810_dss_phy_analog/dwddrphy_top/dwddrphy_core_top/u_DWC_DDRPHYMASTER_w_bumps_top/u_DWC_DDRPHYMASTER_top/Pclkcheckpin1
}

if {[regexp $pin $ddr_phys_pin_list]} {
    if {$clock_uncertainty <=-0.08} {
        set new_slack [expr $slack + 0.02 ] ;# moving from -80p uncr to -60
        if {$clock_uncertainty <=-0.01} {set new_slack [expr $new_slack +0.02]};# moving from -100p uncr to -60  
        if {$new_slack > 0} {set CMD_result 1; }
    } 
}

# filter slack  > -1p
if {$slack > -0.001} {set CMD_result 1; }

}


set clock_tree_pulse_width_CMD {
set ddr_phys_pin_list {
}

if {[regexp $pin $ddr_phys_pin_list]} {
#    echo $clock_uncertainty
#    echo $slack
    if {$clock_uncertainty <=-0.08} {
        set new_slack [expr $slack + 0.02 ] ;# moving from -80p uncr to -60
        if {$clock_uncertainty <=-0.01} {set new_slack [expr $new_slack +0.02]};# moving from -100p uncr to -60  
        if {$new_slack > 0} {set CMD_result 1; }
    } 
}

}


set sequential_clock_min_period_CMD {
# filter slack  > -1p
if {$slack > -0.001} {set CMD_result 1; }

}

#=========================================================================#
# start of main proc                                                      #
#=========================================================================#
proc filter_report_constraing {input_file } {

#set  debug                             [open  report_constraint_debug.rpt  w]
set  sequential_clock_pulse_widthFILE  [open  sequential_clock_pulse_width.rpt  w]
set  min_capacitanceFILE               [open  min_capacitance.rpt               w]
set  min_transitionFILE                [open  min_transition.rpt                w]
set  max_fanoutFILE                    [open  max_fanout.rpt                    w]
set  othersFILE                        [open  others.rpt                        w]
set clock_tree_pulse_widthFILE         [open clock_tree_pulse_width.rpt         w]
set sequential_clock_min_periodFILE    [open sequential_clock_min_period.rpt    w]

set  sequential_clock_pulse_widthFILE_filtered  [open  sequential_clock_pulse_width_filtered.rpt  w]
set  min_capacitanceFILE_filtered               [open  min_capacitance_filtered.rpt               w]
set  min_transitionFILE_filtered                [open  min_transition_filtered.rpt                w]
set sequential_clock_min_periodFILE_filtered    [open  sequential_clock_min_period_filtered.rpt   w]
set clock_tree_pulse_widthFILE_filtered         [open clock_tree_pulse_width_filtered.rpt         w]

global clock_tree_pulse_width_filter_list;
global sequential_clock_min_period_filter_list;
global sequential_clock_pulse_width_filter_list;
global min_capacitance_filter_list;
global min_transition_filter_list;
global sequential_clock_pulse_width_CMD;
global min_capacitance_CMD;
global clock_tree_pulse_width_CMD;
global sequential_clock_min_period_CMD;


    set infile   [open $input_file r]
    while {[gets $infile line] >= 0}  {
#=======================================================================#
# going over the report lappend report starting with Pin and with slack #
# finding the type of report we are reading.                            #
#=======================================================================#
        if {[regexp {(Pin: )(.*$)} $line -> a pin]} {
            set bufLine "$line"; # not sure way but the Pin line take the first two lines as one line adding space to keep the line counte
            lappend bufLine " \n"
            set sequential_clock_pulse_width 0
            set min_capacitance              0
            set max_fanout                   0
            set min_transition               0
            set clock_tree_pulse_width       0
        } else {
            lappend bufLine "$line\n"
        }

        if {[regexp {sequential_clock_pulse_width} $line]} {
            set sequential_clock_pulse_width 1
        }
        if {[regexp {min_capacitance} $line]} {
            set min_capacitance 1
        }
        if {[regexp {max_fanout} $line]} {
            set max_fanout 1
        }
        if {[regexp {min_transition} $line]} {
            set min_transition 1
        }
        if {[regexp {clock_tree_pulse_width} $line]} {
            set clock_tree_pulse_width 1
        }
        if {[regexp {sequential_clock_min_period} $line]} {
            set sequential_clock_min_period 1
        }
        if {[regexp {(Related clock: )(.*)} $line -> a clk]} {
            set Related_clock $clk
        }
        if {[regexp {(clock uncertainty.* )(-......)} $line -> a unc]} {
            set clock_uncertainty $unc
        }
#====================================================================#
# getting to the end of one report this is the time to see if        #
# to print it to filter reports or remining report                   #
#====================================================================#
        if {[regexp {([sS]lack.+?)(-......)} $line -> a slack]} {
            #-- filter can be triger from regexp to list or eval user writen CMD that return CMD_result
            set CMD_result 0;
            #-- remove  { } from print 
            regsub -all {\{|\}} $bufLine {} bufLine 
#-- sequential_clock_pulse_width --#
            if {$sequential_clock_pulse_width} {
                eval $sequential_clock_pulse_width_CMD
                if {$CMD_result} {
                    puts $sequential_clock_pulse_widthFILE_filtered $bufLine 
                } elseif {[filterReport $pin $sequential_clock_pulse_width_filter_list ]} {              
                    puts $sequential_clock_pulse_widthFILE_filtered $bufLine
                } else {
                    puts $sequential_clock_pulse_widthFILE          $bufLine
                }
#-- min_capacitance             --#
            } elseif {$min_capacitance} {
                eval $min_capacitance_CMD
                if {$CMD_result} { 
                    puts $min_capacitanceFILE_filtered $bufLine
                    puts $min_capacitanceFILE_filtered "\n" ;# report have two space after min cap report
                } elseif {[filterReport $pin $min_capacitance_filter_list ]} {
                    puts $min_capacitanceFILE_filtered $bufLine
                    puts $min_capacitanceFILE_filtered "\n" ;# report have two space after min cap report
                } else {
                    puts $min_capacitanceFILE $bufLine  
                    puts $min_capacitanceFILE "\n" ;# report have two space after min cap report
                }
#-- max fanout                  --#                
            } elseif {$max_fanout} {
                puts $max_fanoutFILE $bufLine
#-- min_transition              --#
            } elseif {$min_transition} {
                if {[filterReport $pin $min_transition_filter_list ]} {
                    puts $min_transitionFILE_filtered $bufLine
                } else {
                    puts $min_transitionFILE $bufLine  
                }
#--  clock_tree_pulse_width     --#               
            } elseif {$clock_tree_pulse_width} {
                eval $clock_tree_pulse_width_CMD
                if {$CMD_result} {                    
                    puts $clock_tree_pulse_widthFILE_filtered $bufLine
                } elseif {[filterReport $pin $clock_tree_pulse_width_filter_list]} {
                    puts $clock_tree_pulse_widthFILE_filtered $bufLine
                } else {
                    puts $clock_tree_pulse_widthFILE $bufLine
                }
#-- sequential_clock_min_period --#               
            } elseif {$sequential_clock_min_period} {
                eval $sequential_clock_min_period_CMD
                if ($CMD_result) {
                    puts $sequential_clock_min_periodFILE_filtered $bufLine
                } elseif {[filterReport $pin $sequential_clock_min_period_filter_list ]} {
                    puts $sequential_clock_min_periodFILE_filtered $bufLine
                } else {
                    puts $sequential_clock_min_periodFILE $bufLine
                }
            } else {
#-- other                       --#                
                puts $othersFILE $bufLine  
            }
            
        }

    };# end of in file


close  $sequential_clock_pulse_widthFILE;
close  $min_capacitanceFILE;              
close  $min_transitionFILE;
close  $max_fanoutFILE;
close  $othersFILE;
close  $clock_tree_pulse_widthFILE;
close  $clock_tree_pulse_widthFILE_filtered;
close  $sequential_clock_pulse_widthFILE_filtered;
close  $min_capacitanceFILE_filtered;
close  $min_transitionFILE_filtered;
close  $sequential_clock_min_periodFILE_filtered;
close  $sequential_clock_min_periodFILE;
#close  $debug;
#close  $sequential_clock_pulse_width_filtr;
#close  $min_capacitance_filtr;             
#close  $min_transition_filtr;
};#end of proc


proc filterReport {pin  flist} {
    set f 0
    foreach fl $flist {
        if {[regexp $fl $pin]} {set f 1}
    }
return $f

}



set root_dir "/nfs/pt/store/project_store141/store_apn810_a1_main/USERS/lioral/Model_A1_BE_Exploration/MODELS/Backend/apn810/sta/r0/report/"
set reports_list {
setup/func_ls/slowgnp_0.8_-40/WC_CCW_T_-40/apn810.report_constraint
setup/func_ls/slowgnp_0.8_-40/WRC_CCW_T_-40/apn810.report_constraint
setup/func_ls/slowgnp_0.8_125/WRC_CCW_T_110/apn810.report_constraint
setup/func_ls/slowgnp_0.8_125/WC_CCW_T_110/apn810.report_constraint
setup/func_hs/slowgnp_0.9_125/WRC_CCW_T_110/apn810.report_constraint
setup/func_hs/slowgnp_0.9_125/WC_CCW_T_110/apn810.report_constraint
setup/func_hs/slowgnp_0.9_-40/WRC_CCW_T_-40/apn810.report_constraint
setup/func_hs/slowgnp_0.9_-40/WC_CCW_T_-40/apn810.report_constraint
setup/func_hs_typ/typ_0.8_25/WC_CCW_T_-40/apn810.report_constraint
setup/func_hs_typ/typ_0.8_25/WRC_CCW_T_-40/apn810.report_constraint
setup/func_hs_typ/typ_0.8_85/WRC_CCW_T_110/apn810.report_constraint
setup/func_hs_typ/typ_0.8_85/WC_CCW_T_110/apn810.report_constraint
setup/func_lls/slowgnp_0.72_125/WC_CCW_125/apn810.report_constraint
setup/func_lls/slowgnp_0.72_125/WRC_CCW_125/apn810.report_constraint
setup/func_lls/slowgnp_0.72_-40/WC_CCW_-40/apn810.report_constraint
setup/func_lls/slowgnp_0.72_-40/WRC_CCW_-40/apn810.report_constraint
hold/scan/fastgnp_1.05_125/WC_CCW_125/apn810.report_constraint
hold/scan/fastgnp_1.05_-40/WC_CCW_-40/apn810.report_constraint
hold/func_hs/fastgnp_1.05_125/WC_CCW_125/apn810.report_constraint
hold/func_hs/fastgnp_1.05_125/WRC_CCW_125/apn810.report_constraint
hold/func_hs/fastgnp_1.05_125/BC_CCB_125/apn810.report_constraint
hold/func_hs/fastgnp_1.05_125/BRC_CCB_125/apn810.report_constraint
hold/func_hs/fastgnp_1.05_-40/WC_CCW_-40/apn810.report_constraint
hold/func_hs/fastgnp_1.05_-40/WRC_CCW_-40/apn810.report_constraint
hold/func_hs/fastgnp_1.05_-40/BC_CCB_-40/apn810.report_constraint
hold/func_hs/fastgnp_1.05_-40/BRC_CCB_-40/apn810.report_constraint
hold/func_hs/fastgnp_0.88_-40/BRC_CCB_-40/apn810.report_constraint
hold/func_hs/fastgnp_0.88_-40/BC_CCB_-40/apn810.report_constraint
hold/func_hs/typ_1.0_85/TC_85/apn810.report_constraint
hold/func_hs/typ_0.8_85/TC_85/apn810.report_constraint
hold/func_lls/slowgnp_0.72_125/WC_CCW_125/apn810.report_constraint
hold/func_lls/slowgnp_0.72_125/WRC_CCW_125/apn810.report_constraint
hold/func_lls/slowgnp_0.72_-40/WRC_CCW_-40/apn810.report_constraint
hold/func_lls/slowgnp_0.72_-40/WC_CCW_-40/apn810.report_constraint
}


set root_dir "/nfs/pt/store/project_store141/store_apn810_a1_main/USERS/gshay/Model_A1_BE_Exploration/MODELS/Backend/apn810/sta/apn810_FC_STA_Jun28/report/"
set reports_list {
setup/func_lls/slowgnp_0.72_125/WRC_CCW_T_110/apn810.report_constraint
setup/func_hs/slowgnp_0.9_125/WRC_CCW_T_110/apn810.report_constraint
hold/func_hs/fastgnp_1.05_125/WRC_CCW_125/apn810.report_constraint
setup/func_ls/slowgnp_0.8_125/WRC_CCW_T_110/apn810.report_constraint
}




foreach report $reports_list {
    set work_dir [join [split  [regsub {/apn810.report_constraint} $report {} ] "/"] "_"]
#echo $work_dir
    file delete -force $work_dir
    file mkdir  $work_dir
    cd $work_dir
    file copy ${root_dir}$report ./
    filter_report_constraing  ${root_dir}$report
    cd ..
}


