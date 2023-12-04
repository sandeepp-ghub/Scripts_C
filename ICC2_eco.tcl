

set slct     [get_selection]


#port.
set slct_in  [filter_collection $slct "direction==in&&object_class==port"]
set slct_out [filter_collection $slct "direction==out&&object_class==port"]
set afi [all_fanin  -to   $slct_out  -flat -startpoints_only -only_cells]
set afo [all_fanout -from $slct_in -flat -endpoints_only     -only_cells ]
set afip [all_fanin  -to   $slct_out  -flat -startpoints_only  ]
set afop [all_fanout -from $slct_in -flat -endpoints_only      ]
set pinsIN   [get_flat_pins -of $afi -filter "direction==in&&name=~D*||name=~*data*||name=~*idx*||name=~A*[*]"]
set pinsOUT  [get_flat_pins -of $afo -filter "direction==out&&name=~Q*||name=~*data*||name=~*hit*"]
set portIN   [get_ports  -of $afip -filter "direction==in"]
set portOUT  [get_ports  -of $afop -filter "direction==out"]
change_selection $pinsIN
change_selection $pinsOUT -add
change_selection $portIN -add
change_selection $portOUT -add



#pins.
set slct [get_pins -of $slct]
set slct_in  [filter_collection $slct "direction==in&&object_class!=port"]
set slct_out [filter_collection $slct "direction==out&&object_class!=port"]
set afi [all_fanin  -to   $slct_in  -flat -startpoints_only -only_cells]
set afo [all_fanout -from $slct_out -flat -endpoints_only     -only_cells ]
set afip [all_fanin  -to   $slct_in  -flat -startpoints_only  ]
set afop [all_fanout -from $slct_out -flat -endpoints_only      ]
set pinsIN   [get_flat_pins -of $afi -filter "direction==in&&name=~D*||name=~*data*||name=~*idx*||name=~A*[*]"]
set pinsOUT  [get_flat_pins -of $afo -filter "direction==out&&name=~Q*||name=~*data*||name=~*hit*"]
set portIN   [get_ports  -of $afip -filter "direction==in"]
set portOUT  [get_ports  -of $afop -filter "direction==out"]
change_selection $pinsIN -add
change_selection $pinsOUT -add
change_selection $portIN -add
change_selection $portOUT -add



#change_selection $afi
#change_selection $afo -add




