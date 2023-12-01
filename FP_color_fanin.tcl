eval_legacy {source  /mrvl/cavmhomes/bsekar/scripts/mem/color_fanin.tcl}
gui_bind_key F1 -cmd {eval_legacy colorFanin}


alias gon get_object_name
alias gs dbget selected.name -e
alias dh dehighlight
alias gon get_object_name
alias gc get_cells
alias si selectInst
alias ds deselectAll
alias soc sizeof_collection




proc colorFanin {args} {
	dh
	if {([info exists args] && ($args == "")) } { 
	set args [gs] 
	} else { 
	set cells [gc -quiet $args]
	}

	if {   [regexp "inst" [dbget selected.objType  -u]] } {	
	set cells [gc -quiet $args]
	ds ; dh
	si [gon $cells]
	highlight -index 3
	ds
	#set dataPin [gon [get_pins -of $cells -filter "is_data == true"]]
	set dataPin  [ get_pins -q -of $cells -filter "(is_data == true) && (full_name !~ */RSC* ) && (is_clock == false) && (full_name !~ */SI*) && (full_name !~ */SE* ) "]

	if { [soc $dataPin] ==  0 } { set dataPin [gon [get_pins -q -of $cells -filter "direction == in"]] } else { set dataPin [gon $dataPin]}

	set AllFanin [gon [remove_from_collection [gc -of [all_fanin -to $dataPin ]] [gc $cells]]]

	ds ; si $AllFanin
	highlight -index 1
	ds

	set sp [gon [remove_from_collection  [gc -of [all_fanin -to $dataPin -startpoints_only]] [gc $cells]]]
	ds ; si $sp
	set iports [get_ports -q [get_ports -q [get_ports -q [get_ports -q [all_fanin -to $dataPin -startpoints_only] -filter "full_name !~ *TEST*"] -filter "full_name !~ scan_en"] -filter "full_name !~ *LV*"] -filter "full_name !~ *T_AWT_N*"]
	if {[soc $iports]} {selectPin [gon $iports]}
	highlight -index 2
	}

	if { [dbget selected.objType  -u] == "term" } {
	set ports [get_ports -quiet $args]
        ds ; dh
	foreach pt [gon $ports] { selectPin $pt}
        highlight -index 3
        #set dataPin [gon [get_pins -of $ports -filter "is_data == true"]]
        #set dataPin [gon [ get_pins -of $ports -filter "(is_data == true) && (full_name !~ */RSC* )"]]

	if {[llength [dbget -e selected.isInput 0]] > 0 } { 
	
	set OutPorts [dbget [dbget -e selected.isInput 0 -p ].name ] 
        set AllFanin [gon [gc -of [all_fanin -to $OutPorts]]]

        ds ; si $AllFanin
        highlight -index 1
        ds

        #set sp [gon [remove_from_collection  [gc -of [all_fanin -to $dataPin -startpoints_only]] [gc $ports]]]
	set sp [gon [gc -of [all_fanin -to $OutPorts -startpoints_only]]]
        ds ; si $sp
        highlight -index 2
        }
	
	}

}

#colorFanin
