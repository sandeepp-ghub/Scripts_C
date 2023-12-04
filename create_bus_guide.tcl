
set inst_name {msh_msf_iob0 msh_msf_iob1}
set i 0
foreach cell $inst_name {
    set bbox [get_db [get_db insts $cell] .bbox]
    set ll_x [get_db [get_db insts $cell] .bbox.ll.x]
    set ll_y [get_db [get_db insts $cell] .bbox.ll.y]
    set tr_x [get_db [get_db insts $cell] .bbox.ur.x]
    set tr_y [get_db [get_db insts $cell] .bbox.ur.y]

    set top_pins [get_db [get_db insts $cell] .pins -if " (.location.x >= [expr $ll_x + 14 ]) && ( .location.y > [expr $tr_y - 5] ) " ]
    set bottom_pins [get_db [get_db insts $cell] .pins -if " (.location.x >= [expr $ll_x + 14 ]) && ( .location.y < [expr $ll_y + 5] ) " ]
    
create_net_group -name ${cell}_$i -nets [get_db [get_db $top_pins ] .net.name ] 
set rect1 "$ll_x [expr $tr_y - 1 ] $tr_x [expr $tr_y + 29 ] "
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer [lsort -u [get_db $top_pins .layer.name] ]
incr i

create_net_group -name ${cell}_$i -nets [get_db [get_db $bottom_pins ] .net.name ] 
set rect1 "$ll_x [expr $ll_y - 290 ]  $tr_x [expr $ll_y + 1 ]  "
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer [lsort -u [get_db $bottom_pins .layer.name] ]
incr i


}


set inst_name {msh_msf_ocx0 msh_msf_ocx1}
set i 0
foreach cell $inst_name {
    set bbox [get_db [get_db insts $cell] .bbox]
    set ll_x [get_db [get_db insts $cell] .bbox.ll.x]
    set ll_y [get_db [get_db insts $cell] .bbox.ll.y]
    set tr_x [get_db [get_db insts $cell] .bbox.ur.x]
    set tr_y [get_db [get_db insts $cell] .bbox.ur.y]

    set top_pins [get_db [get_db insts $cell] .pins -if " (.location.x >= [expr $ll_x + 14 ]) && ( .location.y > [expr $tr_y - 5] ) " ]
    set bottom_pins [get_db [get_db insts $cell] .pins -if " (.location.x >= [expr $ll_x + 14 ]) && ( .location.y < [expr $ll_y + 5] ) " ]
    
create_net_group -name ${cell}_$i -nets [get_db [get_db $top_pins ] .net.name ] 
set rect1 "$ll_x [expr $tr_y - 1 ] $tr_x [expr $tr_y + 59 ] "
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer [lsort -u [get_db $top_pins .layer.name] ]
incr i
}


set inst_name { msh_msf_mci0 msh_msf_mci2 }
set i 0
foreach cell $inst_name {
    set bbox [get_db [get_db insts $cell] .bbox]
    set ll_x [get_db [get_db insts $cell] .bbox.ll.x]
    set ll_y [get_db [get_db insts $cell] .bbox.ll.y]
    set tr_x [get_db [get_db insts $cell] .bbox.ur.x]
    set tr_y [get_db [get_db insts $cell] .bbox.ur.y]

    set left_pins [get_db [get_db insts $cell] .pins -if " (.location.x <= [expr $ll_x + 4 ])  " ]
    set right_pins [get_db [get_db insts $cell] .pins -if " (.location.x >= [expr $tr_x - 4 ])  " ]
    
create_net_group -name ${cell}_$i -nets [get_db [get_db $left_pins ] .net.name ] 
set rect1 "[expr $ll_x - 60 ] $ll_y [expr $ll_x + 1] $tr_y  "
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer [lsort -u [get_db $left_pins .layer.name] ]
incr i

create_net_group -name ${cell}_$i -nets [get_db [get_db $right_pins ] .net.name ] 
set rect1 "[expr $tr_x - 1 ] $ll_y [expr $tr_x + 30 ] $tr_y  "
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer [lsort -u [get_db $right_pins .layer.name] ]
incr i
}

set inst_name {  msh_msf_mci1 msh_msf_mci3}
set i 0
foreach cell $inst_name {
    set bbox [get_db [get_db insts $cell] .bbox]
    set ll_x [get_db [get_db insts $cell] .bbox.ll.x]
    set ll_y [get_db [get_db insts $cell] .bbox.ll.y]
    set tr_x [get_db [get_db insts $cell] .bbox.ur.x]
    set tr_y [get_db [get_db insts $cell] .bbox.ur.y]

    set left_pins [get_db [get_db insts $cell] .pins -if " (.location.x <= [expr $ll_x + 4 ])  " ]
    set right_pins [get_db [get_db insts $cell] .pins -if " (.location.x >= [expr $tr_x - 4 ])  " ]
    
#create_net_group -name ${cell}_$i -nets [get_db [get_db $left_pins ] .net.name ] 
#set rect1 "[expr $ll_x - 30 ] $ll_y [expr $ll_x + 1] $tr_y  "
#create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer " M11:[lsort -u [get_db $left_pins .layer.name]] "
#incr i

create_net_group -name ${cell}_$i -nets [get_db [get_db $right_pins ] .net.name ] 
set rect1 "[expr $tr_x - 1 ] $ll_y [expr $tr_x + 30 ] $tr_y  "
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer [lsort -u [get_db $right_pins .layer.name] ]
incr i
}

set inst_name { tile0  tile2 }
set i 0
foreach cell $inst_name {
    set bbox [get_db [get_db insts $cell] .bbox]
    set ll_x [get_db [get_db insts $cell] .bbox.ll.x]
    set ll_y [get_db [get_db insts $cell] .bbox.ll.y]
    set tr_x [get_db [get_db insts $cell] .bbox.ur.x]
    set tr_y [get_db [get_db insts $cell] .bbox.ur.y]

    set right_pins [get_db [get_db insts $cell] .pins -if " (.location.x >= [expr $tr_x - 4 ]) && ( .location.y <= [expr $tr_y - 1640] ) " ]
    
create_net_group -name ${cell}_$i -nets [get_db [get_db $right_pins ] .net.name ] 
set rect1 "[expr $tr_x - 1 ] $ll_y [expr $tr_x + 310 ] [expr $tr_y -1640 ] "
set layers [join [lsort -u [get_db $right_pins .layer.name]] ":"]
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer $layers
incr i
}

set inst_name { tile2 tile3   }
foreach cell $inst_name {
    set bbox [get_db [get_db insts $cell] .bbox]
    set ll_x [get_db [get_db insts $cell] .bbox.ll.x]
    set ll_y [get_db [get_db insts $cell] .bbox.ll.y]
    set tr_x [get_db [get_db insts $cell] .bbox.ur.x]
    set tr_y [get_db [get_db insts $cell] .bbox.ur.y]

    set top_pins [get_db [get_db insts $cell] .pins -if "(.location.x >= [expr $ll_x + 1280  ]) &&  (.location.y >= [expr $tr_y - 4 ])  " ]
    

create_net_group -name ${cell}_$i -nets [get_db [get_db $top_pins ] .net.name ] 
set rect1 "[expr $ll_x + 1280] [expr $tr_y - 1 ] $tr_x [expr $tr_y + 310 ] "
set layers [join [lsort -u [get_db $top_pins .layer.name]] ":"]
create_bus_guide -type hard -net_group ${cell}_$i -rect $rect1 -layer $layers
incr i
}

