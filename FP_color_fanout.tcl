alias gon get_object_name
alias gs dbget selected.name -e
alias dh dehighlight
alias gon get_object_name
alias gc get_cells
alias si selectInst
alias ds deselectAll
alias soc sizeof_collection



proc colorFanout {args} {
	 dh
	if {([info exists args] && ($args == "")) } { 
	set args [gs] 
	} else { 
	set cells [gc -quiet $args]
	}

	if { [dbget selected.objType  -u] == "inst" } {	
	set cells [gc -quiet $args]
	
	 ds ; dh
        si [gon $cells]
        highlight -index 3
        set ckPin [get_pins -q -of $cells -filter "(is_clock == true) && (full_name !~ */RSCLK)"]
	if { [soc $ckPin] ==  0 } { set ckPin [gon [get_pins -q -of $cells -filter "direction == out"]] } else { set ckPin [gon $ckPin]}

        #set AllFanout [gon [remove_from_collection [gc -of [all_fanout -from $ckPin ]] [gc $cells]]]
        set AllFanout [gon [remove_from_collection [gc -of [ get_pins [all_fanout -from $ckPin ] -filter "full_name !~ */LS* "]] [gc $cells]]]

        ds ; si $AllFanout
        highlight -index 1

        #set ep [gon [remove_from_collection [gc -of [all_fanout -from $ckPin -endpoints_only]] [gc $cells]]]
        set ep [gon [remove_from_collection [gc -of [all_fanout -from $ckPin -endpoints_only]] [gc $cells]]]
	set ep [gon [remove_from_collection [gc -of [ get_pins [all_fanout -from $ckPin -endpoints_only ] -filter "full_name !~ */LS* "]] [gc $cells]]]
        ds ; si $ep
	set oports [get_ports -q [all_fanout -from $ckPin -endpoints_only] -filter "(full_name !~ *TEST*) && (full_name !~ *SI*)" ]
	if {[soc $oports]} {selectPin [gon $oports]}
        highlight -index 2

	}

	if { [dbget selected.objType  -u] == "term" } {
	set ports [get_ports -quiet $args]
        ds ; dh
	foreach pt [gon $ports] { selectPin $pt}
        highlight -index 3
        #set dataPin [gon [get_pins -of $ports -filter "is_data == true"]]
        #set dataPin [gon [ get_pins -of $ports -filter "(is_data == true) && (full_name !~ */RSC* )"]]

	if {[llength [dbget -e selected.isInput 1]] > 0 } { 
	
	set InPOrts [dbget [dbget -e selected.isInput 1 -p ].name ] 
        set AllFanout [gon [gc -of [all_fanout -from  $InPOrts]]]

        ds ; si $AllFanout
        highlight -index 1
        ds

        #set startPt [gon [remove_from_collection  [gc -of [all_fanin -to $dataPin -startpoints_only]] [gc $ports]]]
	set endPt [gon [gc -of [all_fanout -from  $InPOrts -endpoints_only]]]
        ds ; si $endPt
        highlight -index 2
        }
	
	}

}

#colorFanout
