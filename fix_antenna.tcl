set fp [open "antenna_violation_eco.tcl" w]
set fp2 [open "antenna_nets.txt" w]
#read_markers -type calibre /proj/ccpd01/release/rcplx_ch_rclk.0.0/PNR1.0.V036/pv.signoff.ant/ant_AL005T/rcplx_ch_rclk/DRC_RES.drc

set inst_with_violations ""
set length_threshold 150
foreach mrkr [get_db markers -if {.user_type == A.R.6*}] {
    set mrkr_bbox [get_db $mrkr .bbox]
    set inst_under_mrkr [get_obj_in_area -areas $mrkr_bbox -obj_type inst]
    set insts [get_db $inst_under_mrkr -if {.name != *DIODE* }]
    if {[llength $insts] } {
    lappend inst_with_violations  $inst_under_mrkr  
    }
}    

set inst_pins [get_db -u $inst_with_violations .pins -if {.is_clock == false}] 
set nets_list [get_db $inst_pins .net]

set long_nets [get_db $nets_list -if {.bbox.length > $length_threshold && .is_clock == false}]

foreach net $long_nets {
set CMD "eco_add_repeater -cell BUFFD8BWP210H6P51CNODLVT -net [get_db $net .name ] -relative_distance_to_sink 0.5"
puts $fp $CMD
    
}

set via_nets ""
foreach mrkr [get_db markers -if {.user_type == A.R.4:VIA* }] {
    set mrkr_bbox [get_db $mrkr .bbox]
    set via_under_mrkr [get_obj_in_area -areas $mrkr_bbox -obj_type via -layers {M14 M13}]
    lappend via_nets [get_db $via_under_mrkr .net]
    }  

set nets_list [get_db -u $via_nets  -if {.is_clock == false} ]

foreach net $nets_list {

set CMD "eco_add_repeater -cell BUFFD8BWP210H6P51CNODLVT -net [get_db $net .name ] -relative_distance_to_sink 0.5"
puts $fp $CMD
}    

close $fp

lappend long_nets $nets_list

foreach net [get_db -u $long_nets] {
puts $fp2 [get_db $net .name ]
}    

close $fp2
