##create Pin DB

if {[info exists pin_DB]} {
unset pin_DB
}
variable pin_DB [dict create]

foreach inst [get_db insts  -if { .place_status != "fixed" }] {

foreach in_pin [get_db [get_db $inst .pins] -if {.direction == in }] {

set driver [get_db $in_pin .net.drivers]
set obj_type [get_db $driver .obj_type]

dict set pin_DB $in_pin driver $driver
dict set pin_DB $in_pin driver_location [get_db $driver .location]


}


foreach out_pin [get_db [get_db $inst .pins] -if {.direction == out }] {

set loads [get_db $out_pin .net.loads]
set obj_type [get_db $driver .obj_type]

dict set pin_DB $out_pin loads $loads

}

}

###################################################
#trace ports

proc trace_place {args} {
parse_proc_arguments -args $args arg

if {![info exists arg(-obj) ] && [llength [get_db $arg(-obj)]] > 0    } {
return -1
}

if {![info exists arg(-offset) ]  } {
    set offset 0
} else {
    set offset $arg(-offset)
}
    


set object $arg(-obj)
set direction $arg(-direction)

set location_x [get_db $object .location.x]
set location_y [get_db $object .location.y]
set port_load  [get_db [get_db $object .net.loads -if { .name == *reg* } ] .inst ]

set obj_type [get_db $object .obj_type]
 
set trace_stop 1

if { [llength $port_load] == 1  } {


if {$direction == "up" && $obj_type == "port" } {
    set new_y [get_legal_location_y -x $location_x  -y [expr $location_y + $offset ] -inst_name $port_load]
    set cmd "place_inst $port_load {$location_x $new_y } -soft_fixed"
} elseif {$direction == "down" && $obj_type == "port" } {
    set new_y [get_legal_location_y -x $location_x  -y [expr $location_y + $offset ] -inst_name $port_load ]
    set cmd "place_inst $port_load {$location_x $new_y } -soft_fixed"
}

eval $cmd
set trace_stop 0

}

set out_pin [get_db [get_db $port_load .pins] -if {.direction == "out" && .base_name == "Q" }]  
set trace_pin $out_pin

set flop_chain $port_load

while {!$trace_stop} {
set trace_load  [get_db [get_db $trace_pin .net.loads] .inst -if { .base_name == *reg* } ]

if { [llength $trace_load] == 1  } {

lappend flop_chain $trace_load 
set trace_pin [get_db $trace_load .pins -if {.direction == "out" && .base_name == "Q" }]

} else {
set trace_stop 1

#set last_sink [get_db [get_db $trace_pin .net.loads]]

}
}

set flopchain_length [llength $flop_chain]

for {set i 1} {$i < $flopchain_length } {incr i} {
set inst [lindex $flop_chain $i] 
if {$direction == "up" } {
set new_y [get_legal_location_y -x $location_x  -y [expr $location_y + 500 ] -inst_name $inst]

set cmd "place_inst $inst {$location_x $new_y } -soft_fixed"
} else {
set new_y [get_legal_location_y -x $location_x  -y [expr $location_y - 500 ] -inst_name $inst]    
set cmd "place_inst $inst {$location_x $new_y } -soft_fixed"
}
eval $cmd
}




}



define_proc_arguments trace_place \
-define_args {\
 {-obj "pin/port" "" string required}
 {-direction "up/down" "" string required}
 {-offset "offset value" "" string optional}
 }


define_proc_arguments get_legal_location_x \
-define_args {\
 {-x "x co-ordinate" "" string required}
 {-y "y" "" string required}
 {-inst_name "inst name obj" "" string required}
 {-search_distance_x "search distance value (default 100u)" "" string optional}
 }

proc get_legal_location_x {args} {
parse_proc_arguments -args $args arg

set x $arg(-x)

if {![info exists arg(-search_distance_x) ] } {
    set search_distance_x 99.978
} else {
    set search_distance_x $arg(-search_distance_x)
} 

set inst [get_db  $arg(-inst_name)]
#set inst [get_db current_design .insts $arg(-inst_name)]
set cell_width [get_db $inst .base_cell.bbox.length]
set cell_height [get_db $inst .base_cell.bbox.width]

set ll_x [expr {round($arg(-x)/0.057) * 0.057 } ]

set ll_y [expr [expr {round($arg(-y)/$cell_height)/2} ] *2*$cell_height  ]

set ur_x [ expr  $ll_x + $cell_width ]   
set ur_y [ expr  $ll_y + $cell_height ]   

#puts "get_obj_in_area -area \"$ll_x $ll_y $ur_x $ur_y\" -obj_type inst "
while { ( [llength [ get_obj_in_area -area "$ll_x $ll_y $ur_x $ur_y" -obj_type inst -enclosed_only ] ] != 0 || [llength [ get_obj_in_area -area "$ll_x $ll_y $ur_x $ur_y" -obj_type inst -overlap_only ] ] !=0 ) && [expr $ur_x - $x] < $search_distance_x } {

set ll_x [expr $ll_x + 0.114 ]
set ur_x [expr $ur_x + 0.114 ]
#puts "new $ll_x"
}    

return $ll_x

}


define_proc_arguments get_legal_location_y \
-define_args {\
 {-x "x co-ordinate" "" string required}
 {-y "y" "" string required}
 {-inst_name "inst name obj" "" string required}
 {-search_distance_y "search distance value (default 100u)" "" string optional}
 }

proc get_legal_location_y {args} {
parse_proc_arguments -args $args arg

set y $arg(-y)
if {![info exists arg(-search_distance_y) ] } {
    set search_distance_y 99.96
} else {
    set search_distance_y $arg(-search_distance_y)
} 

set inst [get_db  $arg(-inst_name)]
#set inst [get_db current_design .insts $arg(-inst_name)]
set cell_width [get_db $inst .base_cell.bbox.length]
set cell_height [get_db $inst .base_cell.bbox.width]

set ll_x [expr {round($arg(-x)/0.057) * 0.057 } ]

set ur_y [expr [expr {round($arg(-y)/$cell_height)/2} ] *2*$cell_height  ]


set ur_x [ expr  $ll_x + $cell_width ]   
set ll_y [ expr  $ur_y - $cell_height ]   

#puts "get_obj_in_area -area \"$ll_x $ll_y $ur_x $ur_y\" -obj_type inst "
while { ( [llength [ get_obj_in_area -area "$ll_x $ll_y $ur_x $ur_y" -obj_type inst -enclosed_only ] ] != 0 || [llength [ get_obj_in_area -area "$ll_x $ll_y $ur_x $ur_y" -obj_type inst -overlap_only ] ] !=0 ) && [expr $y - $ll_y] < $search_distance_y } {

set ll_y [expr $ll_y - $cell_height ]
set ur_y [expr $ur_y - $cell_height ]
#puts "new $ll_y $ur_y [expr $y - $ll_y] "
}    
#puts "new $ll_y $ur_y"

return $ll_y

}



##############################################################################################


return 


set fp2 [open "pin_list.tcl" w]

foreach inst [get_db insts  -if { .place_status != "fixed" }] {

foreach pin [get_db $inst .pins  -if {.direction == "in" && .base_name != "CP" }  ]  {
puts $fp2 "$pin,driver:[dict get $pin_DB $pin driver],[dict get $pin_DB $pin driver_location]"

}

foreach pin [get_db $inst .pins  -if {.direction == "out" }  ]  {
puts $fp2 " $pin,loads:[dict get $pin_DB $pin loads]"

}


}
close $fp2

set port_inst {}
set other_inst {}

set fp1 [open "gates_til.tcl" w]

## place OR gates

foreach inst [get_db insts  -if { .base_cell.name == OR* && .place_status == unplaced }] {

foreach in_pin [get_db [get_db $inst .pins] -if {.direction == "in" }] {
set driver [get_db $in_pin .net.drivers]
set obj_type [get_db $driver .obj_type]
if {$obj_type == "port" } {
set location_x  [get_db $driver .location.x]
set location_y  [get_db $driver .location.y]

set new_y [get_legal_location_y -x $location_x  -y [expr $location_y - 2.52]  -inst_name $inst
puts $fp1 "place_inst $inst {$location_x $new_y}   -soft_fixed"
lappend port_inst $inst 

} elseif {$obj_type == "pin" } {
set driver_ref_name [get_db $driver .inst.base_cell.name]

if {$driver_ref_name == "pcl_til"  || $driver_ref_name == "gwc_asiarb"  || $driver_ref_name == "pcl_msf_lre"  || $driver_ref_name == "pcl_msf_tbe"  } {

set location_x   [get_db $driver .location.x]
set location_y   [get_db $driver .location.y]

set cell_width [get_db $inst .base_cell.bbox.length]
set cell_height [get_db $inst .base_cell.bbox.width]

set new_y [expr [expr {round($location_y/$cell_height)/2} ] *2*$cell_height  ]
set new_x [get_legal_location_x -x [expr $location_x + 2.6 ]  -y $new_y -inst_name $inst]

puts $fp1 "place_inst $inst {$new_x $new_y}   -soft_fixed"

lappend other_inst $inst
} 
}
}
}

close $fp1


set fp3 [open "flops_til.tcl" w]

## place flops

foreach inst [get_db insts  -if { .base_name == *_reg_* && .place_status == unplaced }] {

foreach in_pin [get_db [get_db $inst .pins] -if {.direction == "in" && .base_name == "D" }] {
set driver [get_db $in_pin .net.drivers]
set obj_type [get_db $driver .obj_type]
if {$obj_type == "port" } {
set location_x [get_db $driver .location.x]
set location_y [get_db $driver .location.y]
puts $fp1 "place_inst $inst {$location_x [expr $location_y - 2.24]  }-soft_fixed"
lappend port_inst $inst 

} elseif {$obj_type == "pin" } {
set driver_ref_name [get_db $driver .inst.base_cell.name]

if {$driver_ref_name == "pcl_til"  || $driver_ref_name == "gwc_asiarb"  || $driver_ref_name == "pcl_msf_lre"  || $driver_ref_name == "pcl_msf_tbe" } {

set location_x   [get_db $driver .location.x]
set location_y   [get_db $driver .location.y]
puts $fp1 "place_inst $inst {[expr $location_x+5] $location_y}  -soft_fixed"
lappend other_inst $inst
} 
}
}
}

close $fp3

cat flops_til.tcl | sort -n -k 4 > flops_til_sort.tcl
cat gates_til.tcl | sort -n -k 4 > gates_til_sort.tcl

foreach inst [get_db $port_inst .base_name] {
set_inst_padding -inst $inst  -right_side 2 -left_side 2
}

foreach inst [get_db $other_inst .base_name] {
set_inst_padding -inst $inst  -right_side 2 -left_side 2
}

set_db place_detail_honor_inst_pad true



foreach port [get_db ports -if { .pin_edge == 1 && .base_name != pcl__top_msh* && .base_name != top__pcl_msh* && .base_name != rclk  && .direction == "in"} ] {

trace_place -obj $port -direction down -offset -2.52
}


foreach pin [get_db [get_db insts pcl_chn_g_gwc_*__gwc_asiarb ] .pins -if {.base_name != *clk* }] {

trace_place -obj $pin -direction up

}

foreach pin [get_db [get_db insts  gx_*__gy_1__til ] .pins -if {.base_name != *clk* && .base_name != *msh* && .direction == out }] {

trace_place -obj $pin -direction down

}

##place unplaced inst



foreach inst [get_db insts  -if { .base_name == *_reg_* && .place_status == unplaced }] {

foreach in_pin [get_db [get_db $inst .pins] -if {.direction == "in" && .base_name == "D" }] {
set driver [get_db $in_pin .net.drivers]
set obj_type [get_db $driver .obj_type]
if {$obj_type == "pin" } {
set location   [get_db $driver .location]
set cmd  "place_inst $inst $location -soft_fixed"
puts $cmd
eval $cmd
}
}
}

## place tie cells 

foreach inst [get_db insts  -if { .base_cell.name == TIE*  }] {

set pin [get_db [get_db $inst .pins] -if {.base_name == "Z*" }] 
set loads [get_db $pin .net.loads]
set location   [get_db [lindex $loads 0]  .location]
set cmd  "place_inst $inst $location -soft_fixed"
puts $cmd
eval $cmd
}

