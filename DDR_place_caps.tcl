set N 5
set S 0
set blocks [get_db insts -if {.base_cell==*dwc_ddrphydbyte_top_ew* || .base_cell==*dwc_ddrphyacx4_top_ew* || .base_cell==*dwc_ddrphymaster_top*}]
set rblocks   [get_db $blocks -if {.orient==r0}]
set myblocks  [get_db $blocks -if {.orient==my}]


set j 0
# set rblocks [lindex $rblocks 0]
foreach b $rblocks {
    set cap_base ""
    if {[get_db $b .base_cell.name] eq "dwc_ddrphydbyte_top_ew"} {set cap_base "dwc_ddrphy_decapvddq_dbyte_ew"; set cap_name DBYTECAP}
    if {[get_db $b .base_cell.name] eq "dwc_ddrphyacx4_top_ew"}  {set cap_base "dwc_ddrphy_decapvddq_acx4_ew";  set cap_name ACX4CAP}
    if {[get_db $b .base_cell.name] eq "dwc_ddrphymaster_top"}   {set cap_base "dwc_ddrphy_decapvddq_master";   set cap_name MSTRCAP}

    # block
    set x0 [get_db $b .bbox.ll.x] 
    set y0 [get_db $b .bbox.ll.y]
    set x1 [get_db $b .bbox.ur.x]
    set y1 [get_db $b .bbox.ur.y]
    # cap
    set dx [get_db [get_db base_cells $cap_base] .bbox.width]
    set dy [get_db [get_db base_cells $cap_base] .bbox.length]
    for {set i 0} {$i<$N} {incr i} {
        set x [expr $::FLOW(core_left_offset) + $i*$dx]
        set y $y0
        eval create_inst -cell "$cap_base" -inst "${cap_name}_${j}" -status fixed -location "\{$x $y\}"
        incr j
    }
    # Move cell.
    set x [expr $::FLOW(core_left_offset) + $N*$dx]
    set y ${y0}
    eval move_obj $b -point "\{$x $y\}"

}




foreach b $myblocks {
    set cap_base ""
    if {[get_db $b .base_cell.name] eq "dwc_ddrphydbyte_top_ew"} {set cap_base "dwc_ddrphy_decapvddq_dbyte_ew"; set cap_name DBYTECAP}
    if {[get_db $b .base_cell.name] eq "dwc_ddrphyacx4_top_ew"}  {set cap_base "dwc_ddrphy_decapvddq_acx4_ew";  set cap_name ACX4CAP}
    if {[get_db $b .base_cell.name] eq "dwc_ddrphymaster_top"}   {set cap_base "dwc_ddrphy_decapvddq_master";   set cap_name MSTRCAP}

    # block
    set x0 [get_db $b .bbox.ll.x] 
    set y0 [get_db $b .bbox.ll.y]
    set x1 [get_db $b .bbox.ur.x]
    set y1 [get_db $b .bbox.ur.y]
    # cap
    set dx [get_db [get_db base_cells $cap_base] .bbox.width]
    set dy [get_db [get_db base_cells $cap_base] .bbox.length]
    for {set i 0} {$i<$N} {incr i} {
        set x [expr $x1 + $i*$dx]
        set y $y0
        eval create_inst -cell "$cap_base" -inst "${cap_name}_${j}" -status fixed -location "\{$x $y\}"
        incr j
    }
    # Move cell.
    # set x [expr $::FLOW(core_left_offset) + $N*$dx]
    # set y ${y0}
    # eval move_obj $b -point "\{$x $y\}"
}








#proc set_blockage_right {} {
#    echo "block_right"
#    set x0 [get_db [get_db selected ] .bbox.ll.x] 
#    set y0 [get_db [get_db selected ] .bbox.ll.y]
#    set x1 [get_db [get_db selected ] .bbox.ur.x]
#    set y1 [get_db [get_db selected ] .bbox.ur.y]
#
#    set dx0 [get_db [get_db designs ] .bbox.ll.x] 
#    set dy0 [get_db [get_db designs ] .bbox.ll.y]
#    set dx1 [get_db [get_db designs ] .bbox.ur.x]
#    set dy1 [get_db [get_db designs ] .bbox.ur.y]
#    create_route_blockage -all {route cut} -except_pg_nets -name LIORAL -rects "${x1} [expr ${y0} + 20] [expr ${x1} +65] [expr ${y1} -0]"
#    create_place_blockage -type hard -name LIORAL -rects "${x1} ${y0} ${dx1} ${y1}"
#}
#gui_bind_key r -cmd "set_blockage_right"

