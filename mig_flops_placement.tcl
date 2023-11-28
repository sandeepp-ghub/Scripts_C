### ************************************************************************
### *  MARVELL CONFIDENTIAL AND PROPRIETARY NOTE                           *
### *                                                                      *
### *  This software contains information confidential and proprietary     *
### *  to Marvell, Inc. It shall not be reproduced in whole or in part,    *
### *  or transferred to other documents, or disclosed to third parties,   *
### *  or used for any purpose other than that for which it was obtained,  *
### *  without the prior written consent of Marvell, Inc.                  *
### *                                                                      *
### *  Copyright 2019-2019, Marvell, Inc.  All rights reserved.            *
### *                                                                      *
### ************************************************************************
### * Author      : Lior Allerhand
### * Date        : 20/3/2019
### * Description : Drew an arrow between a macro and the average placement 
### *               point of all the flops talking to it.
### ************************************************************************


global cell;

proc mig_GetCellXY {} {
    global cell;
    set x0 [get_db $cell .bbox.ll.x]
    set y0 [get_db $cell .bbox.ll.y] 
    set x1 [get_db $cell .bbox.ur.x]
    set y1 [get_db $cell .bbox.ur.y]
    set x_mid [expr (${x0} + ${x1})/2]
    set y_mid [expr (${y0} + ${y1})/2]
#    echo $x_mid
#    echo $y_mid
    return "$x_mid $y_mid"
}



#==================#
# Main             #
#==================#

proc mig {args} {
global cell;

set shortFlyLine  200;# 0--150u
set mediumFlyLine 350;#150--275u
    #-- the proc args
    parse_proc_arguments -args ${args} results
    if {[info exists results(-reset)]} {
        gui_clear_highlight -all ;
        delete_obj  [get_db gui_lines];
        delete_obj  [get_db gui_rects];
        delete_obj [get_db gui_texts];       
        return;
    }
    if {[info exists results(-selected)]} {
        if {[get_db selected] ne ""} {
            set macros [get_db selected]
        } else { 
            echo "Error: macro need to be selected";
            return
        }
    }
    if {[info exists results(-macros_list)]} {
        if {$results(-macros_list) ne ""} {
            set macros $results(-macros_list)
        } else { 
            echo "Error: macro_col is empty";
            return
        }
    }
    if {[info exists results(-all)]} {
        set macros [get_db insts -if  {.is_macro==true}] ;#||[{.is_macro==true}]
    }

    #-- run proc 
    foreach macro $macros {
        set cell $macro;
        set macroFlyLineLnt [mig_drew_macro_arrow];
        #-- collor macro.
        if {[info exists results(-color_macros)]} {
            if {$macroFlyLineLnt <= $shortFlyLine } {set color "green"} 
            if {$macroFlyLineLnt > $shortFlyLine && $macroFlyLineLnt <= $mediumFlyLine } {set color "yellow"}
            if {$macroFlyLineLnt > $mediumFlyLine} {set color "red"}
            #gui_change_highlight -add -color $color  -collection $macro
            gui_highlight -pattern solid -color $color $macro
        }
    }
}


define_proc_arguments mig  \
    -info "Drew an arrow between a macro and the average placement point of all the flops talking to it. \n\t\t\t\tWill jump over latches to the driver/receiver flop.  " \
    -define_args {
        {-selected   "Get selected macros"  "" boolean optional}
        {-all        "Run on all macros"  "" boolean optional}
        {-macros_list  "Get an inst: list of macros to run on"    "" list    optional}
        {-reset      "Remove arrows "                          "" boolean optional}
        {-color_macros   "Color macros by fly lines length threshold. Short fly line Green, Medium fly line yellow, long fly line red."  "" boolean optional}
        {-flylines_thresholds   "None default thresholds 0--\$short , \$short--\$medium , \$medium--INF {medium short}"    "" list    optional}

    }



proc mig_drew_macro_arrow {} {
    global cell;
    set macro $cell;
    # get macro x y
    set xy [mig_GetCellXY];
    set x_macro [lindex $xy 0]
    set y_macro [lindex $xy 1]


    # get memory pins.
    set pinsIN   [get_db $macro .pins  -if {.direction==in&&(.name==*/D*[*]||.name==*/*data*||.name==*/*idx*||.name==*/A*[*])}]
    set pinsOUT  [get_db $macro .pins  -if {.direction==out&&(.name==*/Q*[*]||.name==*/*data*||.name==*/*hit*)}]
    # if not a memory make things more relax.
    

    # get memories all fanin/out 
    if {$pinsOUT ne ""} {set afo [all_fanout -from $pinsOUT -trace_through all -flat -endpoints_only   -only_cells]} else {set afo ""}
    if {$pinsIN ne "" } {set afi [all_fanin  -to   $pinsIN  -trace_through all -flat -startpoints_only -only_cells]} else {set afi ""}
    #get first flops.
    if {$afo ne ""} {set afoflops1  [filter_collection $afo "ref_name!~*LN*&&ref_name!~*LH*"]} else {set afoflops1 ""}
    if {$afi ne ""} {set afiflops1  [filter_collection $afi "ref_name!~*LN*&&ref_name!~*LH*"]} else {set afiflops1 ""}
    #-- jump over latches.  #to flops after latchs.
    if {$afo ne ""}  {set afoLatchs  [filter_collection $afo "ref_name!~*LN*&&ref_name!~*LH*"]} else {set afoLatchs ""}
    if {$afi ne "" } {set afiLatchs  [filter_collection $afi "ref_name!~*LN*&&ref_name!~*LH*"]} else {set afiLatchs ""}
    if {$afoLatchs ne ""} {set letPinsOUT [get_pins -of $afoLatchs -filter "name=~Q*" -quiet]} else {set letPinsOUT ""}
    if {$afiLatchs ne ""} {set letPinsIN  [get_pins -of $afiLatchs -filter "name=~D*" -quiet]} else {set letPinsIN ""}   
    if {$letPinsOUT ne ""} {set afoflops2 [filter_collection [all_fanout -from $letPinsOUT -trace_through all -flat -endpoints_only   -only_cells]  "object_class==cell"]} else {set afoflops2 ""}
    if {$letPinsIN ne "" } {set afiflops2 [filter_collection [all_fanin  -to   $letPinsIN  -trace_through all -flat -startpoints_only -only_cells]  "object_class==cell"]} else {set afiflops2 ""}
    
    #-- get all flops
    set afoflops [add_to_collection $afoflops1 $afoflops2]
    set afiflops [add_to_collection $afiflops1 $afiflops2]
    set allFlops [add_to_collection $afoflops  $afiflops ]
    #-- filter *scan* flops.
    set allFlops [filter_collection $allFlops "name!~*_bist_*&&name!~*_csr_"]

    #-- go over all flops and get common point.
    set  i 0;
    set XT 0;
    set YT 0;
    foreach_in_collection flop $allFlops {
        set cell $flop;
        set xy [mig_GetCellXY];
        set x [lindex $xy 0]
        set y [lindex $xy 1]
    #echo $x
    #echo $y
        set XT [expr {$x + $XT}]
        set YT [expr {$y + $YT}]
        incr i
    }
    if {$i eq "0"} {return "0"}
    set XAV [expr {$XT/$i}]
    set YAV [expr {$YT/$i}]
    set_layer_preference red -color red -is_visible 1 -line_width 4
    create_gui_shape -layer red -line "$x_macro $y_macro $XAV $YAV" -arrow
    #gui_add_annotation -window [gui_get_current_window -types Layout] -type arrow [list [list $x_macro $y_macro]     [list $XAV $YAV]] -width 3 -color red

    #-- get arrow size
    set x_sq [expr {($x_macro - $XAV)*($x_macro - $XAV)} ]
    set y_sq [expr {($y_macro - $YAV)*($y_macro - $YAV)} ]
    set c    [expr {sqrt($x_sq + $y_sq)} ]
    return $c
}
