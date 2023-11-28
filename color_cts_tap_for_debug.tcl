#procedure ::inv::clock::color_cts_for_debug  {
#    -short_description "color_cts_for_debug."
#    -description       "color_cts_for_debug."
#    -example           "::inv::clock::color_cts_for_debug"
#    -args              {{args -type string -optional -multiple -description "args list"}}
#} {
#}
proc color_cts_tap_for_debug {clk num} {
    gui_clear_highlight
    set net [get_db [get_db [get_db clocks -if {.base_name==$clk}] .sources -u] .net]
     gui_highlight  $net -color yellow

    set clk3 [get_db clock_trees ${clk}*MSCTS*TAP${num}_*]
    set tap [get_db [get_db $clk3 .source] .inst]
    gui_highlight  $tap -color pink

    foreach ck $clk3 {
        set tap [get_db [get_db $ck .source] .inst]
        set sink [get_db [get_db $ck .sinks] .inst]
        set size [llength $sink]
        puts "$tap => $size "
        gui_highlight  $tap -color red
        set inp  [get_db $tap .pins -if {.direction==in} ] 
        set outp [get_db $tap .pins -if {.direction==out}]
        gui_highlight [get_db $inp .net.special_wires  ] -color yellow
        gui_highlight [get_db $outp .net.wires  ]        -color yellow

        set inst [get_db [get_db $ck .sinks] .inst]
        gui_highlight  $inst -color blue

    }
}
