
set nets [get_db nets dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/*VIO*]
foreach net $nets {

    set driver [get_db $net .drivers]
    set loads  [get_db $net .loads]
    set wires  [get_db $net .wires]
    set nname  [get_db $net .name]
    if {$loads  eq ""} {continue}
    if {$driver eq ""} {continue}
    if {$wires eq "" } {continue}
    if {[llength $loads] > 1} {echo "more then one load; continue"}

    set driver_layer [get_db $driver .layer.name]
    set loads_layer  [get_db $loads  .layer.name]
    if {$driver_layer ne $loads_layer} {
        puts "pins not at same layer"
        continue
    } else {
        set layer $driver_layer
    }

#set dloc [get_db $driver .location]
    set dloc [lindex [get_db $driver .location] 0]
    set dlength [get_db $driver .base_pin.physical_pins.layer_shapes.shapes.rect.length]
    set dwidth  [get_db $driver .base_pin.physical_pins.layer_shapes.shapes.rect.width]
    set x0 [expr [lindex $dloc 0] - ($dlength / 2)]  
    set y0 [expr [lindex $dloc 1] - ($dwidth  / 2)]
    set x1 [expr [lindex $dloc 0] + ($dlength / 2)]
    set y1 [expr [lindex $dloc 1] + ($dwidth  / 2)]
    set driver_box "${x0} ${y0} ${x1} ${y1}"

    set rloc [lindex [get_db $loads .location] 0]
    set rlength [get_db $loads .base_pin.physical_pins.layer_shapes.shapes.rect.length]
    set rwidth  [get_db $loads .base_pin.physical_pins.layer_shapes.shapes.rect.width]
    set x0 [expr [lindex $rloc 0] - ($rlength / 2)]
    set y0 [expr [lindex $rloc 1] - ($rwidth  / 2)]
    set x1 [expr [lindex $rloc 0] + ($rlength / 2)]
    set y1 [expr [lindex $rloc 1] + ($rwidth  / 2)]
    set load_box "${x0} ${y0} ${x1} ${y1}"


    set ts [get_computed_shapes  "\{$driver_box\}" OR  "\{$load_box\}" BBOX]

    foreach wire $wires {
        delete_obj $wire
    }
    create_shape -net $nname -layer $layer -rect $ts


}
