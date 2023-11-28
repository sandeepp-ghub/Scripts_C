set d 1
set blocks [get_db insts -if {.base_cell==*dwc_ddrphydbyte_top_ew* || .base_cell==*dwc_ddrphyacx4_top_ew* || .base_cell==*dwc_ddrphymaster_top* || .base_cell==*decapvddq*}]
foreach b $blocks {
    set x0 [get_db $b .bbox.ll.x] 
    set y0 [get_db $b .bbox.ll.y]
    set x1 [get_db $b .bbox.ur.x]
    set y1 [get_db $b .bbox.ur.y]
    create_route_blockage -all {route cut} -pg_nets -name PHY_PG_BLOCK -rects "$x0 $y0 $x1 $y1"
    
    set x0l [expr $x0 - $d ]
    set y0l [expr $y0 - $d ]
    set x1l [expr $x0 - 0  ]
    set y1l [expr $y1 + $d ]
    create_route_blockage -all {route cut} -pg_nets -name PHY_PG_BLOCK -rects "$x0l $y0l $x1l $y1l"

    set x0r [expr $x1 - 0  ]
    set y0r [expr $y0 - $d ]
    set x1r [expr $x1 + $d ]
    set y1r [expr $y1 + $d ]
    create_route_blockage -all {route cut} -pg_nets -name PHY_PG_BLOCK -rects "$x0r $y0r $x1r $y1r"

    set x0u [expr $x0 - $d ]
    set y0u [expr $y1 - 0  ]
    set x1u [expr $x1 + $d ]
    set y1u [expr $y1 + $d ]
    create_route_blockage -all {route cut} -pg_nets -name PHY_PG_BLOCK -rects "$x0u $y0u $x1u $y1u"

    set x0d [expr $x0 - $d ]
    set y0d [expr $y0 - $d ]
    set x1d [expr $x1 + $d ]
    set y1d [expr $y0 + 0  ] 
    create_route_blockage -all {route cut} -pg_nets -name PHY_PG_BLOCK -rects "$x0d $y0d $x1d $y1d"
}

create_route_blockage -all {route cut} -pg_nets -name CORNER_PG_BLOCK_2 -rects "0 0 120 3787"
create_route_blockage -all {route cut} -pg_nets -name CORNER_PG_BLOCK_1 -rects "1179 496 1466 501"
create_route_blockage -all {route cut} -pg_nets -name CORNER_PG_BLOCK_3 -rects "1179.46 0 1536.0465 504.0"
create_route_blockage -all {route cut} -pg_nets -name PG_BLOCK_4 -rects "627.504 85.904 977 580"

foreach box {
	{0 0 354.858 71.732}
	{0 0 354.015 3789.5}
	{0 1647 483.99 3789.5}
	{1176.009 496.622 1179.446 502.348}
} {
	create_route_blockage -layers {M0 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14} -pg_nets -name CH_PG_BLOCK -rects $box  
}

create_route_blockage -layers {M0 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16} -pg_nets -name CH_PG_BLOCK -rects "122.8305 239.081 353.379 251.104"

foreach b [get_db insts -if {.base_cell==*ESD*}] {
    set x0 [expr [get_db $b .bbox.ll.x] - 0] 
    set y0 [expr [get_db $b .bbox.ll.y] - 1]
    set x1 [expr [get_db $b .bbox.ur.x] - 0]
    set y1 [expr [get_db $b .bbox.ur.y] + 1]
    create_route_blockage -layers {M0 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15} -pg_nets -name ESD_PG_BLOCK -rects "$x0 $y0 $x1 $y1"    
}
