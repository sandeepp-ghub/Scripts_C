# remove sinks from existing skew groups

set sg_sink_pins [get_db pins [get_object_name [all_registers -clock bclk -clock_pins ]]]

set i 0
set sg_list ""
foreach sg_sink_pin $sg_sink_pins {
   foreach sg [get_db $sg_sink_pin .cts_skew_groups_active_sink -if {.name!=bclk/*}] {
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
