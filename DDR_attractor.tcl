set blocks [get_db insts -if {.base_cell==*dwc_ddrphydbyte_top_ew* || .base_cell==*dwc_ddrphyacx4_top_ew* || .base_cell==*dwc_ddrphymaster_top*}]
#foreach b $blocks {
    set bn [get_db $blocks .name]
    puts "Info:: Setting $bn as an attractor "
    place_connected -attractor $bn -sequential all_connected
#}
