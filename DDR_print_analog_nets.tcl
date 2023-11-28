

proc report_analog_pins {} {
    pl [get_db [get_db insts -if {.base_cell==*dwc_ddrphydbyte_top_ew* || .base_cell==*dwc_ddrphyacx4_top_ew* || .base_cell==*dwc_ddrphymaster_top*}] .pins -if {.layer==*M14}]
}


