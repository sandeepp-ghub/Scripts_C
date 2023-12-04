#!/usr/local/bin/tclsh

proc myCellCount {str} {

    set cells [get_flat_cells -hierarchical  -filter "full_name=~${str}*"]
    set cellsC [sizeof_collection $cells ]

    set latch   [filter_collection $cells "ref_name=~*LAT*"]
    if {$latch ne ""} {set latchC  [sizeof_collection $latch]} else {set latchC  "0"}

    set flop  [filter_collection $cells "ref_name=~*DFF*"]
    if {$flop ne ""} {set flopC  [sizeof_collection $flop]} else {set flopC  "0"}

    #set memo
    set memo [filter_collection $cells  "design_type==macro"]
    if {$memo ne ""} {set memoC  [sizeof_collection $memo]} else {set memoC  "0"}

    set STDAREA 0
    set MEMAREA 0
    set area    0
    foreach_in_collection mem $memo {
        set area [get_attr $mem area]
        set MEMAREA [expr {double($MEMAREA) + $area}]
    }
    set stdcells [filter_collection $cells "design_type!=macro"]
    set area    0
    foreach_in_collection std $stdcells {
        set area    [get_attr $std area]
        set STDAREA [expr {double($STDAREA) + $area}]
    }

echo "Design: ${str}*"
echo "Number of cells   : $cellsC"
echo "Number of flops   : $flopC"
echo "Number of latchs  : $latchC"
echo "Number of memories: $memoC"
echo "STD Cells Area:    (Total cell area *   1.3, a.k.a 75% utilization + clock/reset/bonus cells outsize hirerarchy): [format {%0.2f} [expr {double($STDAREA)*1.3}]]"
echo "Memories Cell Area:(Total memory area * 1.1, Memories are wrapped in placement blockage): [format {%0.2f} [expr {double($MEMAREA)*1.1}]]"
echo "Total area: [format {%0.2f} [expr {double($STDAREA)*1.3 + double($MEMAREA)*1.1}]]"

}
