# remove sinks from existing skew groups
#-- DfiClk --#
set sg_sink_pins [get_db pins [get_object_name [all_registers -clock DfiClk -clock_pins]]]

set i 0
set sg_list ""
foreach sg_sink_pin $sg_sink_pins {
   foreach sg [get_db $sg_sink_pin .cts_skew_groups_active_sink -if {.name!=DfiClk/*}] {
        set sg_sink_pin_name [get_db $sg_sink_pin .name]
        if {[info exists MYDB($sg)]} {
            lappend MYDB($sg) $sg_sink_pin_name
        } else {
            set MYDB($sg) $sg_sink_pin_name
            lappend sg_list $sg
        }
    }
}
foreach sg $sg_list {
    update_skew_group -skew_group $sg -remove_sinks $MYDB($sg)
}


if {0} {
#-- DfiCtlClk_1to4 --#
set sg_sink_pins [get_db pins [get_object_name [all_registers -clock DfiCtlClk_1to4 -clock_pins ]]]

set i 0
set sg_list ""
foreach sg_sink_pin $sg_sink_pins {
   foreach sg [get_db $sg_sink_pin .cts_skew_groups_active_sink -if {.name!=DfiCtlClk_1to4/*}] {
        set sg_sink_pin_name [get_db $sg_sink_pin .name]
        if {[info exists MYDB($sg)]} {
            lappend MYDB($sg) $sg_sink_pin_name
        } else {
            set MYDB($sg) $sg_sink_pin_name
            lappend sg_list $sg
        }
    }
}
foreach sg $sg_list {
    update_skew_group -skew_group $sg -remove_sinks $MYDB($sg)
}

#-- APB --#
set sg_sink_pins [get_db pins [get_object_name [all_registers -clock apb_clk_ddr5 -clock_pins ]]]

set i 0
set sg_list ""
foreach sg_sink_pin $sg_sink_pins {
   foreach sg [get_db $sg_sink_pin .cts_skew_groups_active_sink -if {.name!=apb_clk_ddr5/*}] {
        set sg_sink_pin_name [get_db $sg_sink_pin .name]
        if {[info exists MYDB($sg)]} {
            lappend MYDB($sg) $sg_sink_pin_name
        } else {
            set MYDB($sg) $sg_sink_pin_name
            lappend sg_list $sg
        }
    }
}
foreach sg $sg_list {
    update_skew_group -skew_group $sg -remove_sinks $MYDB($sg)
}

} ;# end of if0

puts "Add the dfi clock back to the skew game"
set_db [get_db skew_groups DfiClk*] .cts_skew_group_constrains "ccopt_initial icts"

#puts "Add the DfiCtlClk_1to4 clock back to the skew game"
#set_db [get_db skew_groups DfiCtlClk_1to4*] .cts_skew_group_constrains "ccopt_initial icts"

#puts "Add the apb_clk_ddr5 clock back to the skew game"
#set_db [get_db skew_groups apb_clk_ddr5*] .cts_skew_group_constrains "ccopt_initial icts"

if {[get_db [get_db skew_groups my_master_clock] .name] == ""} {
puts "\nAvi create skew_groups master_clock"
set cmd "create_skew_group -name my_master_clock -rank 1 -sinks {dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/u_DWC_DDRPHYMASTER_top/PllRefClk} -sources dss_clocks/dss_clocks_xclk/phy_ref_clk_mx/cn_clk_mux_v1_0_inst/clkmux2/Z"
puts $cmd ; eval $cmd
set cmd "create_skew_group -name my_master_clock_2 -rank 1 -sinks {dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/u_DWC_DDRPHYMASTER_top/PllBypClk} -sources dss_clocks/dss_clocks_xclk/phy_ref_clk_mx/cn_clk_mux_v1_0_inst/clkmux2/Z"
puts $cmd ; eval $cmd
} 


if {[get_db [get_db skew_groups my_early_clock] .name] == ""} {
puts "\nAvi create skew_groups my_early_clock"
set cmd "create_skew_group -name my_early_clock -rank 1 -sinks dwc_ddrphy_macro_0/mdh__blk_active_sync/drsyncr_inst/sync/gen_bit_0__rank_stage0/CK -sources dss_clocks/dss_clocks_xclk/phy_ref_clk_mx/cn_clk_mux_v1_0_inst/clkmux2/Z"
puts $cmd ; eval $cmd
} 

puts "\nReport skew_groups sinks"
foreach sg [lsort [get_db skew_groups .name]] {echo "[get_db skew_group:$sg .name] [llength [get_db skew_group:$sg .sinks_active]]"}
puts "Done\n"
