proc removePowerOverPhys {} {

    set macros [get_db insts dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/u_DWC_DDR*]
    foreach macro $macros {
        set x0 [get_db $macro  .bbox.ll.x]
        set y0 [get_db $macro  .bbox.ll.y]
        set x1 [get_db $macro  .bbox.ur.x]
        set y1 [get_db $macro  .bbox.ur.y]
        set x0 [expr $x0 - 25]
        set y0 [expr $y0 - 25]
        set x1 [expr $x1 + 25]
        set y1 [expr $y1 + 25]
        trim_pg -area "\{$x0 $y0 $x1 $y1\}" -layer M16 -pattern 0 -type stripe -net VSS
        trim_pg -area "\{$x0 $y0 $x1 $y1\}" -layer M16 -pattern 0 -type stripe -net VDD
        trim_pg -area "\{$x0 $y0 $x1 $y1\}" -layer M15 -pattern 0 -type stripe -net VSS
        trim_pg -area "\{$x0 $y0 $x1 $y1\}" -layer M15 -pattern 0 -type stripe -net VDD

    }


}



