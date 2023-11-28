proc swPortSide {} {

    set ports [ get_db selected]
    set delList  ""
    set moveList ""

    foreach p $ports {
                set port [get_db $p .name]
                sel loc  [get_db $p .location.y]
                puts "  delete_routes -physical_pin -net $p \n \n"
                delete_routes -physical_pin -net $port

create_physical_pin -name $port -net $port -layer M6 -rect 1092.606 1691.66 1092.981 1691.7 -same_port 

#foreach_in_collection  pp [get_pins -of [get_nets -of $p] -leaf] {
#set cell [get_object_name [get_cells -of $pp]]
#set ref  [get_property [get_cells -of $pp] ref_name]


            set pin  [get_object_name $pp]
            set port [get_object_name $p]

            if {$ref eq "dwc_ddrphydbyte_top_ew" || $ref eq "dwc_ddrphyacx4_top_ew" || $ref eq "dwc_ddrphymaster_top"} {
                puts $cell
                puts $ref
                puts $pin
                puts $port
                set x_coordinate [get_property $pp x_coordinate]
                set y_coordinate [get_property $pp y_coordinate]
                set x_coordinate1 [expr $x_coordinate + 5]
                set y_coordinate1 [expr $y_coordinate + 5]
                set delList  "$delList  delete_routes -physical_pin -net $port \n \n"
                delete_routes -physical_pin -net $port
                set moveList "$moveList createPhysicalPin $port -net $port -geom M8 $x_coordinate $y_coordinate $x_coordinate1 $y_coordinate1 -samePort \n \n"
                create_physical_pin -name $port -net $port -layer M8 -rect $x_coordinate $y_coordinate $x_coordinate1 $y_coordinate1 -same_port
            
            }
        }
    }
}
