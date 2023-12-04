global cell;

proc GetCellXY {} {
    global cell;
    set bbox [get_attr $cell bbox]
    set x0 [lindex [lindex $bbox 0] 0]
    set y0 [lindex [lindex $bbox 0] 1]
    set x1 [lindex [lindex $bbox 1] 0]
    set y1 [lindex [lindex $bbox 1] 1]
    set x_mid [expr (${x0} + ${x1})/2]
    set y_mid [expr (${y0} + ${y1})/2]
#    echo $x_mid
#    echo $y_mid
    return "$x_mid $y_mid"
}



#==================#
# Main             #
#==================#

set macro [get_selection ]

# get macro x y
set cell $macro;
set xy [GetCellXY];
set x_macro [lindex $xy 0]
set y_macro [lindex $xy 1]


# get memory pins.
set pinsIN   [get_flat_pins -of $macro -filter "name=~D*[*]||name=~A*[*]"]
set pinsOUT  [get_flat_pins -of $macro -filter "name=~Q*[*]"]
# collect ports that are connected to memory at 1 stage
##if {$pinsOUT ne ""} {set portO [filter_collection [all_fanout -from $pinsOUT -trace_arcs all -flat -endpoints_only]   "object_class==port"]} else {set portO ""}
##if {$pinsIN ne "" } {set portI [filter_collection [all_fanin  -to   $pinsIN  -trace_arcs all -flat -startpoints_only] "object_class==port"]} else {set portI ""}

# get memories all fanin/out 
if {$pinsOUT ne ""} {set afo [all_fanout -from $pinsOUT -trace_arcs all -flat -endpoints_only   -only_cells]} else {set afo ""}
if {$pinsIN ne "" } {set afi [all_fanin  -to   $pinsIN  -trace_arcs all -flat -startpoints_only -only_cells]} else {set afi ""}
#get first flops.
if {$afo ne ""} {set afoflops1  [filter_collection $afo "ref_name!~LAT*"]} else {set afoflops1 ""}
if {$afi ne ""} {set afiflops1  [filter_collection $afi "ref_name!~LAT*"]} else {set afiflops1 ""}
#-- jump over latches.
if {$afo ne ""} {set afoLatchs  [filter_collection $afo "ref_name=~LAT*"]} else {set afoLatchs ""}
if {$afi ne "" } {set afiLatchs  [filter_collection $afi "ref_name=~LAT*"]} else {set afiLatchs ""}
if {$afoLatchs ne ""} {set letPinsOUT [get_pins -of $afoLatchs -filter "name=~Q*" -quiet]} else {set letPinsOUT ""}
if {$afiLatchs ne ""} {set letPinsIN  [get_pins -of $afiLatchs -filter "name=~D*" -quiet]} else {set letPinsIN ""}

#to flops after latchs.
if {$letPinsOUT ne ""} {set afoflops2 [filter_collection [all_fanout -from $letPinsOUT -trace_arcs all -flat -endpoints_only   -only_cells]  "object_class==cell"]} else {set afoflops2 ""}
if {$letPinsIN ne "" } {set afiflops2 [filter_collection [all_fanin  -to   $letPinsIN  -trace_arcs all -flat -startpoints_only -only_cells]  "object_class==cell"]} else {set afiflops2 ""}

#to ports after latchs.
##if {$letPinsOUT ne ""} {set afoPortsAfterLatchs [filter_collection [all_fanout -from $letPinsOUT -trace_arcs all -flat -endpoints_only   ]  "object_class==port"]} else {set afoPortsAfterLatchs ""}
##if {$letPinsIN  ne ""} {set afiPortsAfterLatchs [filter_collection [all_fanin  -to   $letPinsIN  -trace_arcs all -flat -startpoints_only ]  "object_class==port"]} else {set afiPortsAfterLatchs ""}

#-- jump from flops to ports
    #-- get all flops
set afoflops [add_to_collection $afoflops1 $afoflops2]
set afiflops [add_to_collection $afiflops1 $afiflops2]
set allFlops [add_to_collection $afoflops  $afiflops ]
    #-- get all flops all pins
##set afopins [get_pins -of $afoflops -filter "name=~Q*" -quiet]
##set afipins [get_pins -of $afiflops -filter "name=~D*" -quiet]
##set afoPortsAfterFlops [filter_collection [all_fanout -from $afopins -trace_arcs all -flat -endpoints_only   ]  "object_class==port"]
##set afiPortsAfterFlops [filter_collection [all_fanin  -to   $afipins  -trace_arcs all -flat -startpoints_only ]  "object_class==port"]

#-- go over all flops and get common point.
set  i 0;
set XT 0;
set YT 0;
foreach_in_collection flop $allFlops {
    set cell $flop;
    set xy [GetCellXY];
    set x [lindex $xy 0]
    set y [lindex $xy 1]
#echo $x
#echo $y
    set XT [expr {$x + $XT}]
    set YT [expr {$y + $YT}]
    incr i
}
set XAV [expr {$XT/$i}]
set YAV [expr {$YT/$i}]
gui_add_annotation -window [gui_get_current_window -types Layout] -type arrow [list [list $x_macro $y_macro]     [list $XAV $YAV]] -width 3 -color red
