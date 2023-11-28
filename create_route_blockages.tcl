#set blocks [get_db insts -if {.base_cell==*dwc_ddrphydbyte_top_ew* || .base_cell==*dwc_ddrphyacx4_top_ew* || .base_cell==*dwc_ddrphymaster_top*}]

#set x0 [get_db [get_db selected ] .bbox.ll.x] 
#set y0 [get_db [get_db selected ] .bbox.ll.y]
#set x1 [get_db [get_db selected ] .bbox.ur.x]
#set y1 [get_db [get_db selected ] .bbox.ur.y]
#set dx0 [get_db [get_db designs ] .bbox.ll.x] 
#set dy0 [get_db [get_db designs ] .bbox.ll.y]
#set dx1 [get_db [get_db designs ] .bbox.ur.x]
#set dy1 [get_db [get_db designs ] .bbox.ur.y]

#Down:
#set yup [expr double($y0+20)]
#create_route_blockage -all {route cut} -except_pg_nets -name LIORAL -rects "${x0} ${y0} ${dx1} ${yup}"

#UP:
#set yup [expr double($y1-20)]
#create_route_blockage -all {route cut} -except_pg_nets -name LIORAL -rects "${x0} ${y1} ${dx1} ${yup}"

#}


proc set_blockage_right {} {
echo "block_right"
set x0 [get_db [get_db selected ] .bbox.ll.x] 
set y0 [get_db [get_db selected ] .bbox.ll.y]
set x1 [get_db [get_db selected ] .bbox.ur.x]
set y1 [get_db [get_db selected ] .bbox.ur.y]


set dx0 [get_db [get_db designs ] .bbox.ll.x] 
set dy0 [get_db [get_db designs ] .bbox.ll.y]
set dx1 [get_db [get_db designs ] .bbox.ur.x]
set dy1 [get_db [get_db designs ] .bbox.ur.y]
create_route_blockage -all {route cut} -except_pg_nets -name LIORAL -rects "${x1} [expr ${y0} + 0] [expr ${x1} + 10 ] [expr ${y1} - 0]"
create_place_blockage -type hard -name LIORAL -rects "${x1} ${y0} ${dx1} ${y1}"
}
gui_bind_key r -cmd "set_blockage_right"

proc set_soft_blockage_down {} {
set x0 [get_db [get_db selected ] .bbox.ll.x] 
set y0 [get_db [get_db selected ] .bbox.ll.y]
set x1 [get_db [get_db selected ] .bbox.ur.x]
set y1 [get_db [get_db selected ] .bbox.ur.y]


set dx0 [get_db [get_db designs ] .bbox.ll.x] 
set dy0 [get_db [get_db designs ] .bbox.ll.y]
set dx1 [get_db [get_db designs ] .bbox.ur.x]
set dy1 [get_db [get_db designs ] .bbox.ur.y]
create_place_blockage -type soft -name LIORAL -rects "${x0} [expr ${y0} - 40] ${dx1} ${y0}"
}
gui_bind_key x -cmd "set_soft_blockage_down"

proc set_soft_blockage_up {} {
set x0 [get_db [get_db selected ] .bbox.ll.x] 
set y0 [get_db [get_db selected ] .bbox.ll.y]
set x1 [get_db [get_db selected ] .bbox.ur.x]
set y1 [get_db [get_db selected ] .bbox.ur.y]


set dx0 [get_db [get_db designs ] .bbox.ll.x] 
set dy0 [get_db [get_db designs ] .bbox.ll.y]
set dx1 [get_db [get_db designs ] .bbox.ur.x]
set dy1 [get_db [get_db designs ] .bbox.ur.y]
create_place_blockage -type soft -name LIORAL -rects "${x0} ${y1} ${dx1} [expr ${y1} + 40]"
}
gui_bind_key s -cmd  "set_soft_blockage_up"






proc set_blockage_right {} {
echo "block_right"
set x0 [get_db [get_db selected ] .bbox.ll.x] 
set y0 [get_db [get_db selected ] .bbox.ll.y]
set x1 [get_db [get_db selected ] .bbox.ur.x]
set y1 [get_db [get_db selected ] .bbox.ur.y]


set dx0 [get_db [get_db designs ] .bbox.ll.x] 
set dy0 [get_db [get_db designs ] .bbox.ll.y]
set dx1 [get_db [get_db designs ] .bbox.ur.x]
set dy1 [get_db [get_db designs ] .bbox.ur.y]
create_route_blockage -all {route cut} -except_pg_nets -name LIORAL -rects "${x1} [expr ${y0} + 20] [expr ${x1} +65] [expr ${y1} -0]"
create_place_blockage -type hard -name LIORAL -rects "${x1} ${y0} ${dx1} ${y1}"
}
gui_bind_key r -cmd "set_blockage_right"

