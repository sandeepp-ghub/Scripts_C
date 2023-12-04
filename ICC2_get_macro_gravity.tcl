
set macro [get_selection ]

# get memory pins.
set pinsIN   [get_flat_pins -of $macro -filter "name=~D*[*]||name=~A*[*]"]
set pinsOUT  [get_flat_pins -of $macro -filter "name=~Q*[*]"]
# collect ports that are connected to memory at 1 stage
if {$pinsOUT ne ""} {set portO [filter_collection [all_fanout -from $pinsOUT -trace_arcs all -flat -endpoints_only]   "object_class==port"]} else {set portO ""}
if {$pinsIN ne "" } {set portI [filter_collection [all_fanin  -to   $pinsIN  -trace_arcs all -flat -startpoints_only] "object_class==port"]} else {set portI ""}




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
if {$letPinsOUT ne ""} {set afoPortsAfterLatchs [filter_collection [all_fanout -from $letPinsOUT -trace_arcs all -flat -endpoints_only   ]  "object_class==port"]} else {set afoPortsAfterLatchs ""}
if {$letPinsIN  ne ""} {set afiPortsAfterLatchs [filter_collection [all_fanin  -to   $letPinsIN  -trace_arcs all -flat -startpoints_only ]  "object_class==port"]} else {set afiPortsAfterLatchs ""}

#-- jump from flops to ports
    #-- get all flops
set afoflops [add_to_collection $afoflops1 $afoflops2]
set afiflops [add_to_collection $afiflops1 $afiflops2]
    #-- get all flops all pins
set afopins [get_pins -of $afoflops -filter "name=~Q*" -quiet]
set afipins [get_pins -of $afiflops -filter "name=~D*" -quiet]
set afoPortsAfterFlops [filter_collection [all_fanout -from $afopins -trace_arcs all -flat -endpoints_only   ]  "object_class==port"]
set afiPortsAfterFlops [filter_collection [all_fanin  -to   $afipins  -trace_arcs all -flat -startpoints_only ]  "object_class==port"]




gui_change_highlight -remove -all_colors
gui_set_highlight_options -current_color yellow
gui_set_highlight_options -auto_cycle_color false
if {$macro   ne ""}  {gui_change_highlight -add -collection  $macro}
if {$afoflops ne ""} {gui_change_highlight -add -collection  $afoflops}
if {$afiflops ne ""} {gui_change_highlight -add -collection  $afiflops}
if {$afoLatchs ne ""} {gui_change_highlight -add -collection  $afoLatchs}
if {$afiLatchs ne ""} {gui_change_highlight -add -collection  $afiLatchs}
gui_set_highlight_options -current_color green
if {$afoPortsAfterLatchs ne ""} {gui_change_highlight -add -collection  $afoPortsAfterLatchs}
if {$afiPortsAfterLatchs ne ""} {gui_change_highlight -add -collection  $afiPortsAfterLatchs}
gui_set_highlight_options -current_color orange
if {$afoPortsAfterLatchs ne ""} {gui_change_highlight -add -collection  $afoPortsAfterFlops}
if {$afiPortsAfterLatchs ne ""} {gui_change_highlight -add -collection  $afiPortsAfterFlops}
gui_set_highlight_options -current_color red
if {$portO ne ""} {gui_change_highlight -add -collection  $portO}
if {$portI ne ""} {gui_change_highlight -add -collection  $portI}
#gui_set_highlight_options -next_color




