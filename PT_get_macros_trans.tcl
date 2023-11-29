proc fc_timing {} {
##########################################
# get one path to work on var name $path #
##########################################
    set from device_core/proj_dfx_server/dfx_server_wrapper/dfx_server_top/dfx_server_reset_top/rst_in_io_25mhz_delay/gl_cell/sync2/msil_sync2/CK
    set to device_core/alpha_macro/subcore/sbc_rst_unit/sbc_long_rst/por_rst_sync/rst_synch_2ffs/m/D
    set paths [get_timing_path -from $from -to $to -max_path 1 -nworst 1]
    if {[sizeof_collection $paths]< 1} {puts "Error: NO PATHS FOUND FOR PROC INPUTS"; return 0;}
    if {[sizeof_collection $paths]> 1} {puts "Info: MORE THAN ONE PATH WHERE FOUND ONLY THE WORST PATH IS USED";}
    set path [index_collection $paths 0]
##########################################
# get all points devided to macros       #
##########################################
    set points [get_attr $path points]
    set idm 0
    set pins_uid 0
    foreach_in_collection point $points {
        set pinCol   [get_attr $point object]
        set pinName  [get_object_name $pinCol]
        set pinSlack [get_attr $point slack]
        set pinTrans [get_attr $point transition]
        set pinObj   [get_attr $point object_class]
            if {[get_attr $pinCol pin_direction]=="out"} { 
                set pinCap   [get_attr $pinCol effective_capacitance_max]
            } else { 
                set pinCap   [get_attr $pinCol pin_capacitance_max] 
            }
        if {$pinCap==""} { puts "Error: pin: $pinName have no cap attr. using zero"; set pinCap 0}
        set cellib   [get_lib_cell */[get_attr [get_cell -of_object $pinCol] ref_name]]
        regexp {([^/]*/)([^/]*)(/.*)}  $pinName a b macros d
        set pin_table($pins_uid,name)   $pinName
        set pin_table($pins_uid,cap)    $pinCap
        set pin_table($pins_uid,trans)  $pinTrans
        set pin_table($pins_uid,slack)  $pinSlack
        set pin_table($pins_uid,cellib) $cellib
        
    
        if {[info exists macros_table($macros,pins)]} {
            lappend macros_table($macros,pins) $pins_uid
        } else {
            set macros_table($macros,pins) $pins_uid
            lappend macros_list $macros
        }
        incr pins_uid
    }
    if {![info exists macros_list]} {puts "Error: CAN'T FIND ANY MACROS HIER IN THE DESIGN"}

##############################################
# sort pins by cells                         #
##############################################
    set cell_uid 0;
    foreach macro $macros_list {
        set macros_table($macro,cells) [list]
        set start 1
        foreach pin_uid $macros_table($macro,pins) {
            if {$start==1} { 
                set start 0; 
                set id $pin_uid 
            } else {
                set id_Nneg1 $id
                set id $pin_uid
                set cell       [get_object_name [get_cell -of_object $pin_table($id,name)]]
                set cell_Nneg1 [get_object_name [get_cell -of_object $pin_table($id_Nneg1,name)]]
                if {$cell eq $cell_Nneg1} {
                        set cells_table($cell_uid,name)   [get_object_name [get_cell -of_object $pin_table($pin_uid,name)]]
                        set cells_table($cell_uid,col)    [get_cell -of_object $pin_table($pin_uid,name)]
                        set cells_table($cell_uid,in_pin)  $id_Nneg1
                        set cells_table($cell_uid,out_pin) $id
                        lappend macros_table($macro,cells) $cell_uid
                        incr cell_uid;

                }
            }
        }
        if {$macros_table($macro,cells)==""} {puts "Warning: MACRO:$macro have no cells !!!"}
    }

##############################################
# print report on path slacks cap and trans  #
##############################################
puts ""
set group_name_max_length 20
    echo [format "%-${group_name_max_length}s|  %9s | %9s | %9s |" "MACRO_NAME" "SLACK SUM" "TRANS AVER" "SLACK AVER" ]
    foreach macro $macros_list {
        set slackSum 0
        set transSum 0
        set capSum 0
        set pointSum 0
        foreach pin_uid $macros_table($macro,pins) {
            set slackSum  [expr {$slackSum+$pin_table($pin_uid,slack)}]
            set transSum  [expr {$transSum+$pin_table($pin_uid,trans)}]
            set capSum    [expr {$capSum+$pin_table($pin_uid,cap)}]
            incr pointSum  
        }
    set trans_av [expr {$transSum / $pointSum}]
    set cap_av   [expr {$capSum  / $pointSum}]
    echo [format "%-${group_name_max_length}s|  %6.4f   |  %3.5f   |  %3.5f   |" $macro $slackSum $trans_av $cap_av ]
    }
puts ""

###################################################
# print report on cells input tran & output cap   #
###################################################
puts ""
set group_name_max_length 20
    echo [format "%-${group_name_max_length}s|  %95s | %12s | %12s |" "MACRO_NAME" "CELL_NAME" "INPUT TRANS" "OUTPUT CAP" ]
    foreach macro $macros_list {
        foreach cell_uid $macros_table($macro,cells) {
            set macroName  $macro;
            set cellName   $cells_table($cell_uid,name)
            set inputTran  $pin_table($cells_table($cell_uid,in_pin),trans)
            set outputCap  $pin_table($cells_table($cell_uid,out_pin),cap)
            echo [format "%-${group_name_max_length}s|  %95s   | %3.7f   | %3.7f   |" $macroName $cellName $inputTran $outputCap ]
        }
    }
puts ""

############################################
# Temp: work on firs macro                 #
############################################
      


}; #end of proc
